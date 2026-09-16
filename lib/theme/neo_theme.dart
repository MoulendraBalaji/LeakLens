import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neo-Brutalism design system for LeakLens.
///
/// Raw, loud, confident. Thick hard borders, zero-blur offset shadows,
/// flat high-chroma surfaces and heavy-weight type. No gradients, no glow,
/// no glassmorphism — just hard edges and bold slabs.
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

  /// DARK palette — obsidian slabs, white borders, electric yellow shadows.
  static const NeoColors dark = NeoColors(
    background: Color(0xFF101014),
    surface: Color(0xFF1C1C23),
    surfaceAlt: Color(0xFF26262E),
    border: Color(0xFFF2F2F5),
    shadow: Color(0xFFFFD400),
    textBright: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFECECF0),
    textSecondary: Color(0xFFA3A3AC),
    textMuted: Color(0xFF71717B),
    yellow: Color(0xFFFFD400),
    cyan: Color(0xFF00E5FF),
    green: Color(0xFF2BD860),
    red: Color(0xFFFF4D4D),
    orange: Color(0xFFFF9F1C),
    blue: Color(0xFF4D9FFF),
    magenta: Color(0xFFFF5CD8),
    isDark: true,
  );

  /// LIGHT palette — warm paper, punchy black borders, brutal black shadows.
  static const NeoColors light = NeoColors(
    background: Color(0xFFF4F1E8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE9E6DA),
    border: Color(0xFF0B0B0E),
    shadow: Color(0xFF0B0B0E),
    textBright: Color(0xFF0B0B0E),
    textPrimary: Color(0xFF1B1B1F),
    textSecondary: Color(0xFF4D4D57),
    textMuted: Color(0xFF74747E),
    yellow: Color(0xFFFFD400),
    cyan: Color(0xFF00C2DE),
    green: Color(0xFF24C35E),
    red: Color(0xFFFF4D4D),
    orange: Color(0xFFFF9F1C),
    blue: Color(0xFF2F88FF),
    magenta: Color(0xFFFF4FD0),
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

/// Static Neo-Brutalism tokens and helpers.
class NeoTheme {
  NeoTheme._();

  static const double borderWidth = 2.5;
  static const double radius = 0;
  static const double innerRadius = 8;
  static const Offset hardOffset = Offset(5, 5);
  static const Offset hardOffsetLg = Offset(7, 7);

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
      fontWeight: fontWeight ?? FontWeight.w900,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
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

  /// Default hard shell shadow (zero blur offset slab shadow).
  static BoxShadow hardShadow(Color color, {Offset offset = hardOffset}) {
    return BoxShadow(color: color, offset: offset, blurRadius: 0);
  }

  /// The canonical neo-brutalist slab decoration.
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
        if (raised) BoxShadow(color: c.shadow, offset: offset, blurRadius: 0),
      ],
    );
  }

  /// Stamp-style sticker chip.
  static Widget sticker(
    BuildContext context, {
    required String text,
    Color? color,
    Color? fg,
    IconData? icon,
    double fontSize = 11,
    bool mono = true,
    VoidCallback? onTap,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) {
    final c = NeoColors.of(context);
    final fill = color ?? c.yellow;
    final ink = fg ?? c.border;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 3, color: ink),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: (mono ? fontMono : fontSans)(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
    final chip = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: c.border, width: 2),
        boxShadow: [hardShadow(c.border, offset: const Offset(3, 3))],
      ),
      child: content,
    );
    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }

  static ThemeData get darkTheme => _buildTheme(NeoColors.dark);
  static ThemeData get lightTheme => _buildTheme(NeoColors.light);

  static ThemeData _buildTheme(NeoColors c) {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: c.isDark ? Brightness.dark : Brightness.light)
          .textTheme,
    );

    final colorScheme = c.isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFFFD400),
            secondary: Color(0xFF00E5FF),
            surface: Color(0xFF1C1C23),
            error: Color(0xFFFF4D4D),
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Colors.white,
            onError: Colors.black,
          )
        : const ColorScheme.light(
            primary: Color(0xFFFFD400),
            secondary: Color(0xFF00C2DE),
            surface: Colors.white,
            error: Color(0xFFFF4D4D),
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Colors.black,
            onError: Colors.black,
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
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: c.textBright,
          fontWeight: FontWeight.w700,
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
          fontWeight: FontWeight.w800,
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
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: c.border, width: 2.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceAlt,
        elevation: 0,
        contentTextStyle: fontSans(fontSize: 12.5, color: c.textBright),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        labelStyle: fontSans(
          fontSize: 11,
          color: c.textBright,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: c.border, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: fontMono(fontSize: 12, color: c.textMuted),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: c.border, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: c.border, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(color: c.yellow, width: 3),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: c.border, width: 2.5),
        ),
        textStyle: fontSans(fontSize: 13, color: c.textBright),
      ),
      dialogTheme: DialogThemeData(backgroundColor: c.surface),
    );
  }
}