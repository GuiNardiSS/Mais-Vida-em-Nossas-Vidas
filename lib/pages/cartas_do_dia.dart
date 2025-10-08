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
      barrierDismissible: true,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        child: Stack(
          children: [
            // Carta preenchendo toda a tela
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
            // Botão de fechar no canto superior direito
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                ),
              ),
            ),
            // Título da carta no canto superior esquerdo
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
                  cartas[index],
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
      barrierDismissible: true,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        child: Stack(
          children: [
            // Carta preenchendo toda a tela
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
            // Botão de fechar no canto superior direito
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                ),
              ),
            ),
            // Título da carta no canto superior esquerdo
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
            Tab(
              icon: Icon(Icons.auto_awesome),
              text: 'Cartas do Dia',
            ),
            Tab(
              icon: Icon(Icons.business_center),
              text: 'Organização',
            ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              // Calcula quantas colunas cabem na tela com botões maiores e mais legíveis
              final int crossAxisCount =
                  (constraints.maxWidth / 110).floor().clamp(3, 6);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                      0.85, // Proporção mais quadrada para mostrar logo melhor
                ),
                itemCount: 50,
                itemBuilder: (context, i) => Tooltip(
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        minimumSize: const Size(80, 80),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/logo_carta_dia.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.auto_awesome,
                                        size: 32, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            flex: 1,
                            child: FittedBox(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
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
          LayoutBuilder(
            builder: (context, constraints) {
              // Calcula quantas colunas cabem na tela com botões maiores e mais legíveis
              final int crossAxisCount =
                  (constraints.maxWidth / 110).floor().clamp(3, 6);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                      0.85, // Proporção mais quadrada para mostrar logo melhor
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        minimumSize: const Size(80, 80),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/logo_carta_org.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.business_center,
                                        size: 32, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            flex: 1,
                            child: FittedBox(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
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
