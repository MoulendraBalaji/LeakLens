import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../services/risk_explainer_service.dart';
import '../theme/neo_theme.dart';

/// Refined finding card: sleek rounded container with severity accent,
/// masked snippet preview, quick actions, and expandable remediation advice.
class FindingCard extends StatefulWidget {
  final Finding finding;
  const FindingCard({super.key, required this.finding});

  @override
  State<FindingCard> createState() => _FindingCardState();
}

class _FindingCardState extends State<FindingCard> {
  bool _isUnmasked = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final c = NeoColors.of(context);
    final finding = widget.finding;
    final sev = finding.severity;
    final sevColor = sev.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sevColor.withValues(alpha: c.isDark ? 0.45 : 0.32),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: sevColor.withValues(alpha: c.isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: icon + type + line badge + severity tag
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: sevColor.withValues(alpha: c.isDark ? 0.16 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sevColor.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Icon(sev.icon, color: sevColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          finding.type,
                          style: NeoTheme.fontSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.textBright,
                          ),
                        ),
                        _dataChip(c, 'LINE ${finding.lineNumber}', c.blue),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: sevColor.withValues(alpha: c.isDark ? 0.16 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sevColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      sev.label,
                      style: NeoTheme.fontMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: sevColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: c.border.withValues(alpha: 0.6)),

            // REDACTED / UNMASKED SNIPPET
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _isUnmasked ? finding.matchedText : finding.redactedText,
                        style: NeoTheme.fontMono(
                          fontSize: 12,
                          color: _isUnmasked ? c.red : c.textBright,
                          letterSpacing: _isUnmasked ? 0 : 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Peek toggle
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isUnmasked = !_isUnmasked);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: c.border, width: 1),
                        ),
                        child: Icon(
                          _isUnmasked
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 15,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Copy
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(
                            ClipboardData(text: finding.redactedText));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 900),
                          content: Text(
                            'Redacted snippet copied',
                            style: NeoTheme.fontSans(
                                fontSize: 12, color: c.textBright),
                          ),
                        ));
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: c.border, width: 1),
                        ),
                        child: Icon(Icons.copy_rounded,
                            size: 15, color: c.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Context line
            if (finding.contextLine != null && finding.contextLine!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'SRC: ${finding.contextLine}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NeoTheme.fontMono(
                    fontSize: 10,
                    color: c.textMuted,
                  ),
                ),
              ),

            if (finding.contextLine != null && finding.contextLine!.isNotEmpty)
              const SizedBox(height: 8),

            // Explanation
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: c.yellow),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      finding.explanation,
                      style: NeoTheme.fontSans(
                        fontSize: 12.5,
                        height: 1.45,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expand remediation toggle
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isExpanded = !_isExpanded);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isExpanded
                      ? c.surfaceAlt
                      : c.surfaceAlt.withValues(alpha: 0.4),
                  border: Border(
                    top: BorderSide(color: c.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: c.cyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isExpanded ? 'HIDE FIX STEPS' : 'HOW TO FIX',
                      style: NeoTheme.fontSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: c.cyan,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable remediation body
            if (_isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.background,
                  border: Border(
                    top: BorderSide(color: c.border, width: 1),
                  ),
                ),
                child: Text(
                  RiskExplainerService.instance.getMitigationAdvice(finding.type),
                  style: NeoTheme.fontMono(
                    fontSize: 11.5,
                    height: 1.5,
                    color: c.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _dataChip(NeoColors c, String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: c.isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: NeoTheme.fontMono(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}