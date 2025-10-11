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
  int _selectedIndex = 0; // Inicia na primeira tela (Cartas do Dia)
  final List<Widget> _pages = [
    const CartasDoDiaPage(),
    const ConhecaMaisPage(),
    const ContatoPage(),
    const ConteudoPage(),
    const EspiritualidadeDiaPage(),
    const AssinaturasPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
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
        title: Text(
          _selectedIndex < items.length ? items[_selectedIndex].title : 'Menu',
        ),
        centerTitle: true,
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
                  color: AppColors.logoPrimary,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.menu,
                            color: AppColors.logoPrimary, size: 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              ...items.map((it) => Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _selectedIndex == it.builderIndex
                          ? AppColors.logoGold.withValues(alpha: 0.2)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: _selectedIndex == it.builderIndex
                          ? Border.all(color: AppColors.logoGold, width: 1)
                          : null,
                    ),
                    child: ListTile(
                      leading: Icon(
                        it.icon,
                        color: _selectedIndex == it.builderIndex
                            ? AppColors.logoGold
                            : Colors.white,
                      ),
                      title: Text(
                        it.title,
                        style: TextStyle(
                          fontWeight: _selectedIndex == it.builderIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedIndex == it.builderIndex
                              ? AppColors.logoGold
                              : Colors.white,
                        ),
                      ),
                      trailing: _selectedIndex == it.builderIndex
                          ? const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.logoGold,
                              size: 16,
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () => _onItemTapped(it.builderIndex),
                    ),
                  )),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
