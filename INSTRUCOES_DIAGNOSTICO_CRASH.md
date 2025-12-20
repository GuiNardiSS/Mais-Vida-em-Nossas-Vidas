# Instruções para Diagnosticar o Crash

## 1. Fazer Upload do AAB no Google Play Console

O novo AAB está em:
```
meu_app_flutter\build\app\outputs\bundle\release\app-release.aab
```

Versão: **1.0.0+5** (214.6MB)

### Passos:
1. Acesse [Google Play Console](https://play.google.com/console)
2. Vá em **Lançamento → Testes → Testes internos** (ou alpha)
3. Clique em **Criar nova versão**
4. Faça upload do `app-release.aab`
5. Salve e publique

## 2. Instalar e Tentar Abrir o App

Após o upload ser processado (5-15 minutos):

1. Acesse o link de teste no seu celular
2. Instale o app
3. Tente abrir

## 3. Coletar Logs de Crash (CRÍTICO)

### Opção A: Pelo Google Play Console
1. Vá em **Qualidade → Visão Geral das Falhas e ANRs**
2. Aguarde 1-4 horas após o crash
3. Copie o stack trace completo

### Opção B: Via ADB (Imediato)
Conecte seu celular via USB e execute no PowerShell:

```powershell
# 1. Limpar logs antigos
adb logcat -c

# 2. Iniciar captura (deixe rodando)
adb logcat > crash_log.txt

# 3. Em outra janela, abra o app no celular
# (app vai crashar)

# 4. Pare a captura (Ctrl+C no terminal)
# O arquivo crash_log.txt terá os erros
```

### Opção C: Via Android Studio Logcat
1. Conecte celular via USB
2. Abra Android Studio
3. Vá em **View → Tool Windows → Logcat**
4. Abra o app no celular
5. Copie os erros vermelhos

## 4. Informações a Enviar

Após coletar os logs, procure por:
- ✅ **Fatal Exception**: mensagens começando com "FATAL EXCEPTION"
- ✅ **Stack trace**: linhas mostrando `at com.maisvidaemnossasvidas...`
- ✅ **Caused by**: mostra a causa raiz do crash
- ✅ **AndroidRuntime**: erros críticos do Android

## 5. Possíveis Causas (baseado na análise atual)

### Muito Provável:
1. **Permissões em tempo de execução não solicitadas** (READ_EXTERNAL_STORAGE, etc.)
2. **Plugins não inicializados corretamente** (path_provider, shared_preferences)
3. **Arquivos ausentes** (assets não encontrados no release)

### Médio:
4. **ProGuard/R8 removendo código necessário**
5. **Serviços em background sem permissão**

### Menos Provável:
6. Problema de assinatura do keystore
7. Incompatibilidade de versão do Android

## 6. Teste Rápido Alternativo

Para testar localmente (simula release):

```powershell
cd meu_app_flutter

# Instalar diretamente no celular conectado
flutter install --release

# Ver logs em tempo real
adb logcat | Select-String -Pattern "flutter|crash|fatal|exception" -CaseSensitive:$false
```

Isso permite ver o crash IMEDIATAMENTE sem esperar o Play Console.

## 7. Próximos Passos

Com o log de crash em mãos, poderemos:
1. Identificar a linha exata que causa o erro
2. Aplicar correção específica
3. Testar novamente

**SEM o log, estamos "atirando no escuro" tentando adivinhar o problema.**
