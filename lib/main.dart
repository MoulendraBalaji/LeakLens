import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'theme/terminal_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Air-gapped guarantee: prevent google_fonts from attempting network requests
  GoogleFonts.config.allowRuntimeFetching = false;

  // Set immersive dark system navigation bar and status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TerminalTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LeakLensApp());
}

/// Root application widget for LeakLens.
class LeakLensApp extends StatelessWidget {
  const LeakLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeakLens',
      debugShowCheckedModeBanner: false,
      theme: TerminalTheme.darkTheme,
      darkTheme: TerminalTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
