# 📹 GUIA RÁPIDO - Como Adicionar o Vídeo de Boas-Vindas

## 🎯 Passos Simples:

### 1️⃣ Localize o Diretório
```
meu_app_flutter/
└── assets/
    └── intro/          ← Coloque o vídeo aqui
```

### 2️⃣ Renomeie seu Vídeo
**Nome obrigatório:** `video_boas_vindas.mp4`

### 3️⃣ Copie para o Diretório
- Caminho completo: `assets/intro/video_boas_vindas.mp4`

### 4️⃣ Execute o App
```bash
flutter run
```

---

## ✨ Funcionalidades Implementadas:

✅ **Autoplay** - Vídeo inicia automaticamente  
✅ **Loop** - Reproduz continuamente  
✅ **Controle de Som** - Botão mute/unmute (canto superior direito)  
✅ **Play/Pause** - Toque na tela para controlar  
✅ **Responsivo** - Adapta ao tamanho da tela  
✅ **Loading** - Indicador enquanto carrega  
✅ **Tratamento de Erro** - Mensagem amigável se vídeo não existir  

---

## 📐 Especificações Técnicas:

| Item | Recomendação |
|------|--------------|
| **Formato** | MP4 (H.264) |
| **Resolução** | 1280x720 (HD) ou 1920x1080 (Full HD) |
| **Proporção** | 16:9 |
| **FPS** | 30 fps |
| **Bitrate** | 2-5 Mbps |
| **Duração** | 15-60 segundos |
| **Tamanho** | Máximo 10 MB |

---

## 🛠️ Comandos Úteis (PowerShell):

### Copiar vídeo para o diretório:
```powershell
Copy-Item "C:\caminho\do\seu\video.mp4" "assets\intro\video_boas_vindas.mp4"
```

### Verificar se o arquivo está no lugar certo:
```powershell
Test-Path "assets\intro\video_boas_vindas.mp4"
```

### Verificar tamanho do arquivo:
```powershell
Get-Item "assets\intro\video_boas_vindas.mp4" | Select-Object Name, Length
```

---

## 🎨 Prévia da Interface:

```
┌─────────────────────────────────┐
│       Bem-vindo(a)!             │
│  [Texto de descrição]           │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │                         │🔊 │ ← Botão mute/unmute
│  │   📹 VÍDEO AQUI        │   │
│  │   (Toque para pausar)   │   │
│  │                         │   │
│  └─────────────────────────┘   │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │   🃏 Carta Grande       │   │
│  │                         │   │
│  │  "Toque para entrar"    │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

---

## ⚠️ Solução de Problemas:

### Vídeo não aparece?
1. ✅ Confirme o nome: `video_boas_vindas.mp4`
2. ✅ Confirme o caminho: `assets/intro/`
3. ✅ Execute: `flutter clean && flutter pub get`
4. ✅ Recompile: `flutter run`

### Vídeo muito grande?
Use ferramentas de compressão:
- **HandBrake** (gratuito, Windows/Mac/Linux)
- **FFmpeg** (linha de comando)
- **Online:** cloudconvert.com

---

## 📞 Suporte:

Se encontrar problemas, verifique:
- [ ] Nome do arquivo correto
- [ ] Formato MP4 (H.264)
- [ ] Arquivo não corrompido
- [ ] Tamanho razoável (< 10 MB)

**Tudo pronto!** 🚀 Adicione seu vídeo e veja a mágica acontecer! ✨
