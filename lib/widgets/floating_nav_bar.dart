import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/terminal_theme.dart';

/// Modern floating island bottom navigation bar with a fluid sliding pill indicator.
/// Inspired by Apple Dynamic Island and Google Pixel Material You aesthetics.
class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: TerminalTheme.safeGreen.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xE6111622),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0x40202B3D),
                width: 1.2,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 4) / 2;
                final leftOffset = selectedIndex == 0 ? 2.0 : itemWidth + 2.0;

                return Stack(
                  children: [
                    // Fluid Sliding Indicator Pill
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      left: leftOffset,
                      top: 2,
                      bottom: 2,
                      width: itemWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x3310B981),
                              Color(0x1F06B6D4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: TerminalTheme.safeGreen.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: TerminalTheme.safeGreen
                                  .withValues(alpha: 0.18),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Interactive Tab Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNavItem(
                            index: 0,
                            icon: Icons.edit_note_rounded,
                            activeIcon: Icons.edit_note_rounded,
                            label: 'Paste Buffer',
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            index: 1,
                            icon: Icons.camera_alt_outlined,
                            activeIcon: Icons.camera_alt_rounded,
                            label: 'Camera Scan',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isSelected) {
          HapticFeedback.lightImpact();
          onItemSelected(index);
        }
      },
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.02 : 0.98,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected
                    ? TerminalTheme.safeGreenSoft
                    : TerminalTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TerminalTheme.fontSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? TerminalTheme.textBright
                      : TerminalTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
