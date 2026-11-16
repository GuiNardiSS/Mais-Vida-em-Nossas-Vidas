import 'package:material_ui/material_ui.dart';
import '../tokens.dart';

/// Fundo padrão do app: gradiente suave com um brilho dourado discreto.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.showGlow = true,
  });

  final Widget child;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = isDark ? AppColors.night : AppColors.cream;
    final bottom = isDark ? const Color(0xFF042022) : const Color(0xFFF7EFDF);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
      ),
      child: Stack(
        children: [
          if (showGlow) ...[
            Positioned(
              top: -120,
              right: -80,
              child: _Glow(
                color: AppColors.gold.withValues(alpha: isDark ? 0.12 : 0.18),
                size: 280,
              ),
            ),
            Positioned(
              top: 220,
              left: -140,
              child: _Glow(
                color: AppColors.petrolSoft
                    .withValues(alpha: isDark ? 0.10 : 0.08),
                size: 320,
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
