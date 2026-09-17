import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../theme/neo_theme.dart';

/// Refined cybersecurity status banner — a translucent glass posture card that
/// clearly communicates safe / danger posture without visual clutter.
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
    final c = NeoColors.of(context);
    final bool isSafe = findings.isEmpty;
    final highCount = findings.where((f) => f.severity == Severity.high).length;
    final medCount = findings.where((f) => f.severity == Severity.medium).length;
    final lowCount = findings.where((f) => f.severity == Severity.low).length;

    final Color statusColor;
    final String title;
    final String subtitle;
    final IconData statusIcon;

    if (isScanning) {
      statusColor = c.cyan;
      title = 'SCANNING...';
      subtitle = 'Shannon entropy + regex engine running';
      statusIcon = Icons.radar_rounded;
    } else if (isSafe) {
      statusColor = c.green;
      title = 'SAFE TO PUSH';
      subtitle = 'All clear — zero exposed credentials found';
      statusIcon = Icons.verified_rounded;
    } else if (highCount > 0) {
      statusColor = c.red;
      title = '${findings.length} SECRET${findings.length > 1 ? 'S' : ''} DETECTED';
      subtitle = 'Mask or revoke before committing to git';
      statusIcon = Icons.gpp_maybe_rounded;
    } else {
      statusColor = c.yellow;
      title = '${findings.length} SECRET${findings.length > 1 ? 'S' : ''} DETECTED';
      subtitle = 'Review flagged tokens before publishing';
      statusIcon = Icons.warning_amber_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: c.isDark ? 0.45 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: c.isDark ? 0.12 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Glowing status icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: c.isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: isScanning
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: statusColor,
                          ),
                        )
                      : Icon(
                          statusIcon,
                          color: statusColor,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: NeoTheme.fontDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: c.textBright,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: NeoTheme.fontSans(
                        fontSize: 12,
                        color: c.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Optional quick Redact button
              if (!isSafe && onCopyRedacted != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onCopyRedacted!();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: c.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: c.green.withValues(alpha: 0.4),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, size: 14, color: c.green),
                        const SizedBox(width: 5),
                        Text(
                          'REDACT ALL',
                          style: NeoTheme.fontMono(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: c.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Severity counters if findings present
          if (!isSafe) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (highCount > 0)
                  _countBadge('$highCount HIGH', c.red, c),
                if (medCount > 0)
                  _countBadge('$medCount MED', c.yellow, c),
                if (lowCount > 0)
                  _countBadge('$lowCount LOW', c.cyan, c),
                _countBadge('REGEX + SHANNON', c.textSecondary, c),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Widget _countBadge(String text, Color accent, NeoColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: c.isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: accent.withValues(alpha: c.isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: NeoTheme.fontMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}