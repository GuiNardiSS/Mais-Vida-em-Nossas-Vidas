import 'package:flutter/material.dart';
import '../services/app_logger.dart';

/// Observer para rastreamento automático de navegação entre páginas
///
/// Registra automaticamente:
/// - Quando o usuário entra em uma página
/// - Quando o usuário sai de uma página
/// - Tempo de permanência em cada página
class LoggingNavigatorObserver extends NavigatorObserver {
  final Map<Route, DateTime> _routeStartTimes = {};
  final Map<Route, String> _routeNames = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route, 'push', previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRoute(route, 'pop', previousRoute);
    _logRouteExit(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _logRouteExit(oldRoute);
    }
    if (newRoute != null) {
      _trackRoute(newRoute, 'replace', oldRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logRouteExit(route);
  }

  void _trackRoute(Route route, String action, Route? previousRoute) {
    final routeName = _getRouteName(route);
    final previousRouteName =
        previousRoute != null ? _getRouteName(previousRoute) : null;

    // Registra início da visualização da página
    _routeStartTimes[route] = DateTime.now();
    _routeNames[route] = routeName;

    // Log da navegação
    appLogger.logPageView(routeName, data: {
      'action': action,
      'from': previousRouteName,
      'timestamp': DateTime.now().toIso8601String(),
    });

    appLogger.debug('Navegação: $action -> $routeName', data: {
      'from': previousRouteName,
      'route_type': route.runtimeType.toString(),
    });
  }

  void _logRouteExit(Route route) {
    final routeName = _routeNames[route];
    final startTime = _routeStartTimes[route];

    if (routeName != null && startTime != null) {
      final duration = DateTime.now().difference(startTime);

      appLogger.logPerformance('Page Duration: $routeName', duration, data: {
        'page': routeName,
        'duration_seconds': duration.inSeconds,
      });

      // Limpa do cache
      _routeStartTimes.remove(route);
      _routeNames.remove(route);
    }
  }

  String _getRouteName(Route route) {
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      return route.settings.name!;
    }
    return route.runtimeType.toString();
  }
}
