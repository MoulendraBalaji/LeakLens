import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neo_theme.dart';

/// Refined floating dock navigation bar with smooth active pill indicator.
class NeoNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NeoNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = NeoColors.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      height: 64,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          if (c.isDark)
            BoxShadow(
              color: c.cyan.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              context,
              index: 0,
              icon: Icons.edit_note_rounded,
              label: 'PASTE',
            ),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: c.border.withValues(alpha: 0.6),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 1,
              icon: Icons.photo_camera_rounded,
              label: 'SCAN',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final c = NeoColors.of(context);
    final isSelected = selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isSelected) {
          HapticFeedback.lightImpact();
          onItemSelected(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? c.cyan.withValues(alpha: c.isDark ? 0.16 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: c.cyan.withValues(alpha: c.isDark ? 0.45 : 0.35),
                  width: 1.2,
                )
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? c.cyan : c.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: NeoTheme.fontSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? (c.isDark ? c.textBright : c.cyan) : c.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}