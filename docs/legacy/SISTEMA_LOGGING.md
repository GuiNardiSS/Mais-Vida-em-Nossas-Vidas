# Sistema de Logging - Mais Vida em Nossas Vidas

## 📊 Visão Geral

Sistema completo de logging implementado para monitorar:
- Navegação entre páginas
- Transações de pagamento (PIX e Cartão)
- Status de assinaturas
- Performance do aplicativo
- Erros e exceções

## 🎯 Recursos Implementados

### 1. **AppLogger Service** (`lib/services/app_logger.dart`)

Serviço centralizado de logging com múltiplos níveis:

```dart
// Inicialização (já configurado em main.dart)
await appLogger.initialize();

// Níveis de log
appLogger.debug('Mensagem de debug');
appLogger.info('Informação geral');
appLogger.warning('Aviso');
appLogger.error('Erro', error: e, stackTrace: st);
appLogger.fatal('Erro crítico', error: e, stackTrace: st);
```

### 2. **Logging Automático de Navegação**

Observer registrado automaticamente no MaterialApp:

- **Rastreamento automático**: Todas as mudanças de página são registradas
- **Tempo de permanência**: Calcula quanto tempo o usuário fica em cada página
- **Histórico de navegação**: Registra de onde veio e para onde vai

### 3. **Logging de Pagamentos**

Integrado em `PaymentService`:

```dart
// Eventos registrados automaticamente:
- Início de pagamento PIX
- Sucesso/erro na geração de QR Code
- Início de pagamento com cartão
- Sucesso/erro na criação do Payment Intent
- Confirmação de pagamento
- Tempo de processamento
```

### 4. **Logging de Assinaturas**

Integrado em `SubscriptionService`:

```dart
// Eventos registrados:
- Ativação de assinatura
- Validação de assinatura
- Expiração de assinatura
- Limpeza de dados (testes)
```

## 📁 Estrutura de Logs

### Localização dos Arquivos

```
/storage/emulated/0/Android/data/com.example.meu_app_flutter/files/logs/
├── app_2024-01-15.log
├── app_2024-01-16.log
└── app_2024-01-17.log
```

### Formato dos Logs

```
[2024-01-15 14:30:25.123] [INFO] Aplicativo iniciado
[2024-01-15 14:30:26.456] [DEBUG] Navegação: push -> /home
[2024-01-15 14:30:35.789] [INFO] Pagamento PIX iniciado - R$ 29.90
[2024-01-15 14:30:37.012] [INFO] Assinatura ativada - 30 dias
```

### Rotação de Logs

- **Rotação diária**: Novo arquivo criado a cada dia
- **Limite de tamanho**: 5 MB por arquivo
- **Retenção**: 7 dias (arquivos antigos são deletados automaticamente)

## 🔍 Tipos de Logs

### 1. Navegação de Páginas

```dart
// Registrado automaticamente pelo LoggingNavigatorObserver
[INFO] Page View: /assinaturas
  - action: push
  - from: /home
  - timestamp: 2024-01-15T14:30:25.123Z

[PERFORMANCE] Page Duration: /assinaturas - 15.5s
  - page: /assinaturas
  - duration_seconds: 15
```

### 2. Pagamentos

```dart
// PIX
[INFO] Payment: PIX - R$ 29.90 - iniciado
[INFO] Payment: PIX - R$ 29.90 - sucesso
  - qrCodeGenerated: true
  - hasQrText: true
[PERFORMANCE] Geração PIX - 2.3s

// Cartão
[INFO] Payment: Cartão - R$ 29.90 - iniciado
[INFO] Payment: Cartão - R$ 29.90 - sucesso
  - hasClientSecret: true
[PERFORMANCE] Criação Payment Intent - 1.8s
```

### 3. Assinaturas

```dart
[INFO] Subscription: ativada
  - transactionId: txn_123456
  - paymentMethod: pix
  - amount: 29.9
  - expiryDate: 2024-02-15T14:30:25.123Z

[INFO] Subscription: validada
  - isActive: true
  - expiryDate: 2024-02-15T14:30:25.123Z

[INFO] Subscription: expirada
  - isActive: false
```

### 4. Erros e Exceções

```dart
[ERROR] Erro ao gerar pagamento PIX: Connection timeout
  - amount: 29.9
  - stackTrace: [...]

[FATAL] Flutter Error: Exception caught by widgets library
  - library: widgets
  - context: RenderBox was not laid out
  - stackTrace: [...]
```

## 📊 Métodos Especializados

### logPageView()

Registra visualização de página com dados contextuais:

```dart
appLogger.logPageView('/assinaturas', data: {
  'action': 'push',
  'from': '/home',
});
```

### logEvent()

Registra eventos customizados:

```dart
appLogger.logEvent('botao_pix_clicado', data: {
  'valor': 29.90,
  'origem': 'assinaturas',
});
```

### logPayment()

Registra transações de pagamento:

```dart
appLogger.logPayment('PIX', 29.90, 'sucesso', data: {
  'qrCodeGenerated': true,
});
```

### logSubscription()

Registra ações de assinatura:

```dart
appLogger.logSubscription('ativada', data: {
  'transactionId': 'txn_123',
  'paymentMethod': 'pix',
  'amount': 29.90,
});
```

### logPerformance()

Monitora performance de operações:

```dart
final startTime = DateTime.now();
// ... operação ...
final duration = DateTime.now().difference(startTime);
appLogger.logPerformance('Geração PIX', duration);
```

### logNetworkError()

Registra erros de rede:

```dart
appLogger.logNetworkError(
  'POST',
  '/api/payment',
  500,
  error: 'Internal Server Error',
);
```

## 🛠️ Gerenciamento de Logs

### Listar Arquivos de Log

```dart
final logFiles = await appLogger.listLogFiles();
for (var file in logFiles) {
  print('${file.path} - ${file.lengthSync()} bytes');
}
```

### Limpar Logs Antigos

```dart
// Remove logs com mais de 7 dias
await appLogger.cleanOldLogs();
```

### Exportar Logs

```dart
// Exporta para diretório de Downloads
final exportedFile = await appLogger.exportLogs();
if (exportedFile != null) {
  print('Logs exportados para: ${exportedFile.path}');
}
```

## 🔄 Sessões

Cada vez que o app é iniciado, uma nova sessão é criada:

```dart
// Informações da sessão
- sessionId: uuid único
- deviceId: identificador do dispositivo
- startTime: horário de início
- duration: tempo total da sessão
```

## 🌐 Logging Remoto (Opcional)

Configure a URL do backend em `app_logger.dart`:

```dart
static const String? _backendLogsUrl = 'https://seu-backend.com/api/logs';
```

Logs críticos (ERROR e FATAL) podem ser enviados automaticamente para o backend.

## 📱 Integração com Backend

### Endpoint de Logs (Opcional)

Se quiser criar um endpoint para receber logs:

```javascript
// Node.js + Express
app.post('/api/logs', async (req, res) => {
  const { level, message, data, sessionId, deviceId } = req.body;
  
  // Salvar no MongoDB
  await Log.create({
    level,
    message,
    data,
    sessionId,
    deviceId,
    timestamp: new Date(),
  });
  
  res.status(200).json({ success: true });
});
```

## 🎨 Visualização dos Logs

### Console (Debug)

Logs aparecem coloridos no console durante desenvolvimento:

- 🐛 DEBUG - Cinza
- ℹ️ INFO - Azul
- ⚠️ WARNING - Amarelo
- ❌ ERROR - Vermelho
- 💀 FATAL - Vermelho escuro

### Arquivo

Todos os logs são salvos em arquivos `.log` no dispositivo.

### Dashboard (Futuro)

Pode-se criar uma tela no app para visualizar logs:

```dart
// Exemplo de UI para visualizar logs
class LogViewerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>>(
      future: appLogger.listLogFiles(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final file = snapshot.data![index];
              return ListTile(
                title: Text(basename(file.path)),
                subtitle: Text('${file.lengthSync()} bytes'),
                onTap: () => _showLogContent(file),
              );
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## 🔐 Privacidade

### Dados Sensíveis

O sistema **NÃO** registra:
- Números de cartão completos
- Senhas
- Dados pessoais completos

### Device ID

O Device ID é parcialmente ocultado nos logs públicos:
```
deviceId: abc12345... (8 primeiros caracteres)
```

## 📈 Análise de Dados

### KPIs que podem ser extraídos:

1. **Navegação**
   - Páginas mais visitadas
   - Tempo médio por página
   - Fluxo de navegação comum

2. **Pagamentos**
   - Taxa de sucesso PIX vs Cartão
   - Tempo médio de processamento
   - Horários de pico de pagamentos

3. **Assinaturas**
   - Taxa de conversão
   - Taxa de renovação
   - Churn rate

4. **Performance**
   - Operações mais lentas
   - Tempos de resposta da API
   - Crashes e erros frequentes

## 🚀 Próximos Passos

1. **Dashboard Web**: Interface web para visualizar logs em tempo real
2. **Alertas**: Notificações automáticas para erros críticos
3. **Analytics**: Integração com Google Analytics ou Firebase
4. **Crash Reporting**: Integração com Sentry ou Crashlytics
5. **A/B Testing**: Logging de experimentos e conversões

## 🆘 Troubleshooting

### Logs não estão sendo salvos

Verifique permissões de armazenamento:

```dart
// AndroidManifest.xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### Arquivos de log muito grandes

Ajuste o tamanho máximo em `app_logger.dart`:

```dart
static const int _maxFileSize = 5 * 1024 * 1024; // 5 MB
```

### Logs não aparecem no console

Certifique-se de estar em modo debug:

```dart
if (kDebugMode) {
  _logger.log(level, message);
}
```

## 📞 Suporte

Para problemas ou dúvidas sobre o sistema de logging:

1. Verifique os logs em `lib/services/app_logger.dart`
2. Execute `flutter pub get` para garantir que todas as dependências estão instaladas
3. Verifique se `appLogger.initialize()` foi chamado em `main.dart`

---

**Sistema de Logging v1.0**  
Implementado em: Janeiro 2024  
Última atualização: Janeiro 2024
