import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dialogs/trust_dialog.dart';
import '../theme/neo_theme.dart';

/// Refined top bar: brand emblem, AIR-GAPPED security badge,
/// theme toggle and version indicator.
class NeoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const NeoAppBar({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    final c = NeoColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(
          bottom: BorderSide(color: c.border, width: 1.0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              // Brand Icon + Name
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.security_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'LeakLens',
                style: NeoTheme.fontDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: c.textBright,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 8),

              // Version badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: c.border, width: 1),
                ),
                child: Text(
                  'v1.1',
                  style: NeoTheme.fontMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: c.textSecondary,
                  ),
                ),
              ),

              const Spacer(),

              // AIR-GAPPED trust badge (opens dialog)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (_) => const TrustDialog(),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: c.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: c.green.withValues(alpha: 0.35),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: c.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: c.green.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AIR-GAPPED',
                        style: NeoTheme.fontMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: c.green,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Theme toggle
              Tooltip(
                message: 'Toggle light / dark mode',
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onToggleTheme();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.border, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: c.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFFFBBF24) : c.textPrimary,
                    ),
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