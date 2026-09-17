import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cyber-Security Obsidian & Glass design system for LeakLens.
///
/// Blends deep OLED obsidian surfaces with electric security neon accents,
/// crisp Plus Jakarta Sans typography, JetBrains Mono code rendering,
/// refined 16px squircle curvature, and soft ambient elevations.
@immutable
class NeoColors extends ThemeExtension<NeoColors> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color shadow;
  final Color textBright;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color yellow;
  final Color cyan;
  final Color green;
  final Color red;
  final Color orange;
  final Color blue;
  final Color magenta;
  final bool isDark;

  const NeoColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.shadow,
    required this.textBright,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.yellow,
    required this.cyan,
    required this.green,
    required this.red,
    required this.orange,
    required this.blue,
    required this.magenta,
    required this.isDark,
  });

  /// DARK palette — Deep OLED obsidian, frosted slate surfaces, cyber accents.
  static const NeoColors dark = NeoColors(
    background: Color(0xFF080B11),
    surface: Color(0xFF111726),
    surfaceAlt: Color(0xFF182033),
    border: Color(0xFF222F46),
    shadow: Color(0x33000000),
    textBright: Color(0xFFF8FAFC),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    yellow: Color(0xFFF59E0B),
    cyan: Color(0xFF06B6D4),
    green: Color(0xFF10B981),
    red: Color(0xFFF43F5E),
    orange: Color(0xFFF97316),
    blue: Color(0xFF38BDF8),
    magenta: Color(0xFFA855F7),
    isDark: true,
  );

  /// LIGHT palette — Clean crisp studio slate, high-legibility surfaces.
  static const NeoColors light = NeoColors(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    shadow: Color(0x0F0F172A),
    textBright: Color(0xFF0F172A),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    textMuted: Color(0xFF94A3B8),
    yellow: Color(0xFFD97706),
    cyan: Color(0xFF0891B2),
    green: Color(0xFF059669),
    red: Color(0xFFE11D48),
    orange: Color(0xFFEA580C),
    blue: Color(0xFF2563EB),
    magenta: Color(0xFF9333EA),
    isDark: false,
  );

  static NeoColors of(BuildContext context) =>
      Theme.of(context).extension<NeoColors>() ?? dark;

  @override
  NeoColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? shadow,
    Color? textBright,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? yellow,
    Color? cyan,
    Color? green,
    Color? red,
    Color? orange,
    Color? blue,
    Color? magenta,
    bool? isDark,
  }) {
    return NeoColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      textBright: textBright ?? this.textBright,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      yellow: yellow ?? this.yellow,
      cyan: cyan ?? this.cyan,
      green: green ?? this.green,
      red: red ?? this.red,
      orange: orange ?? this.orange,
      blue: blue ?? this.blue,
      magenta: magenta ?? this.magenta,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  NeoColors lerp(ThemeExtension<NeoColors>? other, double t) {
    if (other is! NeoColors) return this;
    return NeoColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      textBright: Color.lerp(textBright, other.textBright, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      green: Color.lerp(green, other.green, t)!,
      red: Color.lerp(red, other.red, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      magenta: Color.lerp(magenta, other.magenta, t)!,
      isDark: isDark,
    );
  }
}

/// Cyber Obsidian & Glass tokens and helpers.
class NeoTheme {
  NeoTheme._();

  static const double borderWidth = 1.2;
  static const double radius = 16.0;
  static const double innerRadius = 10.0;
  static const double pillRadius = 30.0;
  static const Offset hardOffset = Offset(0, 4);
  static const Offset hardOffsetLg = Offset(0, 8);

  /// Brand Multi-color gradient
  static const List<Color> multiColorGradient = [
    Color(0xFF38BDF8),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
  ];

  /// Heavy display type for big statements.
  static TextStyle fontDisplay({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w800,
      color: color,
      height: height,
      letterSpacing: letterSpacing ?? -0.3,
    );
  }

  /// Primary UI sans.
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
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  /// Technical / monospace for code, tokens and data.
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
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  /// Refined ambient elevation shadow.
  static BoxShadow hardShadow(Color color, {Offset offset = hardOffset}) {
    return BoxShadow(
      color: color.withValues(alpha: 0.18),
      offset: offset,
      blurRadius: 12,
      spreadRadius: 0,
    );
  }

  /// Sleek squircle card decoration with subtle border and ambient elevation.
  static BoxDecoration slab(
    BuildContext context, {
    Color? color,
    double radius = radius,
    bool raised = true,
    Offset offset = hardOffset,
    Color? borderColor,
    double width = borderWidth,
  }) {
    final c = NeoColors.of(context);
    return BoxDecoration(
      color: color ?? c.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? c.border, width: width),
      boxShadow: [
        if (raised)
          BoxShadow(
            color: c.shadow,
            offset: offset,
            blurRadius: 14,
            spreadRadius: 0,
          ),
      ],
    );
  }

  /// Refined pill chip with subtle accent tint.
  static Widget sticker(
    BuildContext context, {
    required String text,
    Color? color,
    Color? fg,
    IconData? icon,
    double fontSize = 11,
    bool mono = false,
    VoidCallback? onTap,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
  }) {
    final c = NeoColors.of(context);
    final accent = color ?? c.cyan;
    final ink = fg ?? (c.isDark ? accent : accent);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 3, color: ink),
          const SizedBox(width: 5),
        ],
        Text(
          text,
          style: (mono ? fontMono : fontSans)(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    final chip = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: c.isDark ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(pillRadius),
        border: Border.all(
          color: accent.withValues(alpha: c.isDark ? 0.38 : 0.28),
          width: 1.1,
        ),
      ),
      child: content,
    );

    if (onTap == null) return chip;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: chip,
    );
  }

  static ThemeData get darkTheme => _buildTheme(NeoColors.dark);
  static ThemeData get lightTheme => _buildTheme(NeoColors.light);

  static ThemeData _buildTheme(NeoColors c) {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: c.isDark ? Brightness.dark : Brightness.light)
          .textTheme,
    );

    final colorScheme = c.isDark
        ? ColorScheme.dark(
            primary: c.green,
            secondary: c.cyan,
            surface: c.surface,
            error: c.red,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: c.textPrimary,
            onError: Colors.white,
          )
        : ColorScheme.light(
            primary: c.green,
            secondary: c.cyan,
            surface: c.surface,
            error: c.red,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: c.textPrimary,
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: c.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      colorScheme: colorScheme,
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: c.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: c.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.textBright),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: c.border, width: borderWidth),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceAlt,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.border, width: 1),
        ),
        contentTextStyle: fontSans(fontSize: 13, color: c.textBright),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceAlt,
        labelStyle: fontSans(
          fontSize: 11,
          color: c.textBright,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pillRadius),
          side: BorderSide(color: c.border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: fontMono(fontSize: 12, color: c.textMuted),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.cyan, width: 1.5),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.border, width: 1),
        ),
        textStyle: fontSans(fontSize: 13, color: c.textBright),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
    );
  }
}