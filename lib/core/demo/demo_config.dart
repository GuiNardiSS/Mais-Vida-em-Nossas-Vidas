import 'package:flutter/foundation.dart';

/// Configuração do modo demonstração.
///
/// O app de portfólio não processa cobranças reais. Todo pagamento é simulado
/// e identificado como demonstração na interface. Para desativar, compile com
/// `--dart-define=DEMO_MODE=false`.
const bool kDemoMode = bool.fromEnvironment(
  'DEMO_MODE',
  defaultValue: true,
);

const String kDemoLabel = 'Demonstração';

const double kSubscriptionPrice = 4.99;

const Duration kSubscriptionPeriod = Duration(days: 30);

/// Atalhos apenas para demonstrações web (portfólio/screenshots).
///
/// Ex.: `http://localhost:8080/?skip=1&tab=1`.
bool get demoSkipOnboarding =>
    kIsWeb && Uri.base.queryParameters['skip'] == '1';

int get demoInitialTab {
  if (!kIsWeb) return 0;
  final tab = int.tryParse(Uri.base.queryParameters['tab'] ?? '');
  if (tab == null || tab < 0 || tab > 4) return 0;
  return tab;
}

