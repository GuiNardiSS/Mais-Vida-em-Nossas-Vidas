import 'package:flutter/material.dart';

/// RouteObserver global para permitir que widgets (como players de vídeo)
/// reajam a mudanças de rota (pausar ao navegar para outra tela e retomar ao voltar).
final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();
