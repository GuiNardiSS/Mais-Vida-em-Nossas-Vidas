import 'package:flutter/material.dart';

/// Classe helper para responsividade
class Responsive {
  /// Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  /// Verifica se é mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxWidth;

  /// Verifica se é tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxWidth &&
      MediaQuery.of(context).size.width < tabletMaxWidth;

  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMaxWidth;

  /// Retorna número de colunas baseado no tamanho da tela
  static int getCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  /// Retorna padding horizontal responsivo
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 32;
    return 64;
  }

  /// Retorna tamanho de fonte responsivo
  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.2;
    return baseFontSize * 1.4;
  }

  /// Retorna aspect ratio para cards
  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.7;
    if (isTablet(context)) return 0.75;
    return 0.8;
  }
}
