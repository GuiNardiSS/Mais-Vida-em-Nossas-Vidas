import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import '../../services/prefs.dart';

/// Controla o tema (sistema, claro ou escuro) e persiste a escolha.
final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    Future.microtask(_load);
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final stored = await Prefs.getThemeMode();
      final mode = ThemeMode.values.firstWhere(
        (value) => value.name == stored,
        orElse: () => ThemeMode.system,
      );
      if (state != mode) state = mode;
    } catch (_) {
      // Mantém o tema do sistema se a leitura falhar.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await Prefs.setThemeMode(mode.name);
  }
}
