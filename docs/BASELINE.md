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
| `flutter analyze` | pendente (Flutter em instalação) |
| `flutter test` | pendente |
| `flutter build apk --debug` | pendente |
| `cd backend && npm ci` | pendente |

Este documento será atualizado ao final da Fase 0 com os resultados medidos.
