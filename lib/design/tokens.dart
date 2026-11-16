import 'package:material_ui/material_ui.dart';

/// Paleta e medidas da marca Mais Vida em Nossas Vidas.
///
/// A identidade original (petróleo, dourado e creme) é preservada, com uma
/// versão escura pensada para leitura confortável.
abstract final class AppColors {
  // Marca
  static const petrol = Color(0xFF0B4C52);
  static const petrolDeep = Color(0xFF07383D);
  static const petrolSoft = Color(0xFF2E8A8F);
  static const gold = Color(0xFFC9A65A);
  static const goldBright = Color(0xFFE5B55E);
  static const goldSoft = Color(0xFFE8D3A3);
  static const cream = Color(0xFFFBF6EC);
  static const creamDeep = Color(0xFFF4EDE0);
  static const ink = Color(0xFF102A2C);
  static const inkMuted = Color(0xFF5E7374);
  static const success = Color(0xFF2E7D5B);
  static const danger = Color(0xFFB3403A);

  // Tema escuro
  static const night = Color(0xFF06181A);
  static const nightSurface = Color(0xFF0B2426);
  static const nightSurfaceHigh = Color(0xFF123034);
  static const nightInk = Color(0xFFF3EEE3);
  static const nightMuted = Color(0xFFA9BCBC);

  // Aliases legados (mantidos para as telas ainda não migradas)
  static const primary = petrol;
  static const secondary = gold;
  static const accent = goldBright;
  static const logoPrimary = petrol;
  static const logoGold = goldBright;
  static const scaffold = cream;
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const page = 20.0;
}

abstract final class AppRadii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 620);
}

abstract final class AppShadows {
  static List<BoxShadow> soft(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
