# 💳 Sistema de Pagamento e Assinaturas

## 📋 Visão Geral

Sistema completo de assinaturas premium com pagamento via **PIX** e **Cartão de Crédito**, utilizando identificação única do dispositivo (sem necessidade de login de usuário).

**💰 O DINHEIRO VAI DIRETO PARA SUA CONTA!**

---

## 🏦 IMPORTANTE: Configuração das Contas

### Onde o Dinheiro é Depositado?

#### 💳 Pagamentos com Cartão (Stripe)
- O dinheiro é **depositado automaticamente** na conta bancária que você cadastrar no Stripe
- Prazo: 2-7 dias úteis após o pagamento
- Taxa: ~3,99% + R$ 0,39 por transação

**Como configurar:**
1. Crie conta no Stripe: https://dashboard.stripe.com/register
2. Vá em **Settings > Payouts**
3. Adicione sua conta bancária (qualquer banco brasileiro)
4. **Pronto!** Todos os pagamentos vão para esta conta

#### 💚 Pagamentos com PIX
- O dinheiro é **depositado na conta** vinculada à sua chave PIX
- Recebimento: Instantâneo ou D+1 (dependendo do provedor)
- Taxa: 0,99% a 3,99% (dependendo do provedor)

**Provedores disponíveis:**
- **Mercado Pago**: Recebe no saldo, transfere grátis para banco
- **Asaas**: Recebe na conta em D+1
- **Efi**: Recebe na conta em D+1

**📖 Guia completo de configuração:**
Veja: `meu_backend_node/CONFIGURACAO_CONTAS.md`

---

## 🏗️ Arquitetura

### Serviços Implementados

#### 1. **DeviceService** (`lib/services/device_service.dart`)
- Gera identificação única do dispositivo usando `device_info_plus` e `crypto`
- Cria hash SHA256 para segurança
- Armazena ID localmente para persistência
- Suporta Android, iOS e outras plataformas

#### 2. **SubscriptionService** (`lib/services/subscription_service.dart`)
- Gerencia status da assinatura (free, active, expired, pending)
- Sincronização com backend via API REST
- Armazenamento local usando `SharedPreferences`
- Validação automática de expiração
- Métodos principais:
  - `isPremium()` - Verifica se tem assinatura ativa
  - `activateSubscription()` - Ativa assinatura após pagamento
  - `validateSubscription()` - Sincroniza com backend
  - `getSubscriptionInfo()` - Obtém detalhes da assinatura

#### 3. **PaymentService** (`lib/services/payment_service.dart`)
- Integração com backend para pagamentos
- Métodos principais:
  - `generatePixPayment()` - Gera QR Code PIX
  - `createCardPayment()` - Cria Payment Intent (Stripe)
  - `confirmPayment()` - Confirma pagamento e ativa assinatura
  - `checkPixPaymentStatus()` - Verifica status do PIX

### Widgets de Pagamento

#### 1. **PixPaymentDialog** (`lib/widgets/pix_payment_dialog.dart`)
- Gera QR Code PIX usando `qr_flutter`
- Exibe código "Copia e Cola"
- Botão para copiar código
- Botão "Já paguei" para confirmação manual
- Feedback visual com SnackBars

#### 2. **CardPaymentDialog** (`lib/widgets/card_payment_dialog.dart`)
- Formulário completo de cartão de crédito
- Máscaras de formatação usando `mask_text_input_formatter`
- Validação de campos
- Integração com Stripe Payment Intent
- Processamento seguro

### Página de Assinaturas

**AssinaturasPage** (`lib/pages/assinaturas.dart`)
- Exibe vídeo explicativo
- Mostra detalhes do plano mensal (R$ 4,99)
- Botões de pagamento (PIX e Cartão)
- Status da assinatura atual:
  - ✅ **Ativa**: Mostra dias restantes e data de expiração
  - ❌ **Inativa**: Mostra botões de pagamento
- Opção de renovar assinatura

## 🔧 Configuração

### Backend (Node.js)

O backend já está configurado em `meu_backend_node/`:

**Rotas disponíveis:**
- `POST /pix/gerar` - Gera pagamento PIX
- `GET /pix/status/:id` - Verifica status do PIX
- `POST /pagamento/criar-intent` - Cria Payment Intent (Stripe)
- `POST /subscription/activate` - Ativa assinatura
- `POST /subscription/validate` - Valida assinatura

**Para iniciar o backend:**
```bash
cd meu_backend_node
npm install
npm start
```

### Variáveis de Ambiente (.env)

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/maisvidaapp
STRIPE_SECRET_KEY=sk_test_...
PIX_API_URL=https://api.provedor-pix.com.br
PIX_CLIENT_ID=seu_client_id
PIX_CLIENT_SECRET=seu_client_secret
CORS_ORIGIN=*
```

### Flutter

As dependências já estão no `pubspec.yaml`:
- `device_info_plus: ^10.1.0` - Informações do dispositivo
- `crypto: ^3.0.3` - Hash SHA256
- `sqflite: ^2.3.3+1` - Banco de dados local
- `http: ^1.2.2` - Requisições HTTP
- `qr_flutter: ^4.1.0` - Geração de QR Code
- `mask_text_input_formatter: ^2.9.0` - Máscaras de input
- `shared_preferences: ^2.4.12` - Armazenamento local

## 🚀 Fluxo de Uso

### Pagamento via PIX

1. Usuário clica em "Pix"
2. Sistema gera QR Code e código "Copia e Cola"
3. Usuário escaneia ou copia código
4. Realiza pagamento no banco
5. Clica em "Já paguei"
6. Sistema confirma e ativa assinatura

### Pagamento via Cartão

1. Usuário clica em "Cartão"
2. Preenche dados do cartão:
   - Número (16 dígitos)
   - Nome completo
   - Validade (MM/AA)
   - CVV (3 dígitos)
3. Clica em "Pagar"
4. Sistema processa via Stripe
5. Assinatura ativada automaticamente

## 🔒 Segurança

- **Device ID**: Hash SHA256 do identificador do dispositivo
- **HTTPS**: Comunicação criptografada (produção)
- **Stripe**: PCI-DSS compliant para cartões
- **Rate Limiting**: Proteção contra abuso (backend)
- **Validação**: Todos os inputs são validados

## 📱 Identificação do Dispositivo

**Android:**
- Usa `androidInfo.id` (Android ID único)
- Persiste após reinstalação do app

**iOS:**
- Usa `iosInfo.identifierForVendor`
- Único por app/dispositivo

**Outras plataformas:**
- Fallback com timestamp + hash

## 💾 Armazenamento Local

**SharedPreferences:**
- Status da assinatura
- Data de expiração
- Transaction ID
- Última verificação

**Sincronização:**
- Automática a cada 24 horas
- Manual ao abrir página de assinaturas
- Mantém dados locais em caso de erro de conexão

## 🧪 Testes

### Testar sem Backend

O sistema funciona em modo simulação:
- PIX: Gera QR Code de exemplo
- Cartão: Simula pagamento após 2 segundos
- Assinatura: Armazena localmente

### Testar com Backend

1. Inicie o backend:
   ```bash
   cd meu_backend_node
   npm start
   ```

2. Configure a URL no app:
   - Android Emulator: `http://10.0.2.2:3000`
   - iOS Simulator: `http://localhost:3000`
   - Dispositivo físico: `http://SEU_IP:3000`

3. Execute o app:
   ```bash
   flutter run
   ```

## 📊 Monitoramento

### Logs do Backend

```bash
# Ver logs em tempo real
npm start

# Logs incluem:
- Pagamentos gerados
- Assinaturas ativadas
- Validações realizadas
- Erros e exceções
```

### Logs do Flutter

```dart
// DeviceService
await DeviceService.getDeviceInfo(); // Info do dispositivo

// SubscriptionService
await SubscriptionService.getSubscriptionInfo(); // Status completo
```

## 🔄 Renovação

- **Automática**: Não implementada (requer webhooks)
- **Manual**: Usuário pode renovar clicando em "Renovar Assinatura"
- **Notificação**: Avisar 3 dias antes da expiração (implementar)

## 📈 Próximas Melhorias

- [ ] Webhook para confirmação automática de PIX
- [ ] Renovação automática de cartão
- [ ] Planos anuais com desconto
- [ ] Sistema de cupons de desconto
- [ ] Histórico de pagamentos
- [ ] Notificações push de expiração
- [ ] Analytics de conversão

## 🐛 Troubleshooting

### "Erro de conexão"
- Verifique se o backend está rodando
- Confirme a URL no PaymentService
- Teste a rede do dispositivo/emulador

### "Pagamento não confirma"
- Verifique logs do backend
- Confirme que o device ID está sendo gerado
- Teste manualmente a API

### "Assinatura não aparece"
- Limpe cache: `SubscriptionService.clearSubscription()`
- Force sincronização: `SubscriptionService.validateSubscription()`
- Verifique SharedPreferences

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique os logs do backend e app
2. Consulte a documentação da API
3. Teste em modo simulação primeiro
