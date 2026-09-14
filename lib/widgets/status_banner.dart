import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../theme/terminal_theme.dart';

/// Apple Dynamic Island & Pixel-inspired reactive live status banner.
class StatusBanner extends StatelessWidget {
  final List<Finding> findings;
  final bool isScanning;
  final VoidCallback? onCopyRedacted;

  const StatusBanner({
    super.key,
    required this.findings,
    this.isScanning = false,
    this.onCopyRedacted,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSafe = findings.isEmpty;

    final highCount =
        findings.where((f) => f.severity == Severity.high).length;
    final medCount =
        findings.where((f) => f.severity == Severity.medium).length;
    final lowCount =
        findings.where((f) => f.severity == Severity.low).length;

    final borderColor = isSafe
        ? TerminalTheme.safeGreen
        : (highCount > 0 ? TerminalTheme.alertRed : TerminalTheme.warningAmber);

    final gradientColors = isSafe
        ? [
            const Color(0x2E10B981),
            const Color(0x0F06B6D4),
          ]
        : (highCount > 0
            ? [
                const Color(0x33F43F5E),
                const Color(0x14080B10),
              ]
            : [
                const Color(0x33F59E0B),
                const Color(0x14080B10),
              ]);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.14),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: isScanning
                    ? const SizedBox(
                        key: ValueKey('scanning'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: TerminalTheme.infoBlue,
                        ),
                      )
                    : Container(
                        key: ValueKey(isSafe),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: borderColor.withValues(alpha: 0.18),
                          border: Border.all(
                            color: borderColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isSafe
                              ? Icons.check_rounded
                              : Icons.priority_high_rounded,
                          color: borderColor,
                          size: 18,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSafe
                          ? 'Safe to push'
                          : '${findings.length} secret${findings.length > 1 ? 's' : ''} detected',
                      style: TerminalTheme.fontSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSafe ? TerminalTheme.safeGreenSoft : borderColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSafe
                          ? 'No exposed credentials found in active buffer'
                          : 'Mask or invalidate credentials before pushing',
                      style: TerminalTheme.fontSans(
                        fontSize: 12,
                        color: TerminalTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSafe && onCopyRedacted != null)
                FilledButton.tonal(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onCopyRedacted!();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: TerminalTheme.surfaceHighlight,
                    foregroundColor: TerminalTheme.textBright,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: TerminalTheme.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 15, color: TerminalTheme.safeGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Redact All',
                        style: TerminalTheme.fontSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!isSafe) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (highCount > 0)
                  _buildCountChip('$highCount HIGH', TerminalTheme.alertRed),
                if (medCount > 0) ...[
                  const SizedBox(width: 6),
                  _buildCountChip(
                      '$medCount MED', TerminalTheme.warningAmber),
                ],
                if (lowCount > 0) ...[
                  const SizedBox(width: 6),
                  _buildCountChip('$lowCount LOW', TerminalTheme.infoBlue),
                ],
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TerminalTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'SHANNON + REGEX',
                    style: TerminalTheme.fontMono(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: TerminalTheme.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TerminalTheme.fontMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
