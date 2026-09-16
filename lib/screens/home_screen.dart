import 'package:flutter/material.dart';
import '../theme/neo_theme.dart';
import '../widgets/neo_nav_bar.dart';
import '../widgets/neo_app_bar.dart';
import 'camera_scan_screen.dart';
import 'paste_scan_screen.dart';

/// Main screen hosting the paste and camera pages with a neo-brutalist dock.
class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _pendingPasteText;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSendOcrTextToEditor(String text) {
    setState(() {
      _pendingPasteText = text;
      _currentIndex = 0;
    });
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = NeoColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: NeoAppBar(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
      ),
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              PasteScanScreen(initialText: _pendingPasteText),
              CameraScanScreen(onSendToPasteEditor: _onSendOcrTextToEditor),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: NeoNavBar(
                selectedIndex: _currentIndex,
                onItemSelected: _onTabChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}