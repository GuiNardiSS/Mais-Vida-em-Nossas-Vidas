import 'package:flutter/services.dart';

/// Lista os assets disponíveis. Injetável para testes.
typedef AssetLister = Future<Set<String>> Function();

/// Resolve caminhos de assets em tempo de execução.
///
/// Usa a API [AssetManifest] em vez de `AssetManifest.json`, que foi removido
/// das versões modernas do Flutter. Mantém cache dos caminhos já resolvidos.
class AssetResolver {
  AssetResolver({AssetLister? assetLister})
      : _assetLister = assetLister ?? _loadFromBundle;

  final AssetLister _assetLister;
  final Map<String, String?> _pathCache = {};
  Set<String>? _assets;

  static Future<Set<String>> _loadFromBundle() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().toSet();
  }

  Future<Set<String>> assets() async {
    return _assets ??= await _assetLister();
  }

  /// Retorna o primeiro caminho existente da lista, ou `null`.
  Future<String?> resolveFirst(List<String> candidates) async {
    if (candidates.isEmpty) return null;

    final cacheKey = candidates.join('|');
    if (_pathCache.containsKey(cacheKey)) {
      return _pathCache[cacheKey];
    }

    final available = await assets();
    for (final candidate in candidates) {
      if (available.contains(candidate)) {
        _pathCache[cacheKey] = candidate;
        return candidate;
      }
    }

    _pathCache[cacheKey] = null;
    return null;
  }

  /// Resolve a imagem de fundo da carta (`Back (1).png` etc.).
  Future<String?> resolveCardBack(String folder, int index) async {
    final cacheKey = 'card:$folder:$index';
    if (_pathCache.containsKey(cacheKey)) {
      return _pathCache[cacheKey];
    }

    final n = index + 1;
    final direct = await resolveFirst(<String>[
      '$folder/Back ($n).png',
      '$folder/Back($n).png',
      '$folder/Back $n.png',
      '$folder/Back ($n).PNG',
      '$folder/Back($n).PNG',
      '$folder/Back $n.PNG',
      '$folder/Back.png',
    ]);
    if (direct != null) {
      _pathCache[cacheKey] = direct;
      return direct;
    }

    // Varre a pasta para aceitar variações do nome sem confundir 1 com 10.
    final prefix = '$folder/';
    final pattern = RegExp(r'^Back[^0-9]*\(?\s*(\d{1,2})\s*\)?\.(?:png|PNG)$');
    final available = await assets();
    for (final path in available.where((p) => p.startsWith(prefix))) {
      final name = path.substring(prefix.length);
      final match = pattern.firstMatch(name);
      if (match != null && int.tryParse(match.group(1) ?? '') == n) {
        _pathCache[cacheKey] = path;
        return path;
      }
    }

    _pathCache[cacheKey] = null;
    return null;
  }

  /// Resolve o áudio da carta, aceitando diferentes nomes e formatos.
  Future<String?> resolveAudio(String folder, int index) async {
    final cacheKey = 'audio:$folder:$index';
    if (_pathCache.containsKey(cacheKey)) {
      return _pathCache[cacheKey];
    }

    final cardNumber = index + 1;
    final padded = cardNumber.toString().padLeft(2, '0');
    final candidates = <String>[
      '$folder/carta_$cardNumber.mp3',
      '$folder/carta$cardNumber.mp3',
      '$folder/Carta_$cardNumber.mp3',
      '$folder/Carta$cardNumber.mp3',
      '$folder/audio_$cardNumber.mp3',
      '$folder/audio$cardNumber.mp3',
      '$folder/Audio_$cardNumber.mp3',
      '$folder/Audio$cardNumber.mp3',
      '$folder/$cardNumber.mp3',
      '$folder/carta_$padded.mp3',
      '$folder/audio_$padded.mp3',
    ];

    for (final format in const <String>['mp3', 'm4a', 'wav', 'aac']) {
      final candidatesForFormat = format == 'mp3'
          ? candidates
          : <String>[
              '$folder/carta_$cardNumber.$format',
              '$folder/carta$cardNumber.$format',
              '$folder/audio_$cardNumber.$format',
              '$folder/$cardNumber.$format',
            ];
      final match = await resolveFirst(candidatesForFormat);
      if (match != null) {
        _pathCache[cacheKey] = match;
        return match;
      }
    }

    _pathCache[cacheKey] = null;
    return null;
  }
}
