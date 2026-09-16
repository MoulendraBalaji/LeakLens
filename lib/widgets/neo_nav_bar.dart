import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neo_theme.dart';

/// Neo-brutalist bottom dock: a chunky slab with hard-shadow stamps.
/// The active tab is injected as a heavy yellow sticker.
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 68,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border, width: NeoTheme.borderWidth),
        boxShadow: [NeoTheme.hardShadow(c.shadow, offset: const Offset(6, 6))],
      ),
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
          Container(width: 1, height: 36, color: c.border),
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: EdgeInsets.all(isSelected ? 0 : 6),
        decoration: BoxDecoration(
          color: isSelected ? c.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(0),
          border: isSelected
              ? Border.all(color: c.border, width: 2.5)
              : null,
          boxShadow: isSelected
              ? [NeoTheme.hardShadow(c.border, offset: const Offset(3, 3))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? c.border : c.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: NeoTheme.fontSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? c.border : c.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}