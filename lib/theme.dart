import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The visual language from the design mockups (design/collectionsync/),
/// translated into Flutter theming: warm terracotta accent, soft rounded
/// shapes, Plus Jakarta Sans. Kept in one place so every screen picks it up
/// automatically through Theme.of(context) rather than hardcoding colors.
class AppTheme {
  AppTheme._();

  // Light palette
  static const _lightBg = Color(0xFFF6F3F0);
  static const _lightSurface = Color(0xFFFEFDFB);
  static const _lightText = Color(0xFF3A332E);
  static const _lightTextMuted = Color(0xFF857A70);
  static const _lightAccent = Color(0xFFC1673E);
  static const _lightAccentContrast = Color(0xFFFEFDFB);
  static const _lightAccentSoft = Color(0xFFF3DFD1);
  static const _lightBorder = Color(0xFFE5E0D9);

  // Dark palette
  static const _darkBg = Color(0xFF241F1B);
  static const _darkSurface = Color(0xFF2E2822);
  static const _darkText = Color(0xFFF3F1EE);
  static const _darkTextMuted = Color(0xFFACA096);
  static const _darkAccent = Color(0xFFD3895E);
  static const _darkAccentContrast = Color(0xFF241F1B);
  static const _darkAccentSoft = Color(0xFF4A3A2E);
  static const _darkBorder = Color(0xFF453D36);

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: _lightBg,
        surface: _lightSurface,
        text: _lightText,
        textMuted: _lightTextMuted,
        accent: _lightAccent,
        accentContrast: _lightAccentContrast,
        accentSoft: _lightAccentSoft,
        border: _lightBorder,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: _darkBg,
        surface: _darkSurface,
        text: _darkText,
        textMuted: _darkTextMuted,
        accent: _darkAccent,
        accentContrast: _darkAccentContrast,
        accentSoft: _darkAccentSoft,
        border: _darkBorder,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color textMuted,
    required Color accent,
    required Color accentContrast,
    required Color accentSoft,
    required Color border,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: accentContrast,
      primaryContainer: accentSoft,
      onPrimaryContainer: accent,
      secondary: accent,
      onSecondary: accentContrast,
      secondaryContainer: accentSoft,
      onSecondaryContainer: accent,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: accentSoft,
      onSurfaceVariant: textMuted,
      outline: border,
      outlineVariant: border,
      error: const Color(0xFFB3492E),
      onError: accentContrast,
      shadow: Colors.black,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(bodyColor: text, displayColor: text);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentSoft,
        labelStyle: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 12.5),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        selectedColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentContrast,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border, width: 1.4),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentSoft,
        foregroundColor: accent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accentContrast : surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : border,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      badgeTheme: BadgeThemeData(backgroundColor: accent, textColor: accentContrast),
    );
  }
}
