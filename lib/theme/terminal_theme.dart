import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Refined Apple & Google Pixel-inspired design system for LeakLens.
/// Blends deep OLED obsidian surfaces with electric neon accents and dual typography.
class TerminalTheme {
  // Backgrounds & Surfaces (OLED Deep Obsidian & Slate Graphite)
  static const Color background = Color(0xFF080B10); // Ultra deep OLED obsidian
  static const Color surface = Color(0xFF111622);    // Elevated slate graphite
  static const Color surfaceHighlight = Color(0xFF182030); // Interactive element hover/pressed
  static const Color glassSurface = Color(0xCC111622); // Translucent frosted dock/island
  static const Color border = Color(0xFF202B3D);     // Subtle 1px boundary
  static const Color borderAccent = Color(0xFF06B6D4); // Cyber cyan glow border

  // Status & Severity Accents (Vibrant & Refined)
  static const Color safeGreen = Color(0xFF10B981);   // Electric Emerald
  static const Color safeGreenSoft = Color(0xFF34D399);
  static const Color alertRed = Color(0xFFF43F5E);    // Sunset Crimson
  static const Color warningAmber = Color(0xFFF59E0B); // Solar Amber
  static const Color infoBlue = Color(0xFF06B6D4);     // Cyber Cyan
  static const Color cyanAccent = Color(0xFF38BDF8);

  // Vibrant Multi-Color Brand Gradient (Google & Cyber Spectrum)
  static const List<Color> multiColorGradient = [
    Color(0xFF4285F4), // Google Blue / Cyber Azure
    Color(0xFF06B6D4), // Electric Cyan
    Color(0xFF34D399), // Neon Emerald
    Color(0xFFFBBF24), // Solar Amber
    Color(0xFFF43F5E), // Sunset Crimson
    Color(0xFFA855F7), // Neon Violet
  ];

  /// Premium Google Sans typography helper (Plus Jakarta Sans geometric neo-grotesque)
  static TextStyle fontGoogleSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w800,
      color: color ?? textBright,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  // Typography Colors
  static const Color textBright = Color(0xFFF8FAFC); // Slate 50
  static const Color textPrimary = Color(0xFFE2E8F0); // Slate 200
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  /// Typography helpers:
  /// Primary UI Font: Plus Jakarta Sans (Crisp, modern, human-centric)
  static TextStyle fontSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  /// Technical / Monospace Font: JetBrains Mono (for code, tokens, line numbers)
  static TextStyle fontMono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  /// Builds the complete ThemeData configured with dual-font hierarchy and Apple/Pixel curvature.
  static ThemeData get darkTheme {
    final baseTextTheme =
        GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: safeGreen,
      colorScheme: const ColorScheme.dark(
        primary: safeGreen,
        secondary: infoBlue,
        surface: surface,
        error: alertRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.black,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: textBright,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: textBright,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textBright,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textBright,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Apple squircle curvature
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHighlight,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.jetBrainsMono(
          color: textMuted,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderAccent, width: 1.5),
        ),
      ),
    );
  }
}
