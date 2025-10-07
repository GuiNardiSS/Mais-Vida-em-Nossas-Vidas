import 'package:flutter/material.dart';
import 'inicio.dart';
import 'cartas_do_dia.dart';
import 'contato.dart';
import 'conteudo.dart';
import 'espiritualidade_dia.dart';
import 'assinaturas.dart';
import '../services/palette.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    CartasDoDiaPage(),
    ConhecaMaisPage(),
    ContatoPage(),
    ConteudoPage(),
    EspiritualidadeDiaPage(),
    AssinaturasPage(),
  ];

  void _onItemTapped(int index) {
    Navigator.pop(context);
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'Cartas do Dia',
        icon: Icons.auto_awesome,
        builderIndex: 0,
      ),
      (
        title: 'Conheça Mais',
        icon: Icons.info_outline,
        builderIndex: 1,
      ),
      (
        title: 'Contato',
        icon: Icons.mail_outline,
        builderIndex: 2,
      ),
      (
        title: 'Conteúdo',
        icon: Icons.article_outlined,
        builderIndex: 3,
      ),
      (
        title: 'Espiritualidade no dia a dia',
        icon: Icons.self_improvement,
        builderIndex: 4,
      ),
      (
        title: 'Assinaturas',
        icon: Icons.credit_card,
        builderIndex: 5,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais Vida em Nossas Vidas'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.logoGold,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.logoPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.logoGold, width: 4),
                      ),
                      child: const Center(
                        child: Icon(Icons.menu,
                            color: AppColors.logoGold, size: 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Menu',
                      style: TextStyle(
                        color: AppColors.logoPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              ...items.map((it) => ListTile(
                    leading: Icon(it.icon),
                    title: Text(it.title),
                    selected: _selectedIndex == it.builderIndex,
                    selectedColor: AppColors.logoGold,
                    selectedTileColor:
                        AppColors.logoGold.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () => _onItemTapped(it.builderIndex),
                  )),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
