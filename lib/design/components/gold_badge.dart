import 'package:material_ui/material_ui.dart';
import '../tokens.dart';

/// Selo dourado usado para premium, novidades e categorias.
class GoldBadge extends StatelessWidget {
  const GoldBadge({
    super.key,
    required this.label,
    this.icon,
    this.dark = false,
  });

  final String label;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final background = dark
        ? AppColors.petrol.withValues(alpha: 0.9)
        : AppColors.gold.withValues(alpha: 0.16);
    final foreground = dark ? Colors.white : AppColors.petrol;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
