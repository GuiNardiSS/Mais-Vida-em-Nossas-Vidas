import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'services/notifications.dart';

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
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF0a4b51),
          onPrimary: Colors.white,
          secondary: const Color(0xFFa5852e),
          onSecondary: Colors.white,
          // background: const Color(0xFFa99045),
          // onBackground: Colors.white,
          surface: const Color(0xFF0b4c52),
          onSurface: Colors.white,
          error: Colors.red,
          onError: Colors.white,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0a4b51),
          foregroundColor: Colors.white,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF0a4b51),
        ),
      ),
      home: const HomePage(),
    );
  }
}
