# Guia Rápido: Sistema Gratuito vs Premium

## ✅ O que foi implementado

### 1. Serviço de Restrições
- **Arquivo:** `lib/services/usage_restriction_service.dart`
- Gerencia limites de uso diário
- Verifica status de assinatura
- Mostra dialogs informativos

### 2. Documentação Completa
- **Arquivo:** `SISTEMA_RESTRICOES.md`
- Explica toda a lógica do sistema
- Exemplos de código para implementar nas páginas
- Guia de testes

---

## 🎯 Como Funciona

### Usuário Gratuito
- 1 carta do dia por dia
- 1 carta de organização por dia
- Acesso apenas a conteúdos gratuitos
- Limite reseta à meia-noite

### Usuário Premium (Assinante)
- Cartas ilimitadas
- Acesso a todos os conteúdos
- Conteúdos exclusivos

---

## 🔧 Implementação Necessária

### Nas páginas de cartas (cartas_do_dia.dart e cartas_organizacao.dart):

**Adicionar no início do arquivo:**
```dart
import '../services/usage_restriction_service.dart';
```

**Modificar função de seleção de carta:**
```dart
Future<void> _selecionarCarta(int index) async {
  // ADICIONAR ESTA VERIFICAÇÃO:
  final canSelect = await UsageRestrictionService.canSelectCartaDia();
  
  if (!canSelect) {
    await UsageRestrictionService.showDailyLimitReachedDialog(
      context,
      isCartaDia: true, // ou false para organização
    );
    return;
  }
  
  // Código existente de seleção...
  setState(() {
    cartaSelecionada = index;
  });
  
  // ADICIONAR ESTE REGISTRO:
  await UsageRestrictionService.registerCartaDiaUsage();
  
  // Resto do código de salvar preferências...
}
```

### Na página de conteúdo (conteudo.dart):

**Marcar conteúdos premium:**
```dart
{
  'titulo': 'Conteúdo Exclusivo',
  'tipo': 'video',
  'premiumOnly': true, // <-- ADICIONAR ESTE CAMPO
  // outros campos...
}
```

**Verificar acesso antes de abrir:**
```dart
Future<void> _abrirConteudo(Map<String, dynamic> conteudo) async {
  final canAccess = await UsageRestrictionService.canAccessContent(conteudo);
  
  if (!canAccess) {
    await UsageRestrictionService.showPremiumRequiredDialog(context);
    return;
  }
  
  // Abre normalmente...
}
```

---

## 🧪 Como Testar

### Testar modo Gratuito:
```dart
await SubscriptionService.clearSubscription();
await UsageRestrictionService.clearUsageData();
```

### Testar modo Premium:
```dart
await SubscriptionService.activateSubscription(
  transactionId: 'test_123',
  paymentMethod: 'test',
  amount: 29.90,
);
```

---

## 📋 Checklist de Implementação

- [ ] Importar `usage_restriction_service.dart` em `cartas_do_dia.dart`
- [ ] Adicionar verificação `canSelectCartaDia()` antes de seleção
- [ ] Adicionar `registerCartaDiaUsage()` após seleção bem-sucedida
- [ ] Importar `usage_restriction_service.dart` em `cartas_organizacao.dart`
- [ ] Adicionar verificação `canSelectCartaOrganizacao()` antes de seleção
- [ ] Adicionar `registerCartaOrganizacaoUsage()` após seleção
- [ ] Marcar conteúdos exclusivos com `premiumOnly: true` em `conteudo.dart`
- [ ] Adicionar verificação `canAccessContent()` antes de abrir conteúdo
- [ ] Testar fluxo completo como usuário gratuito
- [ ] Testar fluxo completo como usuário premium

---

## 🎨 Extras Opcionais

### Mostrar contador de cartas restantes:
```dart
FutureBuilder(
  future: UsageRestrictionService.getUsageStats(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox();
    final stats = snapshot.data!;
    if (stats['isPremium']) return SizedBox();
    
    return Text('Cartas restantes hoje: ${stats['cartasDiaRemaining']}');
  },
)
```

### Badge "Premium" em conteúdos exclusivos:
```dart
if (UsageRestrictionService.isContentPremiumOnly(conteudo))
  Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Color(0xFFFFD700),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.stars, color: Colors.white),
        Text('PREMIUM', style: TextStyle(color: Colors.white)),
      ],
    ),
  )
```

---

## 📞 Dúvidas?

Consulte o arquivo `SISTEMA_RESTRICOES.md` para documentação completa com mais exemplos e detalhes técnicos.
