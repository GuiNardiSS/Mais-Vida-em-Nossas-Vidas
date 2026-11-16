# Design System

## Princípios

1. **Editorial e acolhedor** — serifada nos títulos, respiro generoso e dourado como acento, nunca como ruído.
2. **Contraste e legibilidade** — texto confortável em light e dark, com hierarquia clara.
3. **Movimento discreto** — animações de entrada, revelação de cartas e feedback tátil; respeito a “reduzir movimento”.
4. **Offline primeiro** — todos os componentes funcionam sem rede.

## Cores

| Token | Light | Dark | Uso |
|---|---|---|---|
| `petrol` | `#0B4C52` | `#2E8A8F` (primário) | Marca, botões, cabeçalhos |
| `petrolDeep` | `#07383D` | `#06181A` | Gradientes e fundos |
| `gold` | `#C9A65A` | `#E5B55E` | Acentos, badges, ícones |
| `goldBright` | `#E5B55E` | `#E5B55E` | CTAs sobre petróleo |
| `cream` | `#FBF6EC` | `#06181A` | Fundo claro |
| `ink` | `#102A2C` | `#F3EEE3` | Texto |
| `muted` | `#5E7374` | `#A9BCBC` | Texto secundário |

## Tipografia

- **Lora** (serifada): `displayLarge`, `displayMedium`, `headlineLarge`, `headlineMedium`.
- **Inter** (sans): títulos de seção menores, corpo, labels e botões.
- Tamanhos: 34/28/24/20 para títulos; 18/16/14/12 para corpo e labels.
- Pesos: 400, 500, 600, 700 (arquivos locais em `assets/fonts`).

## Espaçamento e formas

- Escala: 4, 8, 12, 16, 24, 32, 48; padding de página 20.
- Raios: 10, 16, 24, pill (999).
- Sombras suaves (`AppShadows.soft`) apenas em cartas e overlays.

## Componentes

| Componente | Arquivo | Uso |
|---|---|---|
| `AppBackground` | `design/components/app_background.dart` | Gradiente + brilho dourado |
| `SectionHeader` | `design/components/section_header.dart` | Título + subtítulo + ação |
| `GoldBadge` | `design/components/gold_badge.dart` | Premium, categorias, demo |
| `SoftCard` | `design/components/soft_card.dart` | Superfícies com borda e sombra |
| `AudioPlayerBar` | `design/components/audio_player_bar.dart` | Player com progresso e seek |

## Telas

- **Onboarding**: três passos, vídeo, dots animados, CTA dourado.
- **Home**: saudação, carta do dia, estatísticas, atalhos, inspiração, destaques e faixa premium.
- **Cartas**: grade de costas de carta, filtros, estado diário, favoritos e leitor fullscreen.
- **Conteúdo**: cards com thumbnail, categorias, selo premium e “em breve”.
- **Contato**: perfil circular, bio expansível, ações sociais em grade.
- **Patrocinadores**: cards com logo, descrição e ações.
- **Assinaturas**: hero premium, benefícios, comparativo, plano e sheet demo.

## Acessibilidade

- Alvos de toque ≥ 48 dp.
- `Semantics` em botões de carta.
- Contraste AA nos textos principais.
- Escala de texto suportada; layouts usam `Flexible`/`Wrap`/scroll.
- Tema do sistema por padrão; escolha manual em Configurações.
