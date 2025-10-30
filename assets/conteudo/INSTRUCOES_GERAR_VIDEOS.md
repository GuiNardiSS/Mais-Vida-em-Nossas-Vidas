# 🎬 Como Gerar os Vídeos com Narração

Este guia explica como gerar os 10 vídeos com narração em português para a página "Conheça Mais".

## 📋 Pré-requisitos

1. **Python 3.7+** instalado
2. **pip** (gerenciador de pacotes Python)

## 🔧 Instalação das Dependências

Abra o terminal/PowerShell na pasta `assets/conteudo/` e execute:

```bash
pip install moviepy gtts pillow
```

**Dependências:**
- `moviepy`: Biblioteca para criar e editar vídeos
- `gtts`: Google Text-to-Speech (narração em português)
- `pillow`: Manipulação de imagens

## 🚀 Gerar os Vídeos

Na pasta `assets/conteudo/`, execute:

```bash
python gerar_videos.py
```

O script irá:
1. Gerar narração em português do Brasil para cada texto
2. Criar frames visuais com títulos e textos
3. Combinar áudio + visual em vídeos MP4
4. Salvar os 10 vídeos na pasta atual

**Vídeos gerados:**
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

## ⏱️ Tempo Estimado

Cada vídeo leva cerca de 30-60 segundos para ser gerado.
Total: **5-10 minutos** para todos os 10 vídeos.

## 🎨 Personalização

Você pode editar o script `gerar_videos.py` para:
- Mudar cores de fundo
- Ajustar tamanhos de fonte
- Modificar textos
- Alterar resolução (padrão: 1280x720)

## 📱 Integração com o App

Após gerar os vídeos, eles já estarão na pasta correta (`assets/conteudo/`).

**Para usar no app:**
1. Abra `lib/pages/inicio.dart`
2. Substitua as URLs de exemplo pelas locais:

```dart
final List<Map<String, String>> informacoes = const [
  {
    'titulo': 'Espiritualidade',
    'resumo': 'Descubra o significado da espiritualidade.',
    'imagem': 'assets/icone1.png',
    'video': 'assets/conteudo/espiritualidade.mp4'  // ← Usar arquivo local
  },
  // ... repetir para os outros 9
];
```

3. Execute `flutter run` para testar

## ✅ Verificação

Após gerar os vídeos, você deve ter:
```
assets/conteudo/
  ├── espiritualidade.mp4
  ├── autoconhecimento.mp4
  ├── gratidao.mp4
  ├── fe.mp4
  ├── resiliencia.mp4
  ├── compaixao.mp4
  ├── proposito.mp4
  ├── equilibrio.mp4
  ├── esperanca.mp4
  └── amor.mp4
```

## ⚠️ Problemas Comuns

### Erro: "No module named 'moviepy'"
```bash
pip install --upgrade moviepy gtts pillow
```

### Erro de fonte (font)
O script usa fontes do sistema. Se houver erro, ele usará fonte padrão automaticamente.

### Vídeos muito grandes
Os vídeos são otimizados (H.264/AAC). Tamanho esperado: 1-3 MB cada.

## 🎥 Características dos Vídeos

- **Resolução**: 1280x720 (HD)
- **FPS**: 24
- **Codec**: H.264 + AAC
- **Duração**: 10-20 segundos (dependendo do texto)
- **Áudio**: Narração em português do Brasil
- **Visual**: Texto centralizado sobre fundo colorido

## 💡 Dica

Se você quiser usar vídeos de maior qualidade ou com animações mais elaboradas, considere usar ferramentas profissionais como:
- Adobe After Effects
- Canva (modo vídeo)
- Remotion (para desenvolvedores React)

Mas o script fornecido já gera vídeos funcionais e de boa qualidade!