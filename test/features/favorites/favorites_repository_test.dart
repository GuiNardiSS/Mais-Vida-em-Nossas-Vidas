import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meu_app_flutter/features/favorites/favorites_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesRepository', () {
    test('começa vazio', () async {
      expect(
        await FavoritesRepository.load(isOrganization: false),
        isEmpty,
      );
    });

    test('adiciona e remove uma carta favorita', () async {
      final added = await FavoritesRepository.toggle(
        isOrganization: false,
        index: 4,
      );
      expect(added, isTrue);
      expect(
        await FavoritesRepository.load(isOrganization: false),
        equals({4}),
      );

      final removed = await FavoritesRepository.toggle(
        isOrganization: false,
        index: 4,
      );
      expect(removed, isFalse);
      expect(
        await FavoritesRepository.load(isOrganization: false),
        isEmpty,
      );
    });

    test('mantém listas separadas para dia e organização', () async {
      await FavoritesRepository.toggle(isOrganization: false, index: 1);
      await FavoritesRepository.toggle(isOrganization: true, index: 9);

      expect(
        await FavoritesRepository.load(isOrganization: false),
        equals({1}),
      );
      expect(
        await FavoritesRepository.load(isOrganization: true),
        equals({9}),
      );
    });
  });
}
