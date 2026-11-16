# Instruções de Build Seguro e Obfuscação

Para garantir a segurança do código em produção, siga estas instruções ao gerar os builds finais.

## 1. Android (APK/App Bundle)

Para gerar um App Bundle (recomendado para Play Store) com obfuscação de código:

```bash
flutter build appbundle --obfuscate --split-debug-info=./build/app/outputs/symbols
```

Para gerar um APK:

```bash
flutter build apk --obfuscate --split-debug-info=./build/app/outputs/symbols
```

**Nota:** A flag `--obfuscate` torna o código Dart ilegível para engenharia reversa. A flag `--split-debug-info` salva os símbolos de debug em uma pasta separada, o que é necessário para decifrar stack traces de erros (crashlytics) posteriormente.

## 2. iOS (IPA)

Para gerar o arquivo para iOS com obfuscação:

```bash
flutter build ipa --obfuscate --split-debug-info=./build/ios/outputs/symbols
```

## 3. Verificações de Segurança

Antes de publicar:

1.  **HTTPS**: Certifique-se de que a URL de produção em `lib/config/api_config.dart` usa `https://`.
2.  **Logs**: Desative logs de debug em produção (o `AppLogger` já faz isso verificando `kDebugMode`, mas revise se não há `print()` soltos).
3.  **Chaves**: Verifique se não há chaves de API sensíveis hardcoded no código. Use variáveis de ambiente ou o `SecureStorageService` se precisar persistir tokens.

## 4. Assinatura do App

Mantenha seus arquivos de keystore (Android) e certificados (iOS) em local seguro e **nunca** comite-os no repositório git.
