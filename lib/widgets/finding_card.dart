import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../services/risk_explainer_service.dart';
import '../theme/neo_theme.dart';

/// Neo-brutalist finding card: a chunky, hard-bordered slab with raw severity
/// accent, redacted snippet, explanation, and expandable remediation.
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
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: sevColor, width: NeoTheme.borderWidth),
        boxShadow: [NeoTheme.hardShadow(c.shadow, offset: const Offset(5, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: icon + type + line badge + severity tag
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: sevColor,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: c.border, width: 2),
                  ),
                  child: Icon(sev.icon, color: c.border, size: 16),
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
                          fontWeight: FontWeight.w800,
                          color: c.textBright,
                        ),
                      ),
                      _dataChip(c, 'LINE ${finding.lineNumber}', c.blue),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sevColor,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: c.border, width: 2),
                    boxShadow: [
                      NeoTheme.hardShadow(c.border, offset: const Offset(2, 2)),
                    ],
                  ),
                  child: Text(
                    sev.label,
                    style: NeoTheme.fontMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: c.border,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 2.5,
            decoration: BoxDecoration(
              color: sevColor,
              border: Border(
                top: BorderSide(color: c.border, width: 1.5),
              ),
            ),
          ),

          // REDACTED SNIPPET
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.background,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: c.border, width: 2),
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
                  const SizedBox(width: 4),
                  // Peek toggle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isUnmasked = !_isUnmasked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.surfaceAlt,
                        border: Border.all(color: c.border, width: 1.5),
                      ),
                      child: Icon(
                        _isUnmasked
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 16,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Copy
                  GestureDetector(
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
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.surfaceAlt,
                        border: Border.all(color: c.border, width: 1.5),
                      ),
                      child: Icon(Icons.copy_rounded,
                          size: 16, color: c.textSecondary),
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
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          if (finding.contextLine != null && finding.contextLine!.isNotEmpty)
            const SizedBox(height: 8),

          // Explanation
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gpp_good_outlined, size: 16, color: c.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    finding.explanation,
                    style: NeoTheme.fontSans(
                      fontSize: 12,
                      height: 1.45,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expand remediation toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isExpanded ? c.yellow : Colors.transparent,
                border: Border(
                  top: BorderSide(color: c.border, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: c.border,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isExpanded ? 'HIDE FIX STEPS' : 'HOW TO FIX',
                    style: NeoTheme.fontSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: c.border,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.background,
                border: Border(
                  top: BorderSide(color: c.border, width: 1.5),
                ),
              ),
              child: Text(
                RiskExplainerService.instance.getMitigationAdvice(finding.type),
                style: NeoTheme.fontMono(
                  fontSize: 11,
                  height: 1.5,
                  color: c.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _dataChip(NeoColors c, String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: Text(
        text,
        style: NeoTheme.fontMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}