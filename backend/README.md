# Backend - Mais Vida em Nossas Vidas

API de assinaturas por dispositivo com **PIX**, **cartão (Stripe)** e um fluxo de
**entitlement** (concessão/revogação de acesso) baseado em pagamento confirmado.

O projeto foi pensado para ser um portfólio executável **sem credenciais
externas**: por padrão usa PIX `mock`, banco MongoDB local e testes com
`mongodb-memory-server`. O app Flutter usa modo demonstração local e não depende
deste backend para funcionar.

- JavaScript **ESM** (sem TypeScript)
- Express + Mongoose + Zod
- OpenAPI 3 + Swagger UI em `/docs`
- Jest + Supertest + `mongodb-memory-server`
- Docker/Docker Compose prontos para desenvolvimento

---

## Sumário

- [Arquitetura](#arquitetura)
- [Rodando localmente](#rodando-localmente)
- [Modo demonstração (sem credenciais)](#modo-demonstração-sem-credenciais)
- [Endpoints](#endpoints)
- [Aliases legados](#aliases-legados)
- [Formato de erro, request id e logs](#formato-de-erro-request-id-e-logs)
- [Segurança](#segurança)
- [Modelo de dados](#modelo-de-dados)
- [Stripe e webhooks](#stripe-e-webhooks)
- [Testes](#testes)
- [Docker](#docker)
- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Limitações conhecidas](#limitações-conhecidas)
- [Deploy](#deploy)

---

## Arquitetura

```
backend/
├── app.js                     # cria o app Express (testável, não abre porta)
├── index.js                   # processo: env, Mongo, listen, graceful shutdown
├── config/
│   ├── env.js                 # validação Zod de env + regras de segurança
│   └── database.js            # conexão/desconexão e isDBConnected()
├── middleware/
│   ├── auth.js                # JWT por deviceId (factory)
│   ├── error.js               # error handler + 404 padronizados
│   ├── rateLimit.js           # limiters por app (stores independentes)
│   ├── requestContext.js      # X-Request-Id + log de duração
│   ├── requireDatabase.js     # 503 DB_OFFLINE
│   └── validate.js            # validação Zod de body/query/params
├── schemas/                   # contratos Zod
├── routes/
│   ├── index.js               # /api/v1
│   ├── payments.js            # /payments/*
│   ├── subscription.js        # /subscription/*
│   ├── webhooks.js            # corpo cru do Stripe
│   └── legacy.js              # aliases das rotas antigas
├── controllers/               # tradução HTTP <-> serviços
├── services/
│   ├── paymentService.js      # cobrança PIX, transições de status
│   ├── entitlementService.js  # ativação idempotente e revogação
│   ├── subscriptionService.js # leitura/validação/cancelamento
│   ├── pixPayload.js          # BR Code EMV + CRC16
│   ├── pixProviders.js        # mock / Mercado Pago / Asaas / Efi
│   └── stripeService.js       # PaymentIntent + eventos de webhook
├── models/
│   ├── Payment.js             # pagamentos (PIX e cartão)
│   └── Subscription.js        # assinatura por deviceId
├── utils/                     # ApiError, asyncHandler, logger, CRC16
├── tests/                     # Jest + Supertest
├── openapi.yaml               # contrato OpenAPI 3
├── Dockerfile
├── docker-compose.yml
└── .env.example
```

Fluxo de uma requisição:

```
rota → rate limit → validação Zod → controller → service → model
                                              ↘ erro → error handler
                                                 { error: { code, message, details?, requestId } }
```

A ativação **nunca** confia em dados do cliente:

1. `Payment` é criado com status `pending`.
2. O pagamento vira `paid` por simulação demo (mock) ou webhook assinado (Stripe).
3. `applyEntitlementToPayment()` marca `entitlementApplied` de forma atômica e só
   então estende a assinatura. Repetir o mesmo pagamento não estende de novo.

---

## Rodando localmente

Pré-requisitos:

- Node.js 18+ (testado com Node 24)
- MongoDB local **ou** Docker Compose (a API sobe em modo degradado sem banco,
  mas endpoints de pagamento/assinatura respondem `503 DB_OFFLINE`)

```bash
cd backend
npm ci
cp .env.example .env      # Windows: copy .env.example .env
npm start
```

- API: http://localhost:3000
- Swagger UI: http://localhost:3000/docs
- OpenAPI: http://localhost:3000/openapi.yaml
- Health: http://localhost:3000/health

Scripts:

| Script | Descrição |
| --- | --- |
| `npm start` | inicia a API |
| `npm run dev` | inicia com `node --watch` |
| `npm test` | Jest em série (`--runInBand`) |
| `npm run test:watch` | Jest em modo watch |
| `npm run test:coverage` | cobertura |

Sem MongoDB local, use o Compose (seção [Docker](#docker)) ou apenas:

```bash
docker run --rm -p 27017:27017 mongo:7
```

---

## Modo demonstração (sem credenciais)

No `.env.example`:

```env
DEMO_MODE=true
DEMO_ACTIVATION_TOKEN=demo-activation-token
PIX_PROVIDER=mock
PIX_KEY=demo@maisvida.app
PLAN_AMOUNT_CENTS=499
PLAN_DAYS=30
```

### Fluxo PIX → pagamento → assinatura

```bash
# 1) cria cobrança mock (BR Code EMV válido com CRC16)
curl -X POST http://localhost:3000/api/v1/payments/pix \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"demo-device-001","amount":499}'
```

Resposta (resumida):

```json
{
  "paymentId": "665f2b0f5f1b2c0012345678",
  "provider": "mock",
  "status": "pending",
  "amount": 499,
  "brCode": "00020126...6304ABCD",
  "copiaECola": "00020126...6304ABCD",
  "transactionId": "mv...",
  "isMock": true
}
```

```bash
# 2) consulta status
curl http://localhost:3000/api/v1/payments/pix/<paymentId>

# 3) simula o pagamento (somente DEMO_MODE=true e provider mock)
curl -X POST http://localhost:3000/api/v1/payments/pix/<paymentId>/simulate \
  -H "Content-Type: application/json" -d '{}'

# 4) valida a assinatura
curl -X POST http://localhost:3000/api/v1/subscription/validate \
  -H "Content-Type: application/json" -d '{"deviceId":"demo-device-001"}'
# { "isActive": true, "status": "active", "expiryDate": "...", "daysRemaining": 30 }

# 5) info completa
curl "http://localhost:3000/api/v1/subscription/info?deviceId=demo-device-001"
```

Também é possível ativar **sem PIX** em demonstração, com o token do servidor:

```bash
curl -X POST http://localhost:3000/api/v1/subscription/activate \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"demo-device-001","demoToken":"demo-activation-token"}'
```

A ativação via pagamento real usa `paymentId` (nunca `transactionId`):

```bash
curl -X POST http://localhost:3000/api/v1/subscription/activate \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"demo-device-001","paymentId":"<paymentId>"}'
```

O BR Code é gerado conforme o padrão EMV do Banco Central (campo
`br.gov.bcb.pix`, valor, moeda `986`, país `BR`, txid e **CRC16/CCITT-FALSE**).
O `qrCodeImage` do mock é apenas um placeholder 1x1; renderize o `copiaECola`
para obter um QR escaneável.

---

## Endpoints

Base versionada: `/api/v1`. Todos os retornos são JSON.

| Método | Rota | Descrição | Limite |
| --- | --- | --- | --- |
| GET | `/health` | liveness | fora do limiter |
| GET | `/api/v1/health` | liveness + estado do Mongo | geral |
| GET | `/api/v1` | metadados e links | geral |
| POST | `/api/v1/payments/pix` | cria cobrança PIX | payment |
| GET | `/api/v1/payments/pix/:id` | status da cobrança | geral |
| POST | `/api/v1/payments/pix/:id/simulate` | simula pagamento (DEMO_MODE) | payment |
| POST | `/api/v1/payments/stripe/intent` | cria PaymentIntent | payment |
| POST | `/api/v1/webhooks/stripe` | webhook assinado do Stripe | webhook |
| POST | `/api/v1/subscription/activate` | ativa com `paymentId` ou `demoToken` | payment |
| POST | `/api/v1/subscription/validate` | valida contrato antigo | validation |
| GET | `/api/v1/subscription/info?deviceId=` | info da assinatura | geral |
| POST | `/api/v1/subscription/cancel` | cancela (idempotente) | geral |

Status de pagamento: `pending`, `paid`, `expired`, `cancelled`, `refunded`,
`failed`. Status de assinatura: `pending`, `active`, `expired`, `cancelled`.

### `POST /api/v1/payments/pix`

```json
{ "deviceId": "demo-device-001", "amount": 499, "deviceInfo": { "platform": "android" } }
```

- `amount` é inteiro em **centavos** (100 a 1.000.000).
- `valor` continua aceito como alias legado de `amount`.
- Sem `amount`/`valor`, usa `PLAN_AMOUNT_CENTS`.
- `201` com `paymentId`, `status: "pending"`, `brCode`, `transactionId`.

### `POST /api/v1/subscription/activate`

```json
{ "deviceId": "demo-device-001", "paymentId": "665f..." }
```

- `201` quando ativa; `200` quando o pagamento já havia sido aplicado
  (idempotente).
- `400 PAYMENT_REQUIRED` se não houver `paymentId` (inclusive se enviar apenas
  `transactionId`).
- `403 PAYMENT_DEVICE_MISMATCH`, `404 PAYMENT_NOT_FOUND`,
  `409 PAYMENT_NOT_PAID`/`PAYMENT_EXPIRED`.
- Retorna um JWT de dispositivo (`30d` por padrão), sem senha/login.

### Exemplos de erros

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Dados de entrada inválidos.",
    "details": [
      { "source": "body", "path": "body.deviceId", "message": "Required" }
    ],
    "requestId": "5d1f..."
  }
}
```

```json
{ "error": { "code": "DB_OFFLINE", "message": "Banco de dados indisponível...", "requestId": "..." } }
```

---

## Aliases legados

As rotas antigas continuam disponíveis e usam **os mesmos handlers** das rotas
`/api/v1` (sem duplicação de lógica). Elas estão marcadas como `deprecated` no
OpenAPI.

| Antiga | Equivalente |
| --- | --- |
| `POST /pix/gerar` | `POST /api/v1/payments/pix` |
| `GET /pix/:id` | `GET /api/v1/payments/pix/:id` |
| `POST /pagamento` | `POST /api/v1/payments/stripe/intent` |
| `POST /pagamento/criar-intent` | idem |
| `POST /subscription/activate` | `POST /api/v1/subscription/activate` |
| `POST /subscription/validate` | idem |
| `GET /subscription/info` | idem |
| `GET /subscription/info/:deviceId` | idem |
| `POST /subscription/cancel` | idem |

**Mudança intencional de segurança:** `/subscription/activate` não ativa mais
com `transactionId` arbitrário. Envie `paymentId` de um pagamento pago (ou
`demoToken` em modo demo).

---

## Formato de erro, request id e logs

- Todas as falhas seguem `{ error: { code, message, details?, requestId } }`.
- Todo response inclui `X-Request-Id`. Um `X-Request-Id` de entrada válido
  (8–128 chars `[A-Za-z0-9._:-]`) é reaproveitado; senão um UUID é gerado.
- Logs são uma linha JSON por evento (`level`, `time`, `msg`, `requestId`,
  `method`, `path`, `status`, `durationMs`), sem dependências pesadas.
  `LOG_LEVEL=silent` desliga (usado nos testes).
- Erros 5xx inesperados não vazam stack/mensagem fora de `development`.

---

## Segurança

- **CORS por allowlist** (`CORS_ORIGIN`, lista separada por vírgulas). `*` só é
  recomendado em desenvolvimento.
- **Helmet** com CSP própria (Swagger recebe CSP compatível com sua UI).
- **Rate limits** separados: geral, pagamento (5/15min), validação (10/min) e
  webhook. Limites configuráveis por env.
- **JWT_SECRET obrigatório** fora de `development`; em produção exige >= 16
  caracteres (recomendado 32+). Em desenvolvimento há fallback explícito com
  warning.
- **Nunca ativa com dados do cliente:** `amount`, `paymentMethod` e status vêm
  do registro de `Payment`, não do body.
- **Simulação restrita:** `/simulate` exige `DEMO_MODE=true` e provider `mock`;
  nunca confirma cobrança de provedor real.
- **Webhook Stripe:** valida `stripe-signature` quando
  `STRIPE_WEBHOOK_SECRET` existe; em produção o secret é obrigatório. O corpo
  cru é montado antes do `express.json()`.
- **Idempotência:** ativação por pagamento usa claim atômico
  (`findOneAndUpdate` com `entitlementApplied != true`); eventos duplicados não
  renovam duas vezes.
- **Revogação:** estorno total (`charge.refunded`) e
  `payment_intent.canceled` cancelam a assinatura; estorno parcial não revoga.
  Um pagamento posterior legítimo não é revogado por estorno do anterior.
- **Banco:** endpoints dependentes retornam `503 DB_OFFLINE` em vez de erro 500.
- **Limites de payload:** JSON `100kb`, webhook `1mb`.

---

## Modelo de dados

### `Payment`

Campos principais: `provider`, `method`, `deviceId`, `amount` (centavos),
`status`, `externalId` (id no provedor), `txid`, `brCode`, `expiresAt`,
`paidAt`, `entitlementApplied`, `events[]`.

Índices: `deviceId + createdAt`, `status + expiresAt` e
`provider + externalId` (único, parcial). Não há TTL: dados financeiros não são
apagados automaticamente.

### `Subscription`

Uma assinatura por `deviceId` (índice único), com `status`, `startDate`,
`expiryDate`, `lastPaymentId`, histórico de `paymentIds`, `deviceInfo` e dados
de cancelamento/revogação.

Métodos:

- `isActive()` — ativa e com `expiryDate` no futuro
- `daysRemaining()`
- `renew(months)` — soma meses sem encurtar acesso vigente
- `cancel(reason)` / `revoke(reason)`

A ativação soma `PLAN_DAYS` à maior data entre **agora** e a expiração atual.
Validações fazem expiração preguiçosa (`active` vencida → `expired`).

---

## Stripe e webhooks

1. Configure `STRIPE_SECRET_KEY` e `STRIPE_WEBHOOK_SECRET`.
2. Crie o intent:

```bash
curl -X POST http://localhost:3000/api/v1/payments/stripe/intent \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"demo-device-001","amount":499}'
```

```json
{ "clientSecret": "pi_..._secret_...", "paymentIntentId": "pi_...", "paymentId": "..." }
```

3. Encaminhe eventos locais:

```bash
stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe
```

4. Eventos tratados:
   - `payment_intent.succeeded` → marca pago + ativa assinatura
   - `payment_intent.payment_failed` → marca `failed`
   - `payment_intent.canceled` → revoga
   - `charge.refunded` (estorno total) → revoga

Sem `STRIPE_WEBHOOK_SECRET`, webhooks só são aceitos fora de produção (modo de
teste, com warning no log). Em produção, a ausência do secret resulta em `503`.

Cartão de teste Stripe: `4242 4242 4242 4242`, data futura, CVC qualquer.

---

## Testes

```bash
npm test
npm run test:watch
```

Cobertura atual (65 testes, Jest + Supertest + `mongodb-memory-server`):

- criação de PIX mock com BR Code EMV válido e CRC16
- consulta de status, 404 e validação Zod (400)
- simulação de pagamento, ativação e idempotência (não estende duas vezes)
- rejeição de ativação sem pagamento pago / com `transactionId` arbitrário
- expiração de pagamento e de assinatura
- cancelamento idempotente
- renovação somando período ao tempo restante (serviço e método `renew()`)
- token de demonstração válido/inválido e demo desabilitado
- webhook Stripe: assinatura inválida, ativação, duplicata, falha, estorno
  total, estorno parcial e evento sem secret fora de produção
- erro padronizado, request id, JSON inválido, Helmet, CORS allowlist, Swagger
- rate limits (geral, pagamento, validação) e `503 DB_OFFLINE`
- validação de ambiente (`JWT_SECRET`, `DEMO_MODE`, CORS, provider)

O `mongodb-memory-server` baixa um binário do MongoDB na primeira execução
(requer internet). Não é necessário MongoDB local nem credenciais externas.

**O que não é testado sem credenciais:** chamadas reais a Mercado Pago, Asaas,
Efi e Stripe. O webhook do Stripe é testado offline com assinatura gerada pelo
SDK. Os providers reais estão implementados, mas validados apenas por revisão de
contrato.

---

## Docker

API + MongoDB:

```bash
docker compose up --build
```

- API: http://localhost:3000
- Swagger: http://localhost:3000/docs
- Mongo: `mongodb://localhost:27017/maisvidaapp` (sem autenticação; apenas dev)

O Compose usa `DEMO_MODE=true`, `PIX_PROVIDER=mock` e um `JWT_SECRET` de
desenvolvimento. Para sobrescrever, edite o bloco `environment` do
`docker-compose.yml` ou crie um `.env` na mesma pasta (variáveis `JWT_SECRET`,
`CORS_ORIGIN`, etc.).

Build isolado:

```bash
docker build -t mais-vida-backend .
docker run --rm -p 3000:3000 --env-file .env mais-vida-backend
```

O container roda como usuário `node` (não-root) e tem healthcheck em `/health`.

**Não use o Compose como está em produção:** ajuste autenticação do Mongo,
rede, TLS, secrets e réplicas.

---

## Variáveis de ambiente

| Variável | Default | Observação |
| --- | --- | --- |
| `NODE_ENV` | `development` | `production` exige `JWT_SECRET` forte |
| `PORT` | `3000` | |
| `MONGODB_URI` | `mongodb://127.0.0.1:27017/maisvidaapp` | |
| `TRUST_PROXY` | `false` | `true` atrás de proxy confiável |
| `JWT_SECRET` | fallback só em dev | obrigatório em test/prod |
| `JWT_EXPIRES_IN` | `30d` | |
| `CORS_ORIGIN` | `*` | allowlist separada por vírgula |
| `DEMO_MODE` | `false` | habilita `/simulate` e demo token |
| `DEMO_ACTIVATION_TOKEN` | — | obrigatório em prod com DEMO_MODE |
| `PIX_PROVIDER` | `mock` | `mock\|mercadopago\|asaas\|efi` |
| `PIX_KEY` | `demo@maisvida.app` | |
| `PIX_RECEIVER_NAME` | `MAIS VIDA` | máx. 25 chars no BR Code |
| `PIX_RECEIVER_CITY` | `SAO PAULO` | máx. 15 chars |
| `PIX_EXPIRATION_SECONDS` | `3600` | |
| `MERCADOPAGO_ACCESS_TOKEN` | — | provider real |
| `ASAAS_API_KEY` / `ASAAS_CUSTOMER_ID` | — | provider real |
| `EFI_CLIENT_ID` / `EFI_CLIENT_SECRET` | — | provider real |
| `STRIPE_SECRET_KEY` | — | sem chave → 503 |
| `STRIPE_WEBHOOK_SECRET` | — | obrigatório em prod p/ webhook |
| `PLAN_AMOUNT_CENTS` | `499` | default quando body omite valor |
| `PLAN_DAYS` | `30` | duração da ativação/renovação |
| `RATE_LIMIT_GENERAL_*` | `30/min` | |
| `RATE_LIMIT_PAYMENT_*` | `5/15min` | |
| `RATE_LIMIT_VALIDATION_*` | `10/min` | |
| `LOG_LEVEL` | `info` (`silent` em test) | |
| `DOCS_ENABLED` | `true` | Swagger UI |

---

## Limitações conhecidas

- **Sem contas de usuário:** a identidade é o `deviceId` + JWT de dispositivo.
  Não há login, senha ou recuperação de conta. Para produção real, considere
  autenticação de usuário e vinculação de dispositivos.
- **QR Code mock:** `imagemQrCode` é um placeholder; o payload `copiaECola` é
  válido e pode ser renderizado pelo cliente.
- **Providers reais** (Mercado Pago, Asaas, Efi) não foram exercitados contra
  sandbox por falta de credenciais. Revise os contratos antes de produção.
- **Rate limit em memória:** em múltiplas réplicas, use um store compartilhado
  (Redis) para limites globais.
- **Eventos de webhook** não são persistidos em coleção própria; a idempotência
  é garantida no `Payment` (`entitlementApplied`) e nos eventos do pagamento.
- **Mongo sem autenticação no Compose:** apenas para desenvolvimento.
- **Estorno parcial** não revoga automaticamente o acesso.
- Não há job agendado de expiração; a transição `active → expired` é feita
  preguiçosamente nas leituras/validações (e há índice para um job futuro).

---

## Deploy

Checklist mínimo:

- [ ] `NODE_ENV=production` e `JWT_SECRET` forte (32+ chars)
- [ ] `CORS_ORIGIN` com domínio(s) explícitos
- [ ] `DEMO_MODE=false` (ou token demo forte e consciente)
- [ ] `MONGODB_URI` com autenticação/TLS
- [ ] `STRIPE_WEBHOOK_SECRET` configurado se usar cartão
- [ ] Credenciais de PIX reais se `PIX_PROVIDER != mock`
- [ ] HTTPS e proxy reverso (`TRUST_PROXY=true` quando aplicável)
- [ ] Store compartilhado de rate limit se houver múltiplas réplicas
- [ ] Monitoramento dos logs JSON e alertas de 5xx

Guias existentes:

- [CONFIGURACAO_CONTAS.md](./CONFIGURACAO_CONTAS.md) — como criar contas e obter
  credenciais de pagamento
- [INTEGRACAO_CIELO_NFE.md](./INTEGRACAO_CIELO_NFE.md) — integração Cielo/NFe

---

**Projeto de portfólio. Use somente cartões e chaves de teste em ambiente de
desenvolvimento.**
