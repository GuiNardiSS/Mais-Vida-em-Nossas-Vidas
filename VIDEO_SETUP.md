# 📹 Vídeos na Página "Conheça Mais" - Configuração

## ✅ O que foi implementado

A página "Conheça Mais" (`lib/pages/inicio.dart`) agora exibe **vídeos com narração em português** ao invés de texto quando você clica em cada uma das 10 caixas de informação.

### 🎥 Recursos do Player de Vídeo:
- **Controles personalizados**: Play/pause, barra de progresso, tempo atual/total
- **Interface intuitiva**: Toque na tela para mostrar/esconder controles
- **Sem autoplay**: O usuário decide quando reproduzir o vídeo
- **Responsivo**: Adapta-se ao tamanho da tela
- **Tratamento de erros**: Mostra mensagem amigável se o vídeo não carregar

## 🎬 Como gerar os vídeos automaticamente

### Opção 1: Gerar vídeos com narração (RECOMENDADO)

Um script Python foi criado para gerar automaticamente os 10 vídeos com narração em português do Brasil.

**Passo a passo:**

1. **Instale as dependências Python:**
   ```bash
   pip install moviepy gtts pillow
   ```

2. **Execute o gerador:**
   ```bash
   cd assets/conteudo
   python gerar_videos.py
   ```

3. **Aguarde a geração** (5-10 minutos)

Os vídeos serão gerados automaticamente com:
- ✅ Narração em português do Brasil
- ✅ Texto visual sobre fundo colorido
- ✅ Áudio sincronizado
- ✅ Formato MP4 otimizado

**Veja instruções detalhadas em:** `assets/conteudo/INSTRUCOES_GERAR_VIDEOS.md`

### Opção 2: Vídeos personalizados

Se preferir criar seus próprios vídeos:

1. **Crie/edite vídeos** usando ferramentas como Adobe Premiere, Canva, etc.
2. **Salve como MP4** na pasta `assets/conteudo/`
3. **Nomeie os arquivos** exatamente como:
   - `espiritualidade.mp4`
   - `autoconhecimento.mp4`
   - `gratidao.mp4`
   - `fe.mp4`
   - `resiliencia.mp4`
   - `compaixao.mp4`
   - `proposito.mp4`
   - `equilibrio.mp4`
   - `esperanca.mp4`
   - `amor.mp4`

### Opção 3: Vídeos online (URLs)

Você também pode usar URLs de vídeos hospedados online. Edite `lib/pages/inicio.dart` e substitua:
```dart
'video': 'assets/conteudo/espiritualidade.mp4'
```
Por:
```dart
'video': 'https://seusite.com/espiritualidade.mp4'
```

## 📋 Estrutura atual

Atualmente está usando **vídeos de exemplo do Google** para demonstração. Os 10 tópicos são:

1. **Espiritualidade** - "Descubra o significado da espiritualidade"
2. **Autoconhecimento** - "Aprofunde-se em si mesmo"
3. **Gratidão** - "O poder de agradecer diariamente"
4. **Fé** - "A força da crença interior"
5. **Resiliência** - "Superando obstáculos com equilíbrio"
6. **Compaixão** - "Praticando o cuidado com o próximo"
7. **Propósito** - "Encontre o seu motivo de viver"
8. **Equilíbrio** - "Harmonia entre corpo, mente e espírito"
9. **Esperança** - "Acreditar em dias melhores"
10. **Amor** - "A energia que transforma tudo"

## 📁 Arquivos modificados/criados

- `lib/pages/inicio.dart` - Página principal modificada
- `lib/widgets/video_popup_player.dart` - **NOVO** widget de player customizado

## 🧪 Como testar

1. **Gere os vídeos** (se ainda não gerou):
   ```bash
   cd assets/conteudo
   python gerar_videos.py
   ```

2. **Execute o app:**
   ```bash
   flutter run
   ```

3. **Teste no app:**
   - Vá para **"Conheça Mais"** no menu
   - Toque em qualquer uma das **10 caixas**
   - O popup abrirá com o player de vídeo
   - Toque no **botão play** para iniciar o vídeo com narração
   - Toque na **tela** para mostrar/esconder controles
   - Use a **barra de progresso** para navegar no vídeo
   - Toque no **X** para fechar o popup

## 🎯 Comportamento do Player

- **SEM autoplay**: O vídeo só inicia quando você pressiona play
- **Carregamento lazy**: Vídeo só carrega quando você abre o popup
- **Controles intuitivos**: Toque para mostrar/esconder
- **Performance otimizada**: Sem desperdício de recursos

## 💻 Comandos para testar

```bash
flutter analyze  # Verificar código
flutter run      # Executar app
```