import 'package:flutter/material.dart';
import 'inicio.dart';
import 'cartas_do_dia.dart';
import 'contato.dart';
import 'conteudo.dart';
import 'espiritualidade_dia.dart';
import 'assinaturas.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pages = const [
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
                title: const Text('Cartas do Dia'),
                onTap: () => _onItemTapped(0)),
            ListTile(
                title: const Text('Conheça Mais'),
                onTap: () => _onItemTapped(1)),
            ListTile(
                title: const Text('Contato'), onTap: () => _onItemTapped(2)),
            ListTile(
                title: const Text('Conteúdo'), onTap: () => _onItemTapped(3)),
            ListTile(
                title: const Text('Espiritualidade no dia a dia'),
                onTap: () => _onItemTapped(4)),
            ListTile(
                title: const Text('Assinaturas'),
                onTap: () => _onItemTapped(5)),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
