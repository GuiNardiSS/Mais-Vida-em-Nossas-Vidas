# Testes

## Como rodar

```bash
flutter analyze --no-fatal-infos
flutter test
cd backend && npm ci && npm test
```

## Estratégia

Os testes priorizam **comportamento observável**, não detalhes internos.

### App

| Teste | O que garante |
|---|---|
| `AssetResolver.resolveCardBack` | Encontra `Back (1).png`, variantes de nome e não confunde 1 com 10. |
| `AssetResolver.resolveAudio` | Resolve `carta_N.mp3`, zero à esquerda e formatos alternativos. |
| `BrCodeGenerator` | Campos obrigatórios, valor formatado, sanitização e CRC16 válido. |

### Backend

O backend possui suíte própria em `backend/test` com Jest + Supertest + Mongo em memória, cobrindo:

- criação de PIX e consulta de status;
- simulação de pagamento apenas em modo demo;
- ativação idempotente de assinatura;
- rejeição de ativação sem pagamento válido;
- expiração e cancelamento;
- validação de entrada e erros padronizados.

## Lacunas conhecidas

- Testes de widget das telas principais.
- Testes de integração do fluxo onboarding → carta → áudio → premium.
- Golden tests para light/dark.
- Testes de player de áudio (dependem de plugin nativo).

Essas lacunas estão no roadmap e foram priorizadas depois da estabilização visual.
