import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../design/components/audio_player_bar.dart';
import '../design/tokens.dart';
import '../features/favorites/favorites_repository.dart';

class CardReaderPage extends StatefulWidget {
  const CardReaderPage({
    super.key,
    required this.index,
    required this.isOrganization,
    required this.assetPath,
  });

  final int index;
  final bool isOrganization;
  final String? assetPath;

  @override
  State<CardReaderPage> createState() => _CardReaderPageState();
}

class _CardReaderPageState extends State<CardReaderPage> {
  final GlobalKey _cardKey = GlobalKey();
  bool _favorite = false;
  bool _sharing = false;

  String get _title => widget.isOrganization
      ? 'Carta Org ${widget.index + 1}'
      : 'Carta ${widget.index + 1}';

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final favorites = await FavoritesRepository.load(
      isOrganization: widget.isOrganization,
    );
    if (!mounted) return;
    setState(() => _favorite = favorites.contains(widget.index));
  }

  Future<void> _toggleFavorite() async {
    final added = await FavoritesRepository.toggle(
      isOrganization: widget.isOrganization,
      index: widget.index,
    );
    if (!mounted) return;
    setState(() => _favorite = added);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Carta adicionada aos favoritos.'
              : 'Carta removida dos favoritos.',
        ),
      ),
    );
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    const message =
        'Uma mensagem do Mais Vida em Nossas Vidas para o seu dia. ✨';
    try {
      final file = await _captureCard();
      if (file != null) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: message),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(text: '$_title — $message'),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível compartilhar agora.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<File?> _captureCard() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2.4);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return null;
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/carta_${widget.isOrganization ? 'org' : 'dia'}_${widget.index + 1}.png',
    );
    await file.writeAsBytes(data.buffer.asUint8List());
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(_title),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: 'Favoritar',
            icon: Icon(
              _favorite ? Icons.favorite : Icons.favorite_border,
              color: _favorite ? AppColors.goldBright : Colors.white,
            ),
          ),
          IconButton(
            onPressed: _sharing ? null : _share,
            tooltip: 'Compartilhar',
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: widget.assetPath == null
                    ? const _MissingCard()
                    : RepaintBoundary(
                        key: _cardKey,
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Center(
                            child: Image.asset(
                              widget.assetPath!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AudioPlayerBar(
                cardIndex: widget.index,
                isOrganizacao: widget.isOrganization,
                title: _title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingCard extends StatelessWidget {
  const _MissingCard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined,
              color: Colors.white54, size: 48),
          SizedBox(height: 12),
          Text(
            'Imagem da carta não encontrada.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
