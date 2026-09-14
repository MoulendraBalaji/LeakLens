import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../services/risk_explainer_service.dart';
import '../theme/terminal_theme.dart';

/// Card displaying an individual detected finding with severity badge,
/// redacted snippet, line number, plain-English explanation, and remediation advice.
class FindingCard extends StatefulWidget {
  final Finding finding;
  final VoidCallback? onCopySnippet;

  const FindingCard({
    super.key,
    required this.finding,
    this.onCopySnippet,
  });

  @override
  State<FindingCard> createState() => _FindingCardState();
}

class _FindingCardState extends State<FindingCard> {
  bool _isUnmasked = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final finding = widget.finding;
    final severityColor = finding.severity.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TerminalTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.08),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Type chip, Line number, Severity badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    finding.severity.icon,
                    color: severityColor,
                    size: 16,
                  ),
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
                        style: TerminalTheme.fontSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: TerminalTheme.textBright,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0x2406B6D4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Line ${finding.lineNumber}',
                          style: TerminalTheme.fontMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: TerminalTheme.infoBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: finding.severity.backgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: severityColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    finding.severity.label,
                    style: TerminalTheme.fontSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: severityColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Middle: Redacted Code Snippet Display Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF090D13),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TerminalTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _isUnmasked
                          ? finding.matchedText
                          : finding.redactedText,
                      style: TerminalTheme.fontMono(
                        fontSize: 12,
                        color: _isUnmasked
                            ? TerminalTheme.alertRed
                            : TerminalTheme.textBright,
                        letterSpacing: _isUnmasked ? 0 : 0.6,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    tooltip: _isUnmasked ? 'Mask Secret' : 'Peek Secret',
                    icon: Icon(
                      _isUnmasked
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: TerminalTheme.textSecondary,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isUnmasked = !_isUnmasked;
                      });
                    },
                  ),
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Copy Redacted',
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: TerminalTheme.textSecondary,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(
                          ClipboardData(text: finding.redactedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          backgroundColor: TerminalTheme.surfaceHighlight,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                                color: TerminalTheme.safeGreen),
                          ),
                          content: Text(
                            'Redacted snippet copied to clipboard',
                            style: TerminalTheme.fontSans(
                              fontSize: 12,
                              color: TerminalTheme.textBright,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Context line preview if available
          if (finding.contextLine != null &&
              finding.contextLine!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'SOURCE: ${finding.contextLine}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TerminalTheme.fontMono(
                  fontSize: 10,
                  color: TerminalTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Plain-English Risk Explanation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.security_rounded,
                    size: 14,
                    color: TerminalTheme.warningAmber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    finding.explanation,
                    style: TerminalTheme.fontSans(
                      fontSize: 12,
                      height: 1.45,
                      color: TerminalTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expandable Remediation Guide
          InkWell(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: TerminalTheme.infoBlue,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isExpanded
                        ? 'Hide Remediation Steps'
                        : 'Recommended remediation steps',
                    style: TerminalTheme.fontSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: TerminalTheme.infoBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated CrossFade for remediation instructions
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: const Color(0xFF090D13),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TerminalTheme.border),
              ),
              child: Text(
                RiskExplainerService.instance
                    .getMitigationAdvice(finding.type),
                style: TerminalTheme.fontMono(
                  fontSize: 11,
                  height: 1.5,
                  color: TerminalTheme.textSecondary,
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
