import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartasDoDiaPage extends StatefulWidget {
  const CartasDoDiaPage({super.key});

  @override
  State<CartasDoDiaPage> createState() => _CartasDoDiaPageState();
}

class _CartasDoDiaPageState extends State<CartasDoDiaPage>
    with SingleTickerProviderStateMixin {
  final List<String> cartas = List.generate(50, (i) => 'Carta ${i + 1}');
  final List<String> mensagens = List.generate(50,
      (i) => 'Mensagem especial da Carta ${i + 1} para iluminar sua jornada.');
  final List<String> cartasOrganizacao =
      List.generate(50, (i) => 'Carta Org ${i + 1}');
  final List<String> mensagensOrganizacao = List.generate(50,
      (i) => 'Mensagem especial da Carta Org ${i + 1} para sua organização.');

  int? cartaSelecionada;
  int? cartaOrgSelecionada;
  // Mostrar todas as cartas imediatamente
  bool cartasReveladas = true;
  bool cartasOrgReveladas = true;
  late TabController _tabController;
  // Cache de assets e manifest
  Set<String>? _assetSet;
  final Map<int, String?> _cacheDia = {};
  final Map<int, String?> _cacheOrg = {};

  // Persistência diária
  static const _kDiaIndexKey = 'carta_dia_index';
  static const _kDiaDateKey = 'carta_dia_date';
  static const _kOrgIndexKey = 'carta_org_index';
  static const _kOrgDateKey = 'carta_org_date';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initAsync();
  }

  Future<void> _initAsync() async {
    // Carrega manifest uma vez
    await _ensureManifestLoaded();
    // Carrega estado persistido
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final diaDate = prefs.getString(_kDiaDateKey);
    final diaIndex = prefs.getInt(_kDiaIndexKey);
    final orgDate = prefs.getString(_kOrgDateKey);
    final orgIndex = prefs.getInt(_kOrgIndexKey);

    int? diaSel;
    int? orgSel;
    if (diaDate == today && diaIndex != null) {
      diaSel = diaIndex;
    }
    if (orgDate == today && orgIndex != null) {
      orgSel = orgIndex;
    }
    if (!mounted) return;
    setState(() {
      cartaSelecionada = diaSel;
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
    cache[index] = null;
    return null;
  }

  // Métodos antigos removidos; todas as cartas são exibidas diretamente nas abas.

  Future<void> _selecionarCarta(int index) async {
    // Comentado temporariamente para permitir múltiplas seleções durante testes
    // if (cartaSelecionada == null) {
    setState(() {
      cartaSelecionada = index;
    });
    // Persistir seleção para hoje
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDiaIndexKey, index);
    await prefs.setString(_kDiaDateKey, _todayKey());

    final assetPath = await _resolveCartaAssetCached(
        'assets/cartas_do_dia', index, _cacheDia);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(cartas[index]),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: assetPath != null
              ? Image.asset(assetPath, fit: BoxFit.cover)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image_not_supported, size: 48),
                    SizedBox(height: 8),
                    Text(
                        'Imagem da carta não encontrada.\nVerifique os assets.'),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    // } else {
    //   _mostrarBloqueio();
    // }
  }

  Future<void> _selecionarCartaOrg(int index) async {
    // Comentado temporariamente para permitir múltiplas seleções durante testes
    // if (cartaOrgSelecionada == null) {
    setState(() {
      cartaOrgSelecionada = index;
    });
    // Persistir seleção para hoje
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kOrgIndexKey, index);
    await prefs.setString(_kOrgDateKey, _todayKey());

    final assetPath = await _resolveCartaAssetCached(
        'assets/cartas_do_dia_org', index, _cacheOrg);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(cartasOrganizacao[index]),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: assetPath != null
              ? Image.asset(assetPath, fit: BoxFit.cover)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image_not_supported, size: 48),
                    SizedBox(height: 8),
                    Text(
                        'Imagem da carta não encontrada.\nVerifique os assets.'),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    // } else {
    //   _mostrarBloqueio();
    // }
  }

  // Método _mostrarBloqueio removido temporariamente para permitir múltiplas seleções durante testes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartas do Dia'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cartas do Dia'),
            Tab(text: 'Cartas para sua organização'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCartasDia(),
          _buildCartasOrganizacao(),
        ],
      ),
    );
  }

  Widget _buildCartasDia() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Cartas do Dia',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Escolha uma das cartas abaixo para receber uma mensagem especial para o seu dia. Você só pode selecionar uma carta por vez.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              50,
              (i) => Tooltip(
                message: 'Carta ${i + 1}',
                child: Semantics(
                  button: true,
                  label: 'Carta ${i + 1}',
                  enabled: true,
                  child: ElevatedButton(
                    onPressed: () => _selecionarCarta(i),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cartaSelecionada == i
                          ? const Color(0xFF0b4c52)
                          : const Color(0xFFa99045),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    child: Text('Carta ${i + 1}'),
                  ),
                ),
              ),
            ),
          ),
          if (cartaSelecionada != null) ...[
            const SizedBox(height: 16),
            Text(
              'Carta escolhida: Carta ${cartaSelecionada! + 1}. Nova seleção disponível amanhã.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCartasOrganizacao() {
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              50,
              (i) => Tooltip(
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
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    child: Text('Carta Org ${i + 1}'),
                  ),
                ),
              ),
            ),
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
