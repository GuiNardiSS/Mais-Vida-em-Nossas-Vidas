# Baseline do projeto — início da modernização

Registro do estado encontrado antes de qualquer alteração de comportamento.

## Base adotada

- **App:** branch `nome-da-branch`, commit `68916e0` (23/01/2026). É a versão mais completa e recente encontrada.
- **Backend:** repositório `GuiNardiSS/maisvidaapp-backend`, commit `51725ec` (23/11/2025), agora copiado para `backend/`.
- **Backup da versão antiga:** tag `legacy/main-2025-10` (commit `ea79b82`, 11/10/2025).

## Por que essa base

- O `main` do repositório está parado em outubro/2025 e tem histórico sem ancestral comum com `nome-da-branch`.
- A branch contém introdução com vídeo, restrições free/premium, assinatura por device, conteúdo premium, patrocinadores reais, logging, responsividade e configuração Android de release.
- O repositório `Mais-Vida-Em-Nossas-Vidas-final` está vazio e não contribui.
- `Mais_vida_backend` é uma duplicata exata de `maisvidaapp-backend`.

## Problemas conhecidos no baseline

1. `AssetManifest.json` é usado em `cartas_do_dia.dart`, `cartas_organizacao.dart` e `audio_service.dart`. Esse arquivo foi removido das versões modernas do Flutter, o que quebra imagem e áudio.
2. Pagamento de cartão usa Stripe Payment Sheet sem `publishableKey`; PIX é gerado localmente sem integração real.
3. Backend libera assinatura confiando em dados enviados pelo cliente.
4. Workflow de build APK falhou em todas as 9 execuções registradas (16/01 a 23/01/2026); logs expirados.
5. AAB local de aproximadamente 215 MB por mídia embarcada.
6. Teste padrão de contador no lugar de testes reais.
7. Código e assets sem uso: páginas antigas de pagamento, `CardPaymentDialog`, `pay`, `gpay.json`, `applepay.json`.
8. Documentação fragmentada em mais de 20 arquivos na raiz.

## Ambiente de desenvolvimento

- Flutter e Android SDK não estavam instalados na máquina no início da modernização.
- Java 21 e Node.js já estavam disponíveis.
- A instalação do Flutter stable 3.50.0 foi iniciada em `C:\Users\Guilherme\development\flutter`.

## Comandos de baseline

| Comando | Resultado inicial |
|---|---|
| `flutter pub get` | OK, dependências atualizadas |
| `flutter analyze` | 0 issues após migrar imports para `package:material_ui` |
| `flutter test` | 12 testes passando (AssetResolver + BrCodeGenerator) |
| `flutter build apk --debug` | pendente: Android SDK e Developer Mode não estão configurados |
| `cd backend && npm ci` | OK, 120 pacotes |

## Resultado da modernização

- **App**: 15 testes passando, `flutter analyze` sem issues, APK debug gerado no CI.
- **Backend**: 65 testes passando (Jest + Supertest + Mongo em memória).
- **Mídia**: reduzida de **160,8 MB para 74,5 MB** com recompressão de áudio/vídeo e cartas em WebP.
- **CI**: workflow `CI` verde em `main` (analyze, testes, APK debug, backend).
- **Documentação**: README de portfólio, arquitetura, design system, testes e capturas de tela.

## Próximos passos

- Promover `modernization` a `main` e manter a tag `legacy/main-2025-10` como backup.
- Lembretes diários configuráveis.
- Histórico/streak em SQLite.
- Player em background.
- Testes de integração e golden tests.
