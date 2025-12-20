import 'package:flutter/material.dart';
import 'dart:async';
import 'pages/cartas_intro.dart';
import 'pages/assinaturas.dart';
import 'services/palette.dart';
import 'services/logging_navigator_observer.dart';

Future<void> main() async {
  // PROTEÇÃO ABSOLUTA CONTRA CRASH - Baseado na documentação oficial do Flutter
  runZonedGuarded(
    () async {
      // Passo 1: Inicialização mínima do Flutter (OBRIGATÓRIO e NUNCA falha)
      WidgetsFlutterBinding.ensureInitialized();

      // Passo 2: Handler de erros Flutter (proteção contra crashes visuais)
      FlutterError.onError = (details) {
        // Log detalhado para debug
        debugPrint('═══════════════════════════════════════');
        debugPrint('🔴 FLUTTER ERROR CAPTURADO:');
        debugPrint('Exception: ${details.exception}');
        debugPrint('Library: ${details.library}');
        debugPrint('Context: ${details.context}');
        debugPrint('Stack trace:');
        debugPrint(details.stack.toString());
        debugPrint('═══════════════════════════════════════');
      };

      // Passo 3: INICIA O APP IMEDIATAMENTE (não espera NADA)
      // Esta é a chave: o app abre a tela primeiro, inicializa depois
      runApp(const MyApp());

      // Passo 4: Inicializa serviços em background (não bloqueia abertura)
      _initializeServicesInBackground();
    },
    (error, stack) {
      // Captura qualquer erro que escape do runApp
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔴 UNCAUGHT ERROR:');
      debugPrint('Error: $error');
      debugPrint('Type: ${error.runtimeType}');
      debugPrint('Stack trace:');
      debugPrint(stack.toString());
      debugPrint('═══════════════════════════════════════');
    },
  );
}

/// Inicializa serviços em background SEM bloquear a UI do app
/// Isso garante que o app abre PRIMEIRO, e só depois carrega os serviços
void _initializeServicesInBackground() {
  // Usa microtask para não bloquear o frame atual
  Future.microtask(() async {
    try {
      // Delay mínimo para garantir que o primeiro frame foi renderizado
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('✅ App inicializado com sucesso');
    } catch (e, stack) {
      // NUNCA deixa o erro subir - apenas loga
      debugPrint(
          '⚠️ Erro ao inicializar serviços (app continua funcionando): $e');
      debugPrint('Stack: $stack');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mais Vida em Nossas Vidas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ),
      // Rota inicial sempre mostra a intro
      home: const CartasIntroPage(),
      // Rotas nomeadas para navegação
      routes: {
        '/assinaturas': (context) => const AssinaturasPage(),
      },
      // Observers para logging (não afetam funcionamento se falharem)
      navigatorObservers: [
        LoggingNavigatorObserver(),
      ],
      // Builder com proteção contra erros
      builder: (context, child) {
        // Proteção contra erros no build
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ops! Algo deu errado.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Erro: ${details.exception}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
