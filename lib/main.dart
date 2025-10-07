import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'services/notifications.dart';
import 'services/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialize apenas as notificações (NÃO agende notificações exatas automaticamente)
  await NotificationsService.init();
  // await NotificationsService.scheduleEvery3Hours(); // Removido para evitar travamento

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mais Vida em Nossas Vidas',
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
      home: const HomePage(),
    );
  }
}
