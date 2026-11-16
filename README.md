# Mais Vida em Nossas Vidas

[![CI](https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/GuiNardiSS/Mais-Vida-em-Nossas-Vidas/actions/workflows/ci.yml)

Aplicativo mobile de espiritualidade e bem-estar, construído em Flutter, com cartas diárias ilustradas, áudios narrados, conteúdos exclusivos e uma experiência premium **em modo demonstração**.

> Projeto de portfólio. Não é publicado em loja e não processa pagamentos reais. Toda a experiência funciona offline.

## ✨ Destaques

- **Onboarding editorial** com vídeo de boas-vindas, identidade em petróleo e dourado, e suporte a tema claro/escuro.
- **Cartas do Dia e Organizações**: 50 cartas em cada categoria, leitura em tela cheia com zoom, player de áudio com progresso, favoritos e compartilhamento.
- **Regras free/premium**: 1 carta gratuita por dia; assinatura libera cartas ilimitadas e conteúdos exclusivos.
- **Premium demonstrativo**: PIX com BR Code válido (CRC16) e cartão com validação Luhn — sem cobrança e sem enviar dados.
- **Conteúdo** com vídeos, capa de livro e bloqueio premium.
- **Conta opcional** com OTP simulado para demonstrar restauração de acesso em outro aparelho.
- **Patrocinadores reais**, página de contato e textos institucionais preservados.
- **Design system próprio**: cores, tipografia (Lora + Inter), componentes, skeletons, animações e acessibilidade.

## 📸 Telas

| Onboarding | Início | Cartas do Dia |
| --- | --- | --- |
| ![Onboarding](docs/screenshots/onboarding.png) | ![Início](docs/screenshots/home.png) | ![Cartas](docs/screenshots/cards.png) |

| Início (tema escuro) |
| --- |
| ![Início escuro](docs/screenshots/home-dark.png) |

## 🧱 Stack

| Camada | Tecnologia |
|---|---|
| App | Flutter 3.50, Dart 3.14 |
| UI | `material_ui`, design system próprio, `flutter_animate` |
| Estado | `flutter_riverpod` |
| Mídia | `video_player`, `audioplayers`, `qr_flutter` |
| Persistência | `shared_preferences`, `flutter_secure_storage`, `sqflite` |
| Serviços | `path_provider`, `share_plus`, `url_launcher`, `device_info_plus` |
| Backend | Node.js ESM, Express, Mongoose, Zod, JWT, Jest/Supertest |
| Qualidade | `flutter analyze`, testes unitários, CI no GitHub Actions |

## 🚀 Rodando o app

Pré-requisitos: Flutter stable (3.50+), Android SDK e um emulador/dispositivo.

```bash
flutter pub get
flutter run
```

No Windows, habilite o **Modo de Desenvolvedor** (necessário para symlinks de plugins):

```powershell
start ms-settings:developers
```

Build de demonstração:

```bash
flutter build apk --debug
# ou
flutter build apk --release
```

> A mídia é embarcada no APK para funcionar 100% offline. O tamanho do build é maior por causa dos vídeos e áudios.

## 💳 Modo demonstração

O app abre com um selo explícito de demonstração. Nenhuma cobrança é realizada e nenhum dado sai do aparelho.

- PIX: gera um BR Code estruturalmente válido (CRC16) e ativa a assinatura localmente ao simular o pagamento.
- Cartão: formulário com máscara, Luhn e cartão de teste (`4242 4242 4242 4242`).
- Login: OTP fixo exibido na tela (`123456`) para demonstrar o fluxo de restauração.
- Para desativar o modo demo em uma build: `flutter run --dart-define=DEMO_MODE=false` (a integração real depende do backend).

## 🧪 Testes

```bash
flutter analyze
flutter test
cd backend && npm test
```

Cobertura atual:

- **15 testes no app**: `AssetResolver`, `BrCodeGenerator` e favoritos.
- **65 testes no backend**: PIX, ativação idempotente, validação, expiração, cancelamento, webhook e rate limit.
- CI verde com `flutter analyze`, `flutter test`, APK debug e `npm test`.

## 📁 Estrutura

```
lib/
├── core/               # assets, pagamentos demo, configuração
├── design/             # tokens, tema e componentes visuais
├── features/           # conteúdo, favoritos, pagamentos, settings
├── pages/              # onboarding, shell, dashboard, cartas, premium
├── services/           # áudio, assinatura, device, storage, logs
├── data/               # mensagens e catálogo local
└── main.dart
backend/                # API Node.js + MongoDB (opcional)
docs/                   # arquitetura, design, testes e legado
assets/                 # cartas, áudios, vídeos, fontes e imagens
```

## 🧭 Arquitetura

- **Apresentação**: widgets + tema + componentes reutilizáveis.
- **Estado**: Riverpod para tema; estado local de tela com `setState` onde é simples e explícito.
- **Domínio**: repositórios e serviços testáveis (`AssetResolver`, `FavoritesRepository`, `SubscriptionService`).
- **Dados**: preferências locais, armazenamento seguro e SQLite preparado para histórico.
- **Backend**: API versionada, validação Zod, entitlement por pagamento, testes com Mongo em memória.

Detalhes em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) e [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md).

## 📌 Limitações conhecidas

- Publicação em loja, assinatura real e envio de e-mail não fazem parte do escopo.
- iOS/web/desktop não são alvos desta entrega (o build web existe para demonstração).
- A mídia é offline e o APK de debug ainda é grande; a evolução prevista é CDN/Asset Delivery.
- O áudio usa `audioplayers`; player em background com controles na notificação está no roadmap.

## 🗺️ Próximos passos

- Lembretes diários configuráveis.
- Histórico de cartas e sequência (streak) persistidos em SQLite.
- Player de áudio em background com controles na notificação.
- Testes de integração e golden tests das telas principais.
- Migração opcional do backend para TypeScript.

## 👤 Créditos

Conteúdo, marca e textos: **Helô Coelho** — Mais Vida em Nossas Vidas.
Código e modernização: projeto de portfólio.
