import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/assets/asset_resolver.dart';

/// Widget para exibir uma logo que se adapta ao tema (claro/escuro),
/// preferindo SVG (se existir) e caindo para PNG automaticamente.
/// - baseName: ex. 'assets/logo_carta_dia'
///   Busca nesta ordem:
///   - assets/logo_carta_dia_dark.svg (quando tema escuro)
///   - assets/logo_carta_dia.svg
///   - assets/logo_carta_dia_dark.png (quando tema escuro)
///   - assets/logo_carta_dia.png
class ThemedLogo extends StatelessWidget {
  final String baseName;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final double? scale; // escala opcional para compensar bordas

  const ThemedLogo({
    super.key,
    required this.baseName,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.scale,
  });

  static final AssetResolver _resolver = AssetResolver();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<String?>(
      future: _resolver.resolveFirst(<String>[
        if (isDark) '${baseName}_dark.svg',
        '$baseName.svg',
        if (isDark) '${baseName}_dark.png',
        '$baseName.png',
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        final path = snapshot.data;
        if (path == null) {
          return const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white70),
          );
        }

        Widget child = path.endsWith('.svg')
            ? SvgPicture.asset(
                path,
                fit: fit,
                alignment: alignment,
              )
            : Image.asset(
                path,
                fit: fit,
                alignment: alignment,
                filterQuality: FilterQuality.medium,
                cacheWidth: 500,
              );

        if (scale != null && scale != 1.0) {
          child = Transform.scale(scale: scale!, child: child);
        }

        return child;
      },
    );
  }
}
