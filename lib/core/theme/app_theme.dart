import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weathernav/core/theme/app_tokens.dart';

class AppTheme {
  static const Color ink = Color(0xFF101015);
  static const Color blackInk = Color(0xFF1C1C1C);
  static const Color paleAsh = Color(0xFFE5E5E5);
  static const Color cream = Color(0xFFF1F0E1);
  static const Color slateBlue = Color(0xFF506385);

  static const Color accentBlue = Color(0xFFB9CBE4);
  static const Color accentPink = Color(0xFFE7B9D6);

  static const Color primary = slateBlue;
  static const Color background = cream;
  static const Color backgroundDark = ink;
  static const Color cardBg = paleAsh;
  static const Color cardBgDark = blackInk;
  static const Color danger = Color(0xFFDC2626);

  static ColorScheme _schemeLight() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: ink,
      primaryContainer: accentBlue,
      onPrimaryContainer: ink,
      secondary: accentPink,
      onSecondary: ink,
      secondaryContainer: accentPink,
      onSecondaryContainer: ink,
      tertiary: accentBlue,
      onTertiary: ink,
      tertiaryContainer: accentBlue,
      onTertiaryContainer: ink,
      error: danger,
      onError: cream,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: cardBg,
      onSurface: ink,
      surfaceContainerHighest: Color(0xFFD9D7CC),
      onSurfaceVariant: Color(0xFF2C2C33),
      outline: Color(0xFFB8B6AC),
      outlineVariant: Color(0xFFD1CFC5),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ink,
      onInverseSurface: cream,
      inversePrimary: accentBlue,
      surfaceTint: primary,
    );
  }

  static ColorScheme _schemeDark() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: cream,
      primaryContainer: Color(0xFF2F3A4F),
      onPrimaryContainer: cream,
      secondary: accentPink,
      onSecondary: ink,
      secondaryContainer: Color(0xFF6A4C61),
      onSecondaryContainer: cream,
      tertiary: accentBlue,
      onTertiary: ink,
      tertiaryContainer: Color(0xFF3F5066),
      onTertiaryContainer: cream,
      error: danger,
      onError: cream,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: cardBgDark,
      onSurface: cream,
      surfaceContainerHighest: Color(0xFF22222A),
      onSurfaceVariant: Color(0xFFC9C7BD),
      outline: Color(0xFF8C8C96),
      outlineVariant: Color(0xFF2E2E36),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: cream,
      onInverseSurface: ink,
      inversePrimary: accentBlue,
      surfaceTint: primary,
    );
  }

  // ── Shared widget theme builder ──────────────────────────────────────

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color scaffoldBg,
    required Color bottomSheetBg,
    double cardElevation = 1,
  }) {
    final textTheme = GoogleFonts.interTextTheme(
      scheme.brightness == Brightness.dark
          ? ThemeData(brightness: Brightness.dark).textTheme
          : ThemeData(brightness: Brightness.light).textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return ThemeData(
      brightness: scheme.brightness,
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0x00000000),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bottomSheetBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
    );
  }

  // ── Public accessors ────────────────────────────────────────────────

  static ThemeData get light => _buildTheme(
    scheme: _schemeLight(),
    scaffoldBg: background,
    bottomSheetBg: cardBg,
  );

  static ThemeData get dark => _buildTheme(
    scheme: _schemeDark(),
    scaffoldBg: backgroundDark,
    bottomSheetBg: cardBgDark,
    cardElevation: 0,
  );
}
