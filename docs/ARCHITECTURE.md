# Arquitetura

## Visão geral

O app é organizado por **features** e camadas explícitas, mantendo a simplicidade de um aplicativo offline-first.

```
main.dart
└── ProviderScope
    └── MyApp (tema claro/escuro)
        └── CartasIntroPage (onboarding + gate)
            └── HomeShell (NavigationBar + Drawer)
                ├── DashboardPage
                ├── CardsPage (Dia)
                ├── ConteudoPage
                ├── CardsPage (Organizações)
                └── MorePage
```

## Decisões

| Decisão | Motivo |
|---|---|
| Base na branch `nome-da-branch` | Era a versão mais completa (jan/2026), com restrições, conteúdo e configuração Android de release. |
| `material_ui` | Pacote oficial do Material para Flutter 3.50; `flutter/material.dart` está depreciado. |
| Riverpod apenas para tema | Evita reescrever todo o app em um state manager; o estado local é pequeno e explícito. |
| Sem login obrigatório | Mantém a essência do produto; a conta é opcional e demonstrativa. |
| Pagamento demo | O projeto é portfólio; a integração real não é necessária e não deve simular dinheiro de forma enganosa. |
| Mídia offline | Requisito do produto; o custo é o tamanho do APK. |
| `AssetResolver` | `AssetManifest.json` foi removido do Flutter moderno; a API `AssetManifest` é o caminho suportado. |
| Backend como monorepo | Elimina o submódulo quebrado e mantém app + API versionados juntos. |

## Fluxo de assinatura (demo)

1. Usuário abre Assinaturas e escolhe PIX ou cartão.
2. `DemoPaymentSheet` valida os dados e gera a transação.
3. `SubscriptionService.activateSubscription` grava status, expiração e transação no `flutter_secure_storage` (fallback para SharedPreferences).
4. `UsageRestrictionService` consulta `SubscriptionService.isPremium()` e libera cartas/conteúdos.
5. Cancelar remove o entitlement local.

## Fluxo de cartas

1. `CardsPage` carrega assinatura, uso diário, carta selecionada e favoritos.
2. O toque verifica `UsageRestrictionService.canSelect...`.
3. A seleção é registrada em `SharedPreferences` com data (`YYYY-MM-DD`).
4. `AssetResolver` resolve a arte `Back (N).png`.
5. `CardReaderPage` abre a carta, inicia o áudio e permite favoritar/compartilhar.

## Backend

- `backend/app.js` monta a API.
- Rotas versionadas em `/api/v1`, com aliases legados.
- Serviços: `paymentService`, `entitlementService`, `subscriptionService`, `pixProviders`.
- Modelos: `Subscription`, `Payment`.
- Testes com `mongodb-memory-server` e Supertest.

## Compatibilidade

- Chaves antigas de `SharedPreferences` e secure storage são preservadas.
- `applicationId` e `minSdk` não mudam.
- Assets mantêm os nomes originais.
