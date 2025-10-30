import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/themed_logo.dart';
import '../widgets/audio_control_widget.dart';
import '../services/audio_service.dart';

class CartasOrganizacaoPage extends StatefulWidget {
  const CartasOrganizacaoPage({super.key});

  @override
  State<CartasOrganizacaoPage> createState() => _CartasOrganizacaoPageState();
}

class _CartasOrganizacaoPageState extends State<CartasOrganizacaoPage> {
  final List<String> cartasOrganizacao =
      List.generate(50, (i) => 'Carta Org ${i + 1}');

  int? cartaOrgSelecionada;
  bool cartasOrgReveladas = true;

  // Cache de assets e manifest
  Set<String>? _assetSet;
  final Map<int, String?> _cacheOrg = {};

  static const _kOrgIndexKey = 'carta_org_index';
  static const _kOrgDateKey = 'carta_org_date';

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _ensureManifestLoaded();
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final orgDate = prefs.getString(_kOrgDateKey);
    final orgIndex = prefs.getInt(_kOrgIndexKey);

    int? orgSel;
    if (orgDate == today && orgIndex != null) {
      orgSel = orgIndex;
    }
    if (!mounted) return;
    setState(() {
      cartaOrgSelecionada = orgSel;
    });
  }

  String _todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  Future<void> _ensureManifestLoaded() async {
    if (_assetSet != null) return;
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestJson);
    _assetSet = manifest.keys.toSet();
  }

  Future<String?> _resolveCartaAssetCached(
      String folder, int index, Map<int, String?> cache) async {
    if (cache.containsKey(index)) return cache[index];
    await _ensureManifestLoaded();
    final assets = _assetSet ?? {};
    final n = index + 1;
    final candidates = <String>[
      '$folder/Back ($n).png',
      '$folder/Back($n).png',
      '$folder/Back $n.png',
      '$folder/Back ($n).PNG',
      '$folder/Back($n).PNG',
      '$folder/Back $n.PNG',
      '$folder/Back.png',
    ];
    for (final c in candidates) {
      if (assets.contains(c)) {
        cache[index] = c;
        return c;
      }
    }

    final prefix = '$folder/';
    final regex = RegExp(r'^Back[^0-9]*\(?\s*(\d{1,2})\s*\)?\.(?:png|PNG)\$');
    for (final path in assets.where((p) => p.startsWith(prefix))) {
      final name = path.substring(prefix.length);
      final m = regex.firstMatch(name);
      if (m != null) {
        final numStr = m.group(1);
        if (numStr != null && int.tryParse(numStr) == n) {
          cache[index] = path;
          return path;
        }
      }
    }
    cache[index] = null;
    return null;
  }

  Future<void> _selecionarCartaOrg(int index) async {
    setState(() {
      cartaOrgSelecionada = index;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kOrgIndexKey, index);
    await prefs.setString(_kOrgDateKey, _todayKey());

    final assetPath = await _resolveCartaAssetCached(
        'assets/cartas_do_dia_org', index, _cacheOrg);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(20),
                child: assetPath != null
                    ? InteractiveViewer(
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.image_not_supported,
                              size: 48, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Imagem da carta não encontrada.\nVerifique os assets.',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: AudioControlWidget(
                cardIndex: index,
                isOrganizacao: true,
                cardTitle: cartasOrganizacao[index],
                onClose: () {
                  AudioService().stopAudio();
                },
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () {
                  AudioService().stopAudio();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cartasOrganizacao[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Cartas para sua organização',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Escolha uma das cartas abaixo para receber uma mensagem especial para sua organização. Você só pode selecionar uma carta por vez.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final int crossAxisCount =
                  (constraints.maxWidth / 130).floor().clamp(3, 5);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: 50,
                itemBuilder: (context, i) => Tooltip(
                  message: 'Carta Org ${i + 1}',
                  child: Semantics(
                    button: true,
                    label: 'Carta da organização ${i + 1}',
                    enabled: true,
                    child: ElevatedButton(
                      onPressed: () => _selecionarCartaOrg(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cartaOrgSelecionada == i
                            ? const Color(0xFF0b4c52)
                            : const Color(0xFFa99045),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(100, 100),
                      ),
                      child: Stack(
                        children: [
                          // Logo maior e mais visível
                          Positioned(
                            top: 8,
                            left: 8,
                            right: 8,
                            bottom: 40,
                            child: ThemedLogo(
                              baseName: 'assets/logo_carta_org',
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                          // Número da carta centralizado na base
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${i + 1}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (cartaOrgSelecionada != null) ...[
            const SizedBox(height: 16),
            Text(
              'Carta da organização escolhida: ${cartaOrgSelecionada! + 1}. Nova seleção disponível amanhã.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
