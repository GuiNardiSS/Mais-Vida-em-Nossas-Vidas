import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app_flutter/core/assets/asset_resolver.dart';

void main() {
  AssetResolver resolverWith(Set<String> assets) {
    return AssetResolver(assetLister: () async => assets);
  }

  group('AssetResolver.resolveCardBack', () {
    test('encontra o nome no formato usado pelos assets atuais', () async {
      final resolver = resolverWith({
        'assets/cartas_do_dia/Back (1).png',
        'assets/cartas_do_dia/Back (2).png',
      });

      expect(
        await resolver.resolveCardBack('assets/cartas_do_dia', 0),
        'assets/cartas_do_dia/Back (1).png',
      );
      expect(
        await resolver.resolveCardBack('assets/cartas_do_dia', 1),
        'assets/cartas_do_dia/Back (2).png',
      );
    });

    test('aceita variantes sem espaço ou com extensão maiúscula', () async {
      final resolver = resolverWith({
        'assets/cartas/Back(3).PNG',
      });

      expect(
        await resolver.resolveCardBack('assets/cartas', 2),
        'assets/cartas/Back(3).PNG',
      );
    });

    test('não confunde a carta 1 com a carta 10', () async {
      final resolver = resolverWith({
        'assets/cartas/Back (10).png',
      });

      expect(await resolver.resolveCardBack('assets/cartas', 0), isNull);
      expect(
        await resolver.resolveCardBack('assets/cartas', 9),
        'assets/cartas/Back (10).png',
      );
    });

    test('retorna null quando a imagem não existe', () async {
      final resolver = resolverWith({'assets/cartas/Back (1).png'});

      expect(await resolver.resolveCardBack('assets/cartas', 49), isNull);
    });
  });

  group('AssetResolver.resolveAudio', () {
    test('prefere carta_N.mp3', () async {
      final resolver = resolverWith({
        'assets/audios/carta_1.mp3',
        'assets/audios/carta_01.mp3',
      });

      expect(
        await resolver.resolveAudio('assets/audios', 0),
        'assets/audios/carta_1.mp3',
      );
    });

    test('aceita número com zero à esquerda', () async {
      final resolver = resolverWith({'assets/audios/carta_07.mp3'});

      expect(
        await resolver.resolveAudio('assets/audios', 6),
        'assets/audios/carta_07.mp3',
      );
    });

    test('aceita outros formatos quando não há mp3', () async {
      final resolver = resolverWith({'assets/audios/audio_5.m4a'});

      expect(
        await resolver.resolveAudio('assets/audios', 4),
        'assets/audios/audio_5.m4a',
      );
    });

    test('retorna null quando não há áudio para a carta', () async {
      final resolver = resolverWith({'assets/audios/carta_1.mp3'});

      expect(await resolver.resolveAudio('assets/audios', 49), isNull);
    });
  });
}
