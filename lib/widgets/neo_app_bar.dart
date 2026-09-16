import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dialogs/trust_dialog.dart';
import '../theme/neo_theme.dart';

/// Neo-brutalist top bar: hard-slabs brand block, AIR-GAPPED stamp,
/// theme toggle and build badge.
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(
          bottom: BorderSide(color: c.border, width: NeoTheme.borderWidth),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              // Brand slab: name-only logo in a hard yellow block
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.yellow,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: c.border, width: 2.5),
                  boxShadow: [NeoTheme.hardShadow(c.border, offset: const Offset(3, 3))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LeakLens',
                      style: NeoTheme.fontDisplay(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: c.border,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Version badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: c.border, width: 2),
                ),
                child: Text(
                  'v1.1',
                  style: NeoTheme.fontMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: c.textSecondary,
                  ),
                ),
              ),

              const Spacer(),

              // AIR-GAPPED trust stamp (opens dialog)
              NeoTheme.sticker(
                context,
                text: 'AIR-GAPPED',
                color: c.green,
                icon: Icons.lock_outline_rounded,
                fontSize: 10,
                onTap: () {
                  HapticFeedback.lightImpact();
                  showDialog(context: context, builder: (_) => const TrustDialog());
                },
              ),
              const SizedBox(width: 8),

              // Theme toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggleTheme();
                },
                child: Tooltip(
                  message: 'Toggle light / dark mode',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: c.border, width: 2.5),
                      boxShadow: [NeoTheme.hardShadow(c.border, offset: const Offset(3, 3))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isDark ? c.yellow : c.background,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: c.border, width: 2),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            size: 12,
                            color: isDark ? c.border : c.yellow,
                          ),
                        ),
                      ],
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