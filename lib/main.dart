import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'theme/neo_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Air-gapped guarantee: prevent google_fonts from attempting network requests
  GoogleFonts.config.allowRuntimeFetching = false;

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('theme_dark') ?? true;

  runApp(LeakLensApp(initialDark: isDark));
}

/// Root application widget for LeakLens.
class LeakLensApp extends StatefulWidget {
  final bool initialDark;

  const LeakLensApp({super.key, this.initialDark = true});

  @override
  State<LeakLensApp> createState() => _LeakLensAppState();
}

class _LeakLensAppState extends State<LeakLensApp> {
  late bool _isDark = widget.initialDark;

  @override
  void initState() {
    super.initState();
    _applySystemOverlay();
  }

  void _applySystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: _isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            _isDark ? const Color(0xFF080B11) : const Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness:
            _isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
    _applySystemOverlay();
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool('theme_dark', _isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeakLens',
      debugShowCheckedModeBanner: false,
      theme: NeoTheme.lightTheme,
      darkTheme: NeoTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}