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
