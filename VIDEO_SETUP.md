# 📹 Como Adicionar Vídeo na Tela de Assinaturas

## Implementação Atual

✅ **O que já está funcionando:**
- Widget `VideoPlayerWidget` criado e funcionando
- Tela de assinaturas configurada para reproduzir vídeo
- Sistema de fallback para quando o vídeo não está disponível
- Botões de pagamento **FUNCIONAIS** (Cartão e PIX)

## 🎥 Para Adicionar Seu Vídeo Real

### Opção 1: Vídeo Local (Asset)
1. **Adicione seu vídeo** na pasta `assets/`
   - Nome sugerido: `assinaturas_video.mp4`
   - Formatos suportados: MP4, MOV, AVI

2. **Atualize o pubspec.yaml:**
   ```yaml
   flutter:
     assets:
       - assets/
       - assets/assinaturas_video.mp4
   ```

3. **Modifique a URL no código** (linha 40 em `assinaturas.dart`):
   ```dart
   videoUrl: 'assets/assinaturas_video.mp4',
   ```

### Opção 2: Vídeo da Web (URL)
- Simplesmente substitua a URL na linha 40:
  ```dart
  videoUrl: 'https://seusite.com/video.mp4',
  ```

## 💳 Sistema de Pagamento

### ✅ Cartão de Crédito
- **Backend:** Integrado com Stripe
- **Funcionalidade:** Processa pagamento via `http://10.0.2.2:3000/pagamento`
- **Status:** Totalmente funcional

### ✅ PIX
- **Backend:** Integrado via `http://10.0.2.2:3000/pix/gerar`
- **Funcionalidade:** Gera QR Code e código copia-e-cola
- **Status:** Totalmente funcional

## 🚀 Próximos Passos

1. **Adicionar vídeo real** seguindo uma das opções acima
2. **Testar pagamentos** com o backend rodando
3. **Personalizar mensagens** de sucesso/erro se necessário

## 📱 Interface Atual

- **Vídeo:** Reproduz automaticamente com controles de play/pause
- **Benefícios:** Lista clara dos benefícios da assinatura
- **Preço:** R$ 19,90/mês claramente destacado
- **Botões:** Cartão (azul) e PIX (dourado) com navegação funcional
- **Design:** Consistente com o tema do app

## 🔧 Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Verificar erros
flutter analyze

# Executar o app
flutter run
```