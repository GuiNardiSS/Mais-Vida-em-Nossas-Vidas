# Sistema de Restrições: Gratuito vs Premium

Este documento explica o funcionamento do sistema de diferenciação entre usuários gratuitos e assinantes premium no aplicativo.

---

## 📋 Diferenças entre Versões

### Versão Gratuita

**Limitações:**
- ✅ **1 Carta do Dia por dia** - Pode selecionar apenas 1 carta na seção "Cartas do Dia"
- ✅ **1 Carta de Organização por dia** - Pode selecionar apenas 1 carta na seção "Cartas para Organização"
- ✅ **Acesso a conteúdos gratuitos** - Vídeos e textos marcados como gratuitos
- ❌ **SEM acesso a conteúdos premium** - Conteúdos exclusivos ficam bloqueados

**Resetam diariamente:**
- Os contadores de cartas usadas resetam automaticamente à meia-noite
- No dia seguinte, o usuário pode selecionar novamente 1 carta de cada tipo

### Versão Premium (Assinantes)

**Benefícios:**
- ✨ **Cartas ilimitadas** - Pode selecionar quantas cartas quiser por dia
- ✨ **Acesso total ao conteúdo** - Todos os vídeos, textos e materiais exclusivos
- ✨ **Sem restrições diárias** - Uso livre de todas as funcionalidades
- ✨ **Conteúdos exclusivos** - Acesso a materiais disponíveis apenas para assinantes

---

## 🔧 Implementação Técnica

### Serviço de Restrições

**Arquivo:** `lib/services/usage_restriction_service.dart`

Este serviço gerencia todas as restrições de uso:

```dart
// Verifica se pode selecionar carta
await UsageRestrictionService.canSelectCartaDia();
await UsageRestrictionService.canSelectCartaOrganizacao();

// Registra uso de carta
await UsageRestrictionService.registerCartaDiaUsage();
await UsageRestrictionService.registerCartaOrganizacaoUsage();

// Verifica acesso a conteúdo
await UsageRestrictionService.canAccessContent(conteudo);

// Mostra dialogs de limitação
await UsageRestrictionService.showDailyLimitReachedDialog(context);
await UsageRestrictionService.showPremiumRequiredDialog(context);
```

### Serviço de Assinatura

**Arquivo:** `lib/services/subscription_service.dart`

Gerencia o status da assinatura do usuário:

```dart
// Verifica se é premium
final isPremium = await SubscriptionService.isPremium();

// Obtém status da assinatura
final status = await SubscriptionService.getSubscriptionStatus();
// Retorna: free, active, expired, pending

// Ativa assinatura após pagamento
await SubscriptionService.activateSubscription(
  transactionId: 'xxx',
  paymentMethod: 'pix',
  amount: 29.90,
);
```

---

## 📝 Como Implementar nas Páginas

### 1. Cartas do Dia (cartas_do_dia.dart)

**Antes de permitir seleção de carta:**

```dart
Future<void> _selecionarCarta(int index) async {
  // Verifica se pode selecionar
  final canSelect = await UsageRestrictionService.canSelectCartaDia();
  
  if (!canSelect) {
    // Mostra dialog de limite atingido
    await UsageRestrictionService.showDailyLimitReachedDialog(
      context,
      isCartaDia: true,
    );
    return;
  }
  
  // Permite seleção
  setState(() {
    cartaSelecionada = index;
  });
  
  // Registra o uso
  await UsageRestrictionService.registerCartaDiaUsage();
  
  // Salva no SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('carta_dia_index', index);
  await prefs.setString('carta_dia_date', _todayKey());
}
```

### 2. Cartas para Organização (cartas_organizacao.dart)

**Mesmo padrão:**

```dart
Future<void> _selecionarCartaOrg(int index) async {
  // Verifica se pode selecionar
  final canSelect = await UsageRestrictionService.canSelectCartaOrganizacao();
  
  if (!canSelect) {
    await UsageRestrictionService.showDailyLimitReachedDialog(
      context,
      isCartaDia: false,
    );
    return;
  }
  
  // Permite seleção e registra uso
  setState(() {
    cartaOrgSelecionada = index;
  });
  
  await UsageRestrictionService.registerCartaOrganizacaoUsage();
}
```

### 3. Conteúdo (conteudo.dart)

**Marcando conteúdos como premium:**

```dart
final conteudos = [
  {
    'titulo': 'Vídeo Gratuito',
    'tipo': 'video',
    'premiumOnly': false, // Gratuito
  },
  {
    'titulo': 'Curso Exclusivo Premium',
    'tipo': 'text',
    'premiumOnly': true, // Apenas para assinantes
  },
];
```

**Verificando acesso:**

```dart
Future<void> _abrirConteudo(Map<String, dynamic> conteudo) async {
  // Verifica se pode acessar
  final canAccess = await UsageRestrictionService.canAccessContent(conteudo);
  
  if (!canAccess) {
    await UsageRestrictionService.showPremiumRequiredDialog(
      context,
      feature: 'Este conteúdo é exclusivo para assinantes premium',
    );
    return;
  }
  
  // Abre o conteúdo normalmente
  _showContentDialog(conteudo);
}
```

**Indicando conteúdo premium visualmente:**

```dart
Widget _buildContentCard(Map<String, dynamic> content) {
  final isPremium = UsageRestrictionService.isContentPremiumOnly(content);
  
  return Card(
    child: Stack(
      children: [
        // Conteúdo do card
        
        // Badge Premium
        if (isPremium)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
```

---

## 🎨 Indicadores Visuais

### Badge Premium

Use em cards de conteúdo exclusivo:

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Color(0xFFFFD700), // Dourado
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [
      Icon(Icons.stars, size: 16, color: Colors.white),
      SizedBox(width: 4),
      Text('PREMIUM', style: TextStyle(color: Colors.white)),
    ],
  ),
)
```

### Indicador de Cartas Restantes

Mostre ao usuário gratuito quantas cartas ainda pode usar:

```dart
FutureBuilder<Map<String, dynamic>>(
  future: UsageRestrictionService.getUsageStats(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox();
    
    final stats = snapshot.data!;
    final isPremium = stats['isPremium'];
    
    if (isPremium) return SizedBox();
    
    final remaining = stats['cartasDiaRemaining'];
    
    return Container(
      padding: EdgeInsets.all(8),
      color: Color(0xFF0b4c52).withOpacity(0.1),
      child: Text(
        remaining > 0
          ? 'Você pode selecionar mais $remaining carta(s) hoje'
          : 'Limite diário atingido. Volte amanhã!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF0b4c52),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  },
)
```

---

## 🔄 Fluxo de Uso

### Usuário Gratuito - Primeiro Acesso do Dia

```
1. Abre "Cartas do Dia"
2. Vê indicador: "Você pode selecionar 1 carta hoje"
3. Seleciona uma carta
4. Carta é revelada e registrada
5. Indicador muda: "Limite diário atingido"
6. Tenta selecionar outra carta
7. Dialog aparece: "Você já selecionou sua carta gratuita hoje"
8. Oferece opção de assinar premium
```

### Usuário Premium

```
1. Abre "Cartas do Dia"
2. Sem indicadores de limite
3. Pode selecionar quantas cartas quiser
4. Acesso total a todos os conteúdos
5. Badge "PREMIUM" em conteúdos exclusivos
```

---

## 🧪 Testes

### Testar como Usuário Gratuito

```dart
// Limpa assinatura para testar modo gratuito
await SubscriptionService.clearSubscription();
await UsageRestrictionService.clearUsageData();

// Agora o app está em modo gratuito
```

### Testar como Usuário Premium

```dart
// Ativa assinatura de teste
await SubscriptionService.activateSubscription(
  transactionId: 'test_123',
  paymentMethod: 'test',
  amount: 29.90,
);

// Agora o app está em modo premium
```

### Resetar Limite Diário

```dart
// Limpa contadores de uso
await UsageRestrictionService.clearUsageData();

// Agora pode testar novamente a seleção de cartas
```

---

## 📊 Estatísticas de Uso

Obter informações sobre uso atual:

```dart
final stats = await UsageRestrictionService.getUsageStats();

print(stats);
// {
//   'isPremium': false,
//   'cartasDiaUsed': 1,
//   'cartasDiaLimit': 1,
//   'cartasDiaRemaining': 0,
//   'cartasOrgUsed': 0,
//   'cartasOrgLimit': 1,
//   'cartasOrgRemaining': 1,
// }
```

---

## 🚀 Próximos Passos

### Para Ativar o Sistema:

1. ✅ Importar `usage_restriction_service.dart` nas páginas de cartas
2. ✅ Adicionar verificações antes de permitir seleção de cartas
3. ✅ Registrar uso após seleção bem-sucedida
4. ✅ Marcar conteúdos como `premiumOnly: true` quando aplicável
5. ✅ Adicionar verificação de acesso em conteúdos
6. ✅ Adicionar badges visuais de "PREMIUM"
7. ✅ Testar fluxo completo para ambos tipos de usuário

### Melhorias Futuras:

- [ ] Analytics de uso (quantos usuários gratuitos vs premium)
- [ ] A/B testing de limites (testar 1 vs 2 cartas gratuitas)
- [ ] Notificações push lembrando de usar carta diária
- [ ] Gamificação (streak de dias consecutivos)
- [ ] Trial premium (3 dias grátis de premium)

---

## 📚 Documentação Relacionada

- `INTEGRACAO_CIELO_NFE.md` - Sistema de pagamento e assinaturas
- `lib/services/subscription_service.dart` - Gerenciamento de assinaturas
- `lib/services/usage_restriction_service.dart` - Restrições de uso
- `lib/pages/assinaturas.dart` - Página de planos e assinaturas

---

**Última atualização:** 18/11/2025  
**Versão:** 1.0
