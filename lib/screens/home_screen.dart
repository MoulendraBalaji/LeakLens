import 'package:flutter/material.dart';
import '../theme/terminal_theme.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/terminal_app_bar.dart';
import 'camera_scan_screen.dart';
import 'paste_scan_screen.dart';

/// Main screen containing floating island bottom navigation and smooth fluid page transitions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSendOcrTextToEditor(String text) {
    setState(() {
      _pendingPasteText = text;
      _currentIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalTheme.background,
      appBar: const TerminalAppBar(),
      extendBody: true, // Allows content to flow behind floating dock
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              PasteScanScreen(
                initialText: _pendingPasteText,
              ),
              CameraScanScreen(
                onSendToPasteEditor: _onSendOcrTextToEditor,
              ),
            ],
          ),

          // Floating Glassmorphic Navigation Island
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: FloatingNavBar(
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
