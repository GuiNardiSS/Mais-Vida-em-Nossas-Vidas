# Modernização do “Mais Vida em Nossas Vidas” — Plano de Implementação

**Goal:** Transformar a versão mais avançada do app (`nome-da-branch` @ `68916e0`) + backend (`maisvidaapp-backend` @ `51725ec`) em um produto de portfólio moderno, fluido, visualmente refinado, 100% funcional offline e com modo de pagamento demonstrativo honesto.

**Architecture:** Base única no branch `nome-da-branch`, reorganizada em feature-first com Riverpod para estado, `go_router` para navegação, serviços/repositórios testáveis e um design system próprio. O backend passa a ser um monorepo `backend/`, endurecido e coberto por testes, com PIX mock e ativação de assinatura idempotente. Nada depende de serviços externos para a demonstração.

**Tech Stack:** Flutter stable (3.5x), Dart 3, Riverpod, go_router, just_audio + just_audio_background, Chewie, sqflite, flutter_secure_storage, flutter_local_notifications + timezone, share_plus, pdfx, shimmer, flutter_animate, fontes locais (Lora + Inter). Backend: Node 20/22, Express, Mongoose, Zod, Jest + Supertest, mongodb-memory-server, Swagger/OpenAPI, Docker Compose.

**Base escolhida (mais funcional e atual):**
- App: `origin/nome-da-branch` → commit `68916e0` (23/01/2026, 46 commits, históricos independentes do `main`).
- Backend: `maisvidaapp-backend` → `51725ec` (23/11/2025). `Mais_vida_backend` é duplicata inútil; `Mais-Vida-Em-Nossas-Vidas-final` está vazio.

## Decisões aprovadas

1. **Canal:** app de portfólio, sem publicação real. Os dois canais (Play Billing e PIX/Stripe) ficam documentados como arquitetura, mas a implementação entrega **modo demonstração** claramente sinalizado.
2. **Credenciais:** as contas existem, mas não serão usadas. Nenhum fluxo depende de credenciais externas.
3. **Mídia:** tudo **offline no APK**, com recompressão para reduzir tamanho.
4. **Identidade premium:** device ID + **login opcional por e-mail com OTP simulado**, sem rede.
5. **Entrega:** em fases utilizáveis, com aceite ao fim de cada fase.
6. **Direção visual:** editorial premium (petróleo + dourado + creme), Lora + Inter, light e dark mode, mantendo a identidade da marca.
7. **Escopo:** todas as telas atuais preservadas e modernizadas (Cartas do Dia, Organizações, Conheça Mais, Contato, Conteúdo, Patrocinadores, Assinaturas).

---

## Plano de testes (escrito primeiro)

Os testes serão escritos **antes** de cada comportamento. Nada de testar getters, tipos ou mocks isolados.

**Integração (app, `integration_test/`)**
- Onboarding → Home → revelar carta → player de áudio aparece → fechar → reabrir mostra a carta do dia persistida.
- Usuário free tenta abrir a segunda carta do dia → vê o dialog de limite → carta permanece bloqueada.
- Compra demo PIX → assinatura ativa → badge premium aparece → reiniciar o app → premium continua ativo.
- Conteúdo premium bloqueado → dialog “Recurso Premium” → navega para Assinaturas → ativa demo → conteúdo libera.
- Fluxo de login opcional: continuar sem conta; entrar com e-mail (OTP demo) → assinatura vinculada ao e-mail → “restaurar” em um segundo device simulado.

**Unitários (comportamento com dependências falsas)**
- `DailyUsageRepository`: limite reseta na virada do dia com relógio injetado; premium ignora limite; fusos e horário de verão.
- `AssetResolver`: resolve `Back (1).png`, `Back(1).png`, ausência de asset e fallback, sem depender do `AssetManifest.json`.
- `EntitlementRepository`: migra chaves antigas (`subscription_status`, `subscription_expiry`, `device_id`) sem perder premium; assinatura expirada vira `expired`.
- `PaymentService`: sucesso, erro HTTP, timeout e resposta malformada geram estados distintos e nunca ativam premium indevidamente.
- `BrCodeGenerator`: payload PIX com CRC16 válido e tamanhos corretos.

**Widget/Golden**
- Home (light e dark), grade de cartas com estado bloqueado, leitor de carta, tela de Assinaturas e estado “assinatura ativa”.
- Texto ampliado (1.3 e 2.0), tela pequena e tablet; sem overflow.

**Backend (Jest + Supertest + Mongo em memória)**
- `POST /api/v1/subscription/activate` rejeita ativação sem comprovante válido/webhook.
- Webhook de pagamento ativa uma única vez (idempotência), inclusive com reentrega.
- `GET /api/v1/pix/status/:id` transita `pending → paid` e reflete na validação.
- Assinatura expirada retorna `isActive: false`; cancelamento revoga acesso.
- Rate limit e validação Zod retornam 400/429 com schema de erro consistente.

**Manual**
- Emulador Android mid-range: abertura, scroll, troca de abas, áudio em background, vídeo, dark mode, rotação, offline total, TalkBack.

> NOTE: I will write *all* tests before I add any implementation behavior.

---

## Fase 0 — Preparação, baseline e CI

**0.1 Ambiente local**
- Instalar Flutter stable e Android SDK (cmdline-tools + platform/build-tools), aceitar licenças; usar o JDK 21 já presente; configurar `ANDROID_HOME`.
- Verificação: `flutter doctor -v` sem erros bloqueantes; `flutter devices`; build de um app vazio.
- Justificativa: Flutter/Android SDK não estão instalados nesta máquina.

**0.2 Estrutura de trabalho**
- Criar tag `legacy/main-2025-10` no `main` atual.
- Criar worktree `C:\Users\Guilherme\Mais-Vida-em-Nossas-Vidas-modern` a partir de `origin/nome-da-branch`; mover a sessão para ele via `tools.opencode.session_move`.
- Criar branch `modernization`.
- Verificação: `git log -1` aponta `68916e0`; `main` intacto.

**0.3 Backend no monorepo**
- Copiar `C:\Users\Guilherme\AppData\Local\Temp\opencode\repos\maisvidaapp-backend` para `backend/` (remove o submódulo quebrado sem `.gitmodules`).
- Adicionar `docker-compose.yml` (Mongo), `.env.example` revisado, scripts `dev`, `start`, `test`.
- Verificação: `npm ci && npm test` roda; `docker compose up` sobe o Mongo.

**0.4 Baseline mensurável**
- Rodar `flutter analyze`, `flutter test`, `flutter build apk --debug`, `npm test`; registrar falhas e tamanho em `docs/BASELINE.md`.
- Remover `build_log.txt` (2,7 MB) do versionamento; ajustar `.gitignore`.

**0.5 CI de portfólio**
- `.github/workflows/ci.yml`: format check, analyze, test, build APK debug, upload de artifact; job separado para o backend.
- Manter workflow de release apenas por tag, **sem exigir secrets** para o build de demonstração.
- Verificação: CI verde em um PR de teste.

**Aceite da fase:** app e backend rodando, build debug gerado, CI verde, baseline documentado.

---

## Fase 1 — Núcleo técnico e correções críticas

**1.1 Resolução de assets (crítico)**
- Substituir todos os usos de `rootBundle.loadString('AssetManifest.json')` por `AssetManifest.loadFromAssetBundle` em um `AssetResolver` único com cache.
- Arquivos: `lib/pages/cartas_do_dia.dart`, `lib/pages/cartas_organizacao.dart`, `lib/services/audio_service.dart`; novo `lib/core/assets/asset_resolver.dart`.
- Motivo: o arquivo foi removido do Flutter moderno (workflow usa 3.38.7); hoje isso quebra imagem/áudio.

**1.2 Estado e navegação**
- Adicionar `flutter_riverpod` e `go_router`; `ProviderScope` no `main.dart`; shell route com bottom navigation + drawer preservado; rotas nomeadas para Assinaturas, Conteúdo, Carta, Perfil.
- Migrar `SubscriptionService`, `UsageRestrictionService` e `AudioService` para providers/repositórios injetáveis (sem singletons escondidos).

**1.3 Áudio moderno**
- Trocar `audioplayers` por `just_audio` + `just_audio_background`: play/pause, seek, ±15 s, velocidade, progresso, controles na notificação e mini-player persistente.
- Arquivos: `lib/features/audio/…`; remover `lib/widgets/audio_control_widget.dart` antigo.

**1.4 Design tokens e tema**
- Criar `lib/design/tokens.dart` (cores, espaçamento 4/8/12/16/24/32, raios, sombras, tipografia) e `lib/design/app_theme.dart` com light/dark.
- Implementar `ThemeController` (arquivo hoje vazio) com `system/light/dark` persistido em `prefs`.
- Fontes locais: Lora (títulos) + Inter (texto), embarcadas em `assets/fonts/`.

**1.5 Erros, logs e robustez**
- Padronizar falhas com `sealed class AppFailure`; mensagens amigáveis; `ErrorWidget` discreto; logging existente mantido com níveis e rotação.
- Remover “proteções absolutas” improvisadas que escondem erros sem tratamento.

**1.6 Limpeza**
- Remover páginas/dialogs mortos (`pagamento_cartao.dart`, `pagamento_pix.dart` antigos, `CardPaymentDialog` sem uso), deps sem uso (`pay`, `flutter_svg`, `sqflite` se não adotado) e `assets/gpay.json`/`applepay.json`.

**1.7 Migração de dados**
- Migrar chaves antigas de `SharedPreferences`/secure storage para os novos repositórios, preservando device ID e premium.
- Verificação: teste de migração com dados legados.

**Aceite:** onboarding→home→carta→áudio funciona offline; 0 issues no analyze; testes verdes; APK debug instalável.

---

## Fase 2 — Redesign e experiência

**2.1 Design system aplicado**
- Componentes: `AppScaffold`, `SectionHeader`, `AppCard`, `PrimaryButton`, `GoldBadge`, `PremiumLock`, `EmptyState`, `Skeleton`, `AudioMiniPlayer`, `RevealCard`.
- Manter identidade: petróleo `#0B4C52`, dourado `#C9A65A`/`#E5B55E`, creme `#FBF6EC`; dark mode com superfícies profundas e dourado como acento.

**2.2 Navegação e shell**
- Bottom bar: Início, Cartas, Conteúdo, Organizações, Mais (abre sheet com Contato, Patrocinadores, Assinaturas, Perfil, Configurações). Drawer completo preservado para quem preferir.
- Transições com `go_router` e hero animations; respeito a “reduzir movimento”.

**2.3 Onboarding**
- 3 slides + vídeo de boas-vindas, indicador de progresso, “pular”, CTA final; persistência de conclusão.
- Arquivo base: `lib/pages/cartas_intro.dart` → `lib/features/onboarding/`.

**2.4 Home repaginada**
- Saudação por horário + data; hero “Carta do dia” com estado bloqueado/revelado; sequência (streak) e estatísticas; “Continue de onde parou”; destaques de conteúdo; faixa premium; mini-player.
- Skeleton loading e animações de entrada escalonadas.

**2.5 Cartas do Dia e Organizações**
- Grade elegante de costas de carta com padrão dourado, seleção com animação de revelação e haptic.
- Estado 1 carta/dia grátis com contagem regressiva; premium ilimitado; favoritos.
- Leitor fullscreen: pinça para zoom, swipe entre cartas, barra de áudio com progresso/seek/velocidade, compartilhar texto/imagem, salvar.

**2.6 Conteúdo**
- Busca, categorias (chips), progresso de vídeo com retomada, bloqueio premium, detalhe com Chewie (fullscreen), descrição e relacionados; leitor de PDF para o livro com `pdfx`.

**2.7 Contato e Patrocinadores**
- Perfil moderno com foto, bio expansível, botões sociais e formulário que abre WhatsApp/e-mail pré-preenchido.
- Patrocinadores com imagens reais, categorias e links; fallback elegante quando imagem faltar.

**2.8 Assinaturas (modo demonstração)**
- Landing premium com benefícios, comparativo Free × Premium e plano.
- Bottom sheet com abas PIX/Cartão; PIX gera BR Code **válido com CRC**; cartão com máscara, Luhn e validação; selo visível “Demonstração — nenhuma cobrança real”.
- Sucesso com animação, recibo, “Gerenciar assinatura”, “Restaurar compra” (demo) e contagem de dias.

**2.9 Acessibilidade e responsividade**
- Semântica, contraste AA, alvos ≥ 48 dp, escala de texto, tablets e landscape; revisar os layouts fixos apontados em `ANALISE_ORIENTACAO.md`.

**Aceite:** golden tests das telas-chave; checklist manual em 3 tamanhos; navegação fluida sem jank perceptível.

---

## Fase 3 — Funcionalidades modernas e backend de portfólio

**3.1 Favoritos, histórico e sequência**
- `sqflite` com DAO e migrações; telas “Minhas cartas” e histórico por dia; streak baseado em datas locais com relógio injetado.

**3.2 Lembretes e configurações**
- Notificação diária em horário escolhido, permissões, teste de notificação, tela “Configurações” com tema, lembretes, privacidade, resetar dados demo e versão.

**3.3 Compartilhamento**
- `share_plus` + captura do card via `RepaintBoundary` gerando imagem com marca; compartilhar mensagem e imagem.

**3.4 Perfil opcional (demo)**
- “Continuar sem conta” ou “Entrar com e-mail”: OTP simulado (código exibido na tela), vínculo com device, restauração de assinatura, logout e exclusão de dados.
- Abstração `AuthRepository` com implementação local (padrão) e implementação HTTP preparada, sem depender de rede.

**3.5 Backend endurecido**
- `/api/v1`, validação Zod, erros padronizados, request-id, logs, CORS allowlist, rate limit, health/readiness.
- Assinatura como máquina de estados (`pending/active/expired/cancelled`); ativação **somente** por webhook/comprovante; idempotência; `GET /pix/status/:id`; PIX com provider mock gerando BR Code válido.
- Swagger em `/docs`, testes Jest/Supertest com Mongo em memória, Dockerfile e Compose.
- Decisão registrada (ADR): manter JavaScript com Zod/JSDoc nesta entrega; TypeScript fica como evolução opcional.

**3.6 Documentação de portfólio**
- README com screenshots/GIFs, arquitetura, como rodar, roteiro de demonstração, decisões e limitações honestas (“pagamentos em modo demo”).
- Reorganizar os 20+ `.md` atuais em `docs/` (produto, design system, testes, legado); remover duplicatas.

**Aceite:** fluxo completo de demonstração sem rede externa; backend 100% testado; docs prontos para recrutador.

---

## Fase 4 — Qualidade, performance e consolidação

**4.1 Performance e tamanho**
- `flutter build apk --analyze-size`, lazy lists, `const`, evitar rebuilds; comprimir mídia (vídeos 720p, áudio 64 kbps mono, imagens WebP) mantendo tudo offline.
- Meta: reduzir o APK de ~215 MB para a faixa de ~100–130 MB sem perda visível.

**4.2 Segurança e privacidade**
- Nenhum segredo no repo; configuração por `--dart-define`; secure storage com fallback; validar entradas; política de privacidade e consentimento no app demo.

**4.3 Consolidação do repositório**
- Após aprovação: promover `modernization` a `main` com `--force-with-lease`, mantendo tag `legacy/main-2025-10`; proteger `main`; atualizar descrição e README do GitHub; versão `2.0.0+7`.
- Não alterar `applicationId` (`com.maisvidaemnossasvidas.official`) nem `minSdk 23`.

**Aceite:** CI verde, APK release de demonstração gerado, main atualizada, documentação publicada.

---

## Compatibilidade e migração (importante)

- **Não renomear** chaves antigas sem migração: `carta_dia_index/date`, `carta_org_index/date`, `cartas_dia_used_count`, `cartas_org_used_count`, `device_id`, `subscription_status/expiry`, `audio_mapping_dia/org`, `conteudos`, `theme_mode`.
- Preservar o **device ID** para não perder premium de quem testou a versão anterior.
- Manter caminhos de assets (`assets/cartas_do_dia/Back (N).png`, `assets/audios_cartas_dia/carta_N.mp3`) para não exigir renomear mídia.
- Manter textos, conteúdo e identidade visual; mudanças são de apresentação e engenharia.
- Android: mesmo `applicationId`, `minSdk 23`; atualização instalável por cima da versão anterior.
- iOS/web/desktop: não são alvo desta entrega; ficam compilando ou são explicitamente desabilitados na documentação.

## Casos de borda cobertos

Virada de dia com app aberto; relógio do aparelho alterado; primeira abertura offline; storage seguro indisponível; mídia ausente/corrompida; download/reprodução interrompida; duplo toque em pagar; ativação duplicada; assinatura expirada durante a sessão; reinstalação/troca de aparelho; texto 200%; landscape; tablet; pouco armazenamento; permissões de notificação negadas; usuário free tentando conteúdo premium por deep link; restauração de compra sem conta; dados legados corrompidos.

---

**Testing Details** — Testes de comportamento em três níveis: integração do fluxo completo (onboarding → carta → áudio → premium demo → persistência), unitários com relógio/bundle/HTTP falsos para regras de limite, assets, entitlement e PIX, e golden/widget para as telas-chave em light/dark e escalas de texto. Backend testado por API real com Mongo em memória, incluindo idempotência de webhook e expiração. Nenhum teste valida apenas mocks, tipos ou detalhes internos.

**Implementation Details**
- Base única: `nome-da-branch` (`68916e0`) + backend `51725ec`; `main` antiga preservada por tag.
- Correção mais urgente: eliminar `AssetManifest.json` e centralizar resolução de assets.
- Riverpod + go_router + design tokens + dark mode como fundação da modernização.
- Áudio com `just_audio`/background e mini-player; vídeo com Chewie; PDF com `pdfx`.
- Pagamentos apenas em **modo demonstração explícito**, com backend idempotente e testado.
- Login opcional por e-mail em modo demo local, sem dependência de rede.
- Mídia permanece offline no APK, com recompressão para reduzir tamanho.
- CI de portfólio sem secrets + build APK de demonstração.
- Documentação e screenshots como parte da entrega.
- Implementação em fases utilizáveis, com aceite ao fim de cada uma.

**Question** — Nenhuma pendente: as cinco decisões foram aprovadas em 16/11/2026.
