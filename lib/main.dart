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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}