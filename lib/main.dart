import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'design/app_theme.dart';
import 'features/settings/theme_controller.dart';
import 'pages/cartas_intro.dart';
import 'pages/assinaturas.dart';
import 'services/app_logger.dart';
import 'services/logging_navigator_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };

  runZonedGuarded(
    () => runApp(const ProviderScope(child: MyApp())),
    (error, stack) {
      debugPrint('Uncaught error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );

  // Logging é opcional e nunca deve impedir a abertura do app.
  AppLogger().initialize();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Mais Vida em Nossas Vidas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const CartasIntroPage(),
      routes: {
        '/assinaturas': (context) => const AssinaturasPage(),
      },
      navigatorObservers: [LoggingNavigatorObserver()],
      builder: (context, child) {
        ErrorWidget.builder = (details) => const _FriendlyError();
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

class _FriendlyError extends StatelessWidget {
  const _FriendlyError();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: theme.colorScheme.secondary,
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                'Algo saiu do compasso.',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Feche e abra o aplicativo para tentar novamente.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
