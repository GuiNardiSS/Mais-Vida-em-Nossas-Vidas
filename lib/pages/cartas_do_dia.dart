import 'package:flutter/material.dart';

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
  bool cartasReveladas = false;
  bool cartasOrgReveladas = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _mostrarCartas() {
    setState(() {
      cartasReveladas = true;
    });
  }

  void _mostrarCartasOrg() {
    setState(() {
      cartasOrgReveladas = true;
    });
  }

  void _selecionarCarta(int index) {
    if (cartaSelecionada == null) {
      setState(() {
        cartaSelecionada = index;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(cartas[index]),
          content: SizedBox(
            width: 250,
            child: Image.asset(
              'assets/cartas_do_dia/Back (${index + 1}).png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text('Imagem não encontrada'),
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
    } else {
      _mostrarBloqueio();
    }
  }

  void _selecionarCartaOrg(int index) {
    if (cartaOrgSelecionada == null) {
      setState(() {
        cartaOrgSelecionada = index;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(cartasOrganizacao[index]),
          content: SizedBox(
            width: 250,
            child: Image.asset(
              'assets/cartas_do_dia_org/Back (${index + 1}).png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text('Imagem não encontrada'),
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
    } else {
      _mostrarBloqueio();
    }
  }

  void _mostrarBloqueio() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aviso'),
        content: const Text(
            'Carta do dia utilizada! Volte amanhã e descubra o que a espiritualidade aguarda para você.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 32),
          if (!cartasReveladas)
            ElevatedButton(
              onPressed: _mostrarCartas,
              child: const Text('Mostrar Cartas'),
            ),
          if (cartasReveladas)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                50,
                (i) => ElevatedButton(
                  onPressed: cartaSelecionada == null
                      ? () => _selecionarCarta(i)
                      : () => _mostrarBloqueio(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        cartaSelecionada == i ? Colors.deepPurple : null,
                  ),
                  child: Text('Carta ${i + 1}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartasOrganizacao() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 32),
          if (!cartasOrgReveladas)
            ElevatedButton(
              onPressed: _mostrarCartasOrg,
              child: const Text('Mostrar Cartas'),
            ),
          if (cartasOrgReveladas)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                50,
                (i) => ElevatedButton(
                  onPressed: cartaOrgSelecionada == null
                      ? () => _selecionarCartaOrg(i)
                      : () => _mostrarBloqueio(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        cartaOrgSelecionada == i ? Colors.deepPurple : null,
                  ),
                  child: Text('Carta Org ${i + 1}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
