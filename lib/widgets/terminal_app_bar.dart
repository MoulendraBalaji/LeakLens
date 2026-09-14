import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dialogs/trust_dialog.dart';
import '../theme/terminal_theme.dart';

/// Top application bar with minimal brand mark, pulsing status beacon,
/// and air-gapped security badge.
class TerminalAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TerminalAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  State<TerminalAppBar> createState() => _TerminalAppBarState();
}

class _TerminalAppBarState extends State<TerminalAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TerminalTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              // Minimal Brand Mark Icon (Vector Cyber Lens)
              Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: const Color(0xFF0D131F),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.shield_rounded,
                    color: TerminalTheme.safeGreen,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Brand Title with Premium Google Sans typography & Multi-color full name
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Multicolor 'LeakLens' in Full Name with Premium Google Sans Font
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: TerminalTheme.multiColorGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'LeakLens',
                          style: TerminalTheme.fontGoogleSans(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: TerminalTheme.surfaceHighlight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: TerminalTheme.border),
                        ),
                        child: Text(
                          'v1.0',
                          style: TerminalTheme.fontMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: TerminalTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'ON-DEVICE CREDENTIAL AUDIT',
                    style: TerminalTheme.fontMono(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: TerminalTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Air-Gapped Trust Badge with Animated Pulsing Beacon
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (ctx) => const TrustDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1A10B981),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TerminalTheme.safeGreen.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TerminalTheme.safeGreen.withValues(alpha: 0.08),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pulsing Emerald Beacon
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TerminalTheme.safeGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: TerminalTheme.safeGreen.withValues(
                                    alpha: _pulseAnimation.value * 0.8,
                                  ),
                                  blurRadius: 6 * _pulseAnimation.value,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AIR-GAPPED',
                        style: TerminalTheme.fontMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: TerminalTheme.safeGreen,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
