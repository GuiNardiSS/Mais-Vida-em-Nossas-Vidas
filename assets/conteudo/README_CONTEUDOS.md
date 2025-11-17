# 📹 Guia de Conteúdos na Tela "Conteúdo"

## 🎯 Visão Geral

A tela de conteúdo agora suporta **3 tipos diferentes** de conteúdo:

1. **🎥 Vídeos Internos** - Vídeos armazenados no app (assets)
2. **📄 Textos Longos** - Artigos/textos exibidos em popup
3. **🔗 Links Externos** - Links para YouTube, Instagram, etc.

---

## 📁 Estrutura de Arquivos

### Localização dos Vídeos:
```
assets/
  conteudo/
    video1.mp4              # Vídeo 1
    video2.mp4              # Vídeo 2
    video3.mp4              # Vídeo 3
    video1_thumb.png        # Miniatura do vídeo 1 (opcional)
    video2_thumb.png        # Miniatura do vídeo 2 (opcional)
    video3_thumb.png        # Miniatura do vídeo 3 (opcional)
    gratidao.png            # Imagem para conteúdo de texto (opcional)
```

---

## 🎥 Como Adicionar Vídeos

### Passo 1: Adicionar arquivo de vídeo

1. Coloque seus arquivos `.mp4` na pasta `assets/conteudo/`
2. Nomeie-os de forma descritiva, ex: `meditacao_guiada.mp4`

### Passo 2: Adicionar miniatura (opcional)

1. Crie uma imagem PNG da capa do vídeo
2. Nomeie como `nome_do_video_thumb.png`
3. Coloque na mesma pasta

### Passo 3: Configurar no código

Edite `lib/pages/conteudo.dart` e adicione no array `conteudos`:

```dart
{
  'titulo': 'Seu Título Aqui',
  'descricao': 'Breve descrição do conteúdo do vídeo',
  'tipo': 'video',
  'videoPath': 'assets/conteudo/seu_video.mp4',
  'imagePath': 'assets/conteudo/seu_video_thumb.png', // Opcional
},
```

---

## 📄 Como Adicionar Textos Longos

### Configurar no código

Adicione no array `conteudos`:

```dart
{
  'titulo': 'Título do Artigo',
  'descricao': 'Breve resumo do artigo',
  'tipo': 'text',
  'textoCompleto': '''
Aqui vai todo o texto do seu artigo.

Você pode usar múltiplas linhas,
parágrafos, e formatação básica.

Use emojis: 💫 🙏 ✨

Lista de itens:
• Item 1
• Item 2
• Item 3

O texto aparecerá em um popup bonito!
''',
  'imagePath': 'assets/conteudo/imagem_artigo.png', // Opcional
},
```

---

## 🔗 Como Adicionar Links Externos

### Configurar no código

Adicione no array `conteudos`:

```dart
{
  'titulo': 'Nome do Link',
  'descricao': 'Descrição do conteúdo externo',
  'tipo': 'link',
  'youtube': 'https://youtube.com/@seu_canal',
  'instagram': 'https://instagram.com/seu_perfil',
  'imagePath': null, // Ou caminho para imagem
},
```

---

## 🎨 Personalização Visual

### Cores por Tipo:
- **Vídeo**: Vermelho (#FF0000)
- **Texto**: Azul Escuro (#0b4c52)
- **Link**: Azul Escuro (#0b4c52)

### Ícones por Tipo:
- **Vídeo**: `play_circle_filled`
- **Texto**: `article`
- **Link**: `link`

---

## 📝 Exemplo Completo

```dart
conteudos = [
  // VÍDEO
  {
    'titulo': 'Meditação para Iniciantes',
    'descricao': 'Aprenda os fundamentos da meditação com este vídeo guiado.',
    'tipo': 'video',
    'videoPath': 'assets/conteudo/meditacao_iniciantes.mp4',
    'imagePath': 'assets/conteudo/meditacao_thumb.png',
  },
  
  // TEXTO
  {
    'titulo': 'O Poder da Gratidão',
    'descricao': 'Descubra como a gratidão transforma vidas.',
    'tipo': 'text',
    'textoCompleto': '''
A gratidão é uma das práticas mais poderosas...
[seu texto completo aqui]
''',
    'imagePath': 'assets/conteudo/gratidao.png',
  },
  
  // LINK
  {
    'titulo': 'Nosso Canal no YouTube',
    'descricao': 'Visite nosso canal para mais conteúdos.',
    'tipo': 'link',
    'youtube': 'https://youtube.com/@maisvidaemnossasvidas',
    'instagram': 'https://instagram.com/maisvidaemnossasvidas',
    'imagePath': 'assets/conteudo/canal_thumb.png',
  },
];
```

---

## 🎬 Player de Vídeo

### Funcionalidades:
- ✅ Play/Pause
- ✅ Barra de progresso
- ✅ Tempo atual/total
- ✅ Tela cheia
- ✅ Controles personalizados
- ✅ Toque para mostrar/esconder controles

### Controles:
- **Toque na tela**: Mostra/esconde controles
- **Botão Play**: Inicia/pausa vídeo
- **Barra de progresso**: Arraste para navegar
- **Botão X**: Fecha o player

---

## 📄 Popup de Texto

### Funcionalidades:
- ✅ Scroll automático
- ✅ Cabeçalho colorido
- ✅ Formatação de texto
- ✅ Suporte a emojis
- ✅ Botão fechar

---

## ⚙️ Configurações Técnicas

### Formatos de Vídeo Suportados:
- **Recomendado**: MP4 (H.264)
- **Alternativo**: MOV, WebM

### Tamanho Recomendado:
- **Vídeos**: Máximo 50MB por vídeo
- **Miniaturas**: 800x450px (16:9)
- **Formato**: PNG ou JPG

### Performance:
- Vídeos grandes aumentam o tamanho do app
- Considere hospedar vídeos online se forem muito grandes
- Use compressão de vídeo (Handbrake, FFmpeg)

---

## 🔧 Comandos Úteis

### Adicionar vídeo aos assets:

1. Copie o vídeo para `assets/conteudo/`
2. O `pubspec.yaml` já está configurado com:
   ```yaml
   assets:
     - assets/conteudo/
   ```

### Comprimir vídeo (FFmpeg):
```bash
ffmpeg -i input.mp4 -vcodec h264 -acodec aac -b:v 1M output.mp4
```

### Criar miniatura do vídeo:
```bash
ffmpeg -i video.mp4 -ss 00:00:03 -frames:v 1 thumb.png
```

---

## 🐛 Troubleshooting

### Vídeo não carrega:
1. Verifique se o caminho está correto
2. Confirme que o arquivo está em `assets/conteudo/`
3. Execute `flutter clean` e `flutter pub get`
4. Reconstrua o app

### Miniatura não aparece:
- Miniatura é opcional
- Se não houver, aparece ícone placeholder colorido

### Texto muito longo:
- Use scroll automático (já implementado)
- Divida em múltiplos artigos se necessário

---

## 📊 Estatísticas

- **3 vídeos** configurados por padrão
- **1 artigo de texto** como exemplo
- **3 links externos** mantidos
- **Total**: 7 conteúdos pré-configurados

---

## 🚀 Próximas Melhorias Sugeridas

1. Admin panel para adicionar conteúdos via UI
2. Download de vídeos para offline
3. Favoritos de conteúdo
4. Compartilhamento social
5. Analytics de visualizações
6. Busca de conteúdos
7. Categorias/tags

---

*Documentação atualizada - 10/11/2025*
