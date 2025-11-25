import 'package:flutter/material.dart';
import 'pages/cartas_intro.dart';
import 'pages/assinaturas.dart';
import 'services/notifications.dart';
import 'services/palette.dart';
import 'services/route_observer.dart';
import 'services/app_logger.dart';
import 'services/logging_navigator_observer.dart';
// Removed unused import of HomePage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa sistema de logging (agora seguro em release)
    await appLogger.initialize();
    appLogger.info('Aplicativo iniciado', data: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    // Se o logger falhar, continua sem ele
    debugPrint('Erro ao inicializar logger: $e');
  }

  try {
    // Inicialize apenas as notificações (NÃO agende notificações exatas automaticamente)
    await NotificationsService.init();
    // await NotificationsService.scheduleEvery3Hours(); // Removido para evitar travamento
  } catch (e) {
    // Se notificações falharem, continua sem elas
    debugPrint('Erro ao inicializar notificações: $e');
  }

  // Registra erro global de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    try {
      appLogger.fatal(
        'Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
        data: {
          'library': details.library ?? 'unknown',
          'context': details.context?.toString() ?? 'no context',
        },
      );
    } catch (e) {
      debugPrint('Erro ao logar: $e');
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mais Vida em Nossas Vidas',
      navigatorObservers: [
        appRouteObserver,
        LoggingNavigatorObserver(), // Observer de logging automático
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          surface: AppColors.accent,
          onSurface: AppColors.logoPrimary,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.scaffold,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.primary,
        ),
        cardTheme: CardThemeData(
          color: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          margin: const EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.logoPrimary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.logoPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.scaffold,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.logoPrimary,
          ),
          contentTextStyle: const TextStyle(fontSize: 15),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.logoPrimary,
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: AppColors.logoGold,
          textColor: AppColors.logoGold,
        ),
      ),
      home: const CartasIntroPage(),
      routes: {
        '/assinaturas': (context) => const AssinaturasPage(),
      },
    );
  }
}
