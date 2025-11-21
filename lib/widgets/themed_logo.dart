import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final candidates = <_AssetCandidate>[
      if (isDark) _AssetCandidate('${baseName}_dark.svg', _AssetType.svg),
      _AssetCandidate('$baseName.svg', _AssetType.svg),
      if (isDark) _AssetCandidate('${baseName}_dark.png', _AssetType.png),
      _AssetCandidate('$baseName.png', _AssetType.png),
    ];

    Widget child = const SizedBox.shrink();

    return FutureBuilder<List<String>>(
      future: _loadAssets(),
      builder: (context, snapshot) {
        final available = snapshot.data ?? const <String>[];
        _AssetCandidate? chosen;
        for (final c in candidates) {
          if (available.contains(c.path)) {
            chosen = c;
            break;
          }
        }

        if (chosen == null) {
          child = const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white70),
          );
        } else if (chosen.type == _AssetType.svg) {
          child = SvgPicture.asset(
            chosen.path,
            fit: fit,
            alignment: alignment,
          );
        } else {
          child = Image.asset(
            chosen.path,
            fit: fit,
            alignment: alignment,
            filterQuality: FilterQuality
                .medium, // Otimização: High é desnecessário para ícones/logos
            cacheWidth: 500, // Otimização: Limita memória usada
          );
        }

        if (scale != null && scale != 1.0) {
          child = Transform.scale(scale: scale!, child: child);
        }

        return child;
      },
    );
  }

  static List<String>? _cachedManifest;

  Future<List<String>> _loadAssets() async {
    if (_cachedManifest != null) return _cachedManifest!;
    // Lê o AssetManifest.json via rootBundle
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);
      _cachedManifest = manifest.keys.cast<String>().toList(growable: false);
      return _cachedManifest!;
    } catch (_) {
      return const <String>[];
    }
  }
}

enum _AssetType { svg, png }

class _AssetCandidate {
  final String path;
  final _AssetType type;
  const _AssetCandidate(this.path, this.type);
}
