import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_service.dart';
import 'app_logger.dart';

/// Serviço para gerenciar restrições de uso entre usuários gratuitos e premium
class UsageRestrictionService {
  // FLAG DE ATIVAÇÃO DO SISTEMA DE RESTRIÇÕES
  // Altere para true quando quiser ativar as restrições de free/premium
  static const bool restricoesAtivas = false;
  // Keys para SharedPreferences
  static const String _cartasDiaUsedKey = 'cartas_dia_used_count';
  static const String _cartasDiaDateKey = 'cartas_dia_date';
  static const String _cartasOrgUsedKey = 'cartas_org_used_count';
  static const String _cartasOrgDateKey = 'cartas_org_date';

  // Limites para usuários gratuitos
  static const int _freeUserDailyLimit = 1; // 1 carta por dia

  /// Verifica se o usuário pode selecionar mais cartas hoje (Cartas do Dia)
  static Future<bool> canSelectCartaDia() async {
    // Se restrições estão desabilitadas, sempre permite
    if (!restricoesAtivas) return true;

    final isPremium = await SubscriptionService.isPremium();

    // Premium pode selecionar quantas quiser
    if (isPremium) {
      appLogger.debug('Usuário premium: sem limite de cartas do dia');
      return true;
    }

    // Usuário gratuito: verifica limite diário
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final lastDate = prefs.getString(_cartasDiaDateKey);
    final usedCount = prefs.getInt(_cartasDiaUsedKey) ?? 0;

    // Se mudou o dia, reseta o contador
    if (lastDate != today) {
      await _resetDailyUsage(prefs, _cartasDiaUsedKey, _cartasDiaDateKey);
      appLogger.info('Novo dia: limite de cartas do dia resetado');
      return true;
    }

    // Verifica se atingiu o limite
    final canUse = usedCount < _freeUserDailyLimit;

    if (!canUse) {
      appLogger.info('Usuário gratuito atingiu limite diário de cartas do dia',
          data: {
            'usedCount': usedCount,
            'limit': _freeUserDailyLimit,
          });
    }

    return canUse;
  }

  /// Verifica se o usuário pode selecionar mais cartas hoje (Cartas de Organização)
  static Future<bool> canSelectCartaOrganizacao() async {
    // Se restrições estão desabilitadas, sempre permite
    if (!restricoesAtivas) return true;

    final isPremium = await SubscriptionService.isPremium();

    // Premium pode selecionar quantas quiser
    if (isPremium) {
      appLogger.debug('Usuário premium: sem limite de cartas organização');
      return true;
    }

    // Usuário gratuito: verifica limite diário
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final lastDate = prefs.getString(_cartasOrgDateKey);
    final usedCount = prefs.getInt(_cartasOrgUsedKey) ?? 0;

    // Se mudou o dia, reseta o contador
    if (lastDate != today) {
      await _resetDailyUsage(prefs, _cartasOrgUsedKey, _cartasOrgDateKey);
      appLogger.info('Novo dia: limite de cartas organização resetado');
      return true;
    }

    // Verifica se atingiu o limite
    final canUse = usedCount < _freeUserDailyLimit;

    if (!canUse) {
      appLogger.info(
          'Usuário gratuito atingiu limite diário de cartas organização',
          data: {
            'usedCount': usedCount,
            'limit': _freeUserDailyLimit,
          });
    }

    return canUse;
  }

  /// Registra que o usuário selecionou uma carta do dia
  static Future<void> registerCartaDiaUsage() async {
    final isPremium = await SubscriptionService.isPremium();
    if (isPremium) return; // Premium não tem limite, não precisa registrar

    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final usedCount = prefs.getInt(_cartasDiaUsedKey) ?? 0;

    await prefs.setInt(_cartasDiaUsedKey, usedCount + 1);
    await prefs.setString(_cartasDiaDateKey, today);

    appLogger.debug('Uso de carta do dia registrado', data: {
      'usedCount': usedCount + 1,
      'limit': _freeUserDailyLimit,
    });
  }

  /// Registra que o usuário selecionou uma carta de organização
  static Future<void> registerCartaOrganizacaoUsage() async {
    final isPremium = await SubscriptionService.isPremium();
    if (isPremium) return; // Premium não tem limite, não precisa registrar

    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final usedCount = prefs.getInt(_cartasOrgUsedKey) ?? 0;

    await prefs.setInt(_cartasOrgUsedKey, usedCount + 1);
    await prefs.setString(_cartasOrgDateKey, today);

    appLogger.debug('Uso de carta organização registrado', data: {
      'usedCount': usedCount + 1,
      'limit': _freeUserDailyLimit,
    });
  }

  /// Obtém quantas cartas do dia o usuário já usou hoje
  static Future<int> getCartasDiaUsedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final lastDate = prefs.getString(_cartasDiaDateKey);

    if (lastDate != today) return 0;

    return prefs.getInt(_cartasDiaUsedKey) ?? 0;
  }

  /// Obtém quantas cartas de organização o usuário já usou hoje
  static Future<int> getCartasOrganizacaoUsedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final lastDate = prefs.getString(_cartasOrgDateKey);

    if (lastDate != today) return 0;

    return prefs.getInt(_cartasOrgUsedKey) ?? 0;
  }

  /// Verifica se um conteúdo é exclusivo para premium
  static bool isContentPremiumOnly(Map<String, dynamic> content) {
    // Pode adicionar um campo 'premium' no conteúdo
    // Por enquanto, vamos marcar vídeos como gratuitos e alguns textos como premium
    final premiumOnly = content['premiumOnly'] ?? false;

    return premiumOnly == true;
  }

  /// Verifica se o usuário pode acessar um conteúdo específico
  static Future<bool> canAccessContent(Map<String, dynamic> content) async {
    // Se restrições estão desabilitadas, sempre permite
    if (!restricoesAtivas) return true;

    if (!isContentPremiumOnly(content)) {
      return true; // Conteúdo gratuito, todos podem acessar
    }

    final isPremium = await SubscriptionService.isPremium();

    if (!isPremium) {
      appLogger.info('Usuário gratuito tentou acessar conteúdo premium', data: {
        'contentTitle': content['titulo'],
      });
    }

    return isPremium;
  }

  /// Mostra dialog informando sobre limitação e incentivando assinatura
  static Future<void> showPremiumRequiredDialog(BuildContext context,
      {String? feature}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.stars, color: Color(0xFFFFD700), size: 28),
            SizedBox(width: 8),
            Text('Recurso Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature ?? 'Este recurso é exclusivo para assinantes premium.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Com a assinatura premium você terá:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('✨ Cartas ilimitadas por dia'),
            const Text('✨ Acesso a conteúdos exclusivos'),
            const Text('✨ Novos recursos em primeira mão'),
            const SizedBox(height: 16),
            const Text(
              'Assine agora e aproveite todos os benefícios!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF0b4c52),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navega para página de assinaturas
              // Você precisará ajustar isso de acordo com sua navegação
              Navigator.of(context).pushNamed('/assinaturas');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0b4c52),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ver Planos'),
          ),
        ],
      ),
    );
  }

  /// Mostra dialog informando que atingiu limite diário
  static Future<void> showDailyLimitReachedDialog(BuildContext context,
      {bool isCartaDia = true}) {
    final cartaType = isCartaDia ? 'Cartas do Dia' : 'Cartas para Organização';

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF0b4c52), size: 28),
            SizedBox(width: 8),
            Text('Limite Diário Atingido'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você já selecionou sua carta gratuita de $cartaType hoje!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Volte amanhã para selecionar uma nova carta ou assine o plano premium para cartas ilimitadas.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0b4c52).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Benefícios Premium:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('• Cartas ilimitadas por dia'),
                  Text('• Acesso a conteúdos exclusivos'),
                  Text('• Suporte prioritário'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed('/assinaturas');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0b4c52),
              foregroundColor: Colors.white,
            ),
            child: const Text('Assinar Premium'),
          ),
        ],
      ),
    );
  }

  /// Reseta o uso diário (chamado automaticamente quando muda o dia)
  static Future<void> _resetDailyUsage(
    SharedPreferences prefs,
    String countKey,
    String dateKey,
  ) async {
    await prefs.setInt(countKey, 0);
    await prefs.setString(dateKey, _getTodayKey());
  }

  /// Retorna a chave do dia atual (formato: YYYY-MM-DD)
  static String _getTodayKey() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Limpa todos os dados de uso (útil para testes)
  static Future<void> clearUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartasDiaUsedKey);
    await prefs.remove(_cartasDiaDateKey);
    await prefs.remove(_cartasOrgUsedKey);
    await prefs.remove(_cartasOrgDateKey);

    appLogger.info('Dados de uso limpos');
  }

  /// Obtém estatísticas de uso
  static Future<Map<String, dynamic>> getUsageStats() async {
    final isPremium = await SubscriptionService.isPremium();
    final cartasDiaUsed = await getCartasDiaUsedToday();
    final cartasOrgUsed = await getCartasOrganizacaoUsedToday();

    return {
      'isPremium': isPremium,
      'cartasDiaUsed': cartasDiaUsed,
      'cartasDiaLimit': isPremium ? 'ilimitado' : _freeUserDailyLimit,
      'cartasDiaRemaining': isPremium
          ? 'ilimitado'
          : (_freeUserDailyLimit - cartasDiaUsed).clamp(0, _freeUserDailyLimit),
      'cartasOrgUsed': cartasOrgUsed,
      'cartasOrgLimit': isPremium ? 'ilimitado' : _freeUserDailyLimit,
      'cartasOrgRemaining': isPremium
          ? 'ilimitado'
          : (_freeUserDailyLimit - cartasOrgUsed).clamp(0, _freeUserDailyLimit),
    };
  }
}
