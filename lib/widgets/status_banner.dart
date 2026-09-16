import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../theme/neo_theme.dart';

/// Bold neo-brutalist status banner — a fat solid-color slab that instantly
/// communicates safe / danger status with zero ambiguity.
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

    Color bg;
    Color bannerBorder;
    if (isScanning) {
      bg = c.yellow;
      bannerBorder = c.border;
    } else if (isSafe) {
      bg = c.green;
      bannerBorder = c.border;
    } else if (highCount > 0) {
      bg = c.red;
      bannerBorder = c.border;
    } else {
      bg = c.orange;
      bannerBorder = c.border;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: bannerBorder, width: NeoTheme.borderWidth),
        boxShadow: [
          NeoTheme.hardShadow(
            bannerBorder,
            offset: const Offset(6, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status icon / spinner
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isScanning
                    ? SizedBox(
                        key: const ValueKey('spinning'),
                        width: 32,
                        height: 32,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFF0B0B0E),
                        ),
                      )
                    : Container(
                        key: ValueKey(isSafe ? 'safe' : 'danger'),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSafe ? c.border : const Color(0x33000000),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: c.border,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSafe
                                  ? Icons.check_rounded
                                  : Icons.warning_rounded,
                              size: 20,
                              color: isSafe ? c.green : c.border,
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isScanning
                          ? 'SCANNING...'
                          : isSafe
                              ? 'SAFE TO PUSH'
                              : '${findings.length} SECRET${findings.length > 1 ? 'S' : ''}',
                      style: NeoTheme.fontDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: c.border,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isScanning
                          ? 'Regex + Shannon entropy analysis running'
                          : isSafe
                              ? 'All clear — no exposed credentials found'
                              : 'Mask or revoke before pushing to source',
                      style: NeoTheme.fontMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xAA000000),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSafe && onCopyRedacted != null)
                NeoTheme.sticker(
                  context,
                  text: 'REDACT ALL',
                  color: c.border,
                  fg: bg,
                  icon: Icons.shield_rounded,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onCopyRedacted!();
                  },
                ),
            ],
          ),
          if (!isSafe) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (highCount > 0)
                  _countBadge('$highCount× HIGH', c.border),
                if (medCount > 0)
                  _countBadge('$medCount× MED', c.border),
                if (lowCount > 0)
                  _countBadge('$lowCount× LOW', c.border),
                _countBadge('REGEX + SHANNON', const Color(0x77000000)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Widget _countBadge(String text, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x22000000),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: fg, width: 1.5),
      ),
      child: Text(
        text,
        style: NeoTheme.fontMono(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}