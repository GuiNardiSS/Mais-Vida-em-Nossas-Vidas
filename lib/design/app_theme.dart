import 'package:material_ui/material_ui.dart';
import 'tokens.dart';

/// Tema visual do aplicativo, com versões clara e escura.
abstract final class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.petrol,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.petrol,
          onPrimary: Colors.white,
          secondary: AppColors.gold,
          onSecondary: const Color(0xFF241B07),
          surface: Colors.white,
          onSurface: AppColors.ink,
          surfaceContainerHighest: AppColors.creamDeep,
          outline: const Color(0xFFD9CDB8),
          outlineVariant: const Color(0xFFE8DECB),
          error: AppColors.danger,
          onError: Colors.white,
        ),
        scaffold: AppColors.cream,
        appBarBackground: AppColors.cream,
        appBarForeground: AppColors.ink,
        cardColor: Colors.white,
        navigationBackground: Colors.white,
        navigationIndicator: AppColors.goldSoft,
        muted: AppColors.inkMuted,
        subtleBorder: const Color(0xFFE8DECB),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.petrolSoft,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.petrolSoft,
          onPrimary: const Color(0xFF04191B),
          secondary: AppColors.goldBright,
          onSecondary: const Color(0xFF241B07),
          surface: AppColors.nightSurface,
          onSurface: AppColors.nightInk,
          surfaceContainerHighest: AppColors.nightSurfaceHigh,
          outline: const Color(0xFF315054),
          outlineVariant: const Color(0xFF1E3B3E),
          error: const Color(0xFFE08A84),
          onError: const Color(0xFF2B0806),
        ),
        scaffold: AppColors.night,
        appBarBackground: AppColors.night,
        appBarForeground: AppColors.nightInk,
        cardColor: AppColors.nightSurface,
        navigationBackground: AppColors.nightSurface,
        navigationIndicator: const Color(0xFF1D3B3E),
        muted: AppColors.nightMuted,
        subtleBorder: const Color(0xFF1E3B3E),
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color cardColor,
    required Color navigationBackground,
    required Color navigationIndicator,
    required Color muted,
    required Color subtleBorder,
  }) {
    final textTheme = _textTheme(scheme.onSurface, muted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Inter',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationBackground,
        indicatorColor: navigationIndicator,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium!.copyWith(
            color: selected ? scheme.onSurface : muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : muted,
            size: 24,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: subtleBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
          minimumSize: const Size(0, 52),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? AppColors.nightSurfaceHigh
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium!.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium!.copyWith(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: subtleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.nightSurfaceHigh
            : Colors.white,
        selectedColor: AppColors.goldSoft,
        side: BorderSide(color: subtleBorder),
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelMedium!,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        titleTextStyle: textTheme.headlineMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.onSurface,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: scheme.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: subtleBorder,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.onSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall!.copyWith(color: scheme.surface),
      ),
    );
  }

  static TextTheme _textTheme(Color ink, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Lora',
        fontSize: 34,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Lora',
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: -0.3,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Lora',
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Lora',
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: muted,
        letterSpacing: 0.3,
      ),
    );
  }
}
