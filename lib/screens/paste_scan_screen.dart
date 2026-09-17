import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../services/scanner_service.dart';
import '../theme/neo_theme.dart';
import '../widgets/finding_card.dart';
import '../widgets/status_banner.dart';

/// Paste / buffer screen — paste terminal output or .env files for
/// instant on-device credential scanning.
class PasteScanScreen extends StatefulWidget {
  final String? initialText;
  const PasteScanScreen({super.key, this.initialText});

  @override
  State<PasteScanScreen> createState() => _PasteScanScreenState();
}

class _PasteScanScreenState extends State<PasteScanScreen> {
  late final TextEditingController _textController;
  Timer? _debounceTimer;
  List<Finding> _findings = [];
  bool _isScanning = false;
  Severity? _selectedSeverityFilter;

  static const Map<String, String> _samplePresets = {
    'AWS & Stripe .env': '''# Production Environment Secrets
APP_ENV=production
PORT=8080
DATABASE_URL=postgres://app_user:z9#kL2!vP0@xQ8^mC4&wR1@db.internal:5432/main
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
STRIPE_SECRET_KEY=sk_test_51Abcdefghijklmnopqrstuvwx987654321
STRIPE_PUBLIC_KEY=pk_test_51Abcdefghijklmnopqrstuvwx987654321
REDIS_PASSWORD=mypassword123456789!@#
''',
    'Git Diff / Tokens': '''diff --git a/config.json b/config.json
--- a/config.json
+++ b/config.json
@@ -1,5 +1,6 @@
 {
   "version": "1.0.0",
+  "github_token": "ghp_123456789012345678901234567890123456",
+  "google_api_key": "AIzaSyD-1234567890abcdefghijklmnopqrst",
   "debug": false
 }
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0mY8...fake_private_key_pem_block...
-----END RSA PRIVATE KEY-----
''',
    'Terminal Logs / Auth': '''[2026-09-14 12:04:15] [INFO] Outgoing request to Slack bot
[2026-09-14 12:04:16] [DEBUG] Auth Header: Bearer xoxb-9999999999mocktokenforexample9999
[2026-09-14 12:04:17] [WARN] Session token in payload:
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
''',
    'Clean Terminal Code': '''git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
npm run test
PASS src/index.test.ts (4 tests passed)
''',
  };

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    if (_textController.text.isNotEmpty) {
      _runScanImmediately(_textController.text);
    }
  }

  @override
  void didUpdateWidget(PasteScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != null && widget.initialText != _textController.text) {
      _textController.text = widget.initialText!;
      _runScanImmediately(widget.initialText!);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    setState(() => _isScanning = true);
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _runScanImmediately(text);
    });
  }

  void _runScanImmediately(String text) {
    final results = ScannerService.instance.scanText(text);
    if (mounted) setState(() { _findings = results; _isScanning = false; });
  }

  void _copyRedactedVersion() {
    final original = _textController.text;
    if (original.isEmpty) return;
    final sanitized =
        ScannerService.instance.generateRedactedDocument(original, _findings);
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: sanitized));
    final c = NeoColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: c.surfaceAlt,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.green.withValues(alpha: 0.5), width: 1),
      ),
      content: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: c.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Redacted version copied — all secrets masked with •',
              style: NeoTheme.fontSans(fontSize: 12.5, color: c.textBright),
            ),
          ),
        ],
      ),
    ));
  }

  void _loadPreset(String key) {
    final sample = _samplePresets[key];
    if (sample != null) {
      HapticFeedback.selectionClick();
      _textController.text = sample;
      _runScanImmediately(sample);
    }
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.selectionClick();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
      _runScanImmediately(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = NeoColors.of(context);
    final filteredFindings = _selectedSeverityFilter == null
        ? _findings
        : _findings
            .where((f) => f.severity == _selectedSeverityFilter)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // STATUS
          StatusBanner(
            findings: _findings,
            isScanning: _isScanning,
            onCopyRedacted: _findings.isNotEmpty ? _copyRedactedVersion : null,
          ),

          const SizedBox(height: 14),

          // TOOLBAR ROW
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Preset picker
              PopupMenuButton<String>(
                tooltip: 'Load sample',
                onSelected: _loadPreset,
                itemBuilder: (ctx) => _samplePresets.keys
                    .map((name) => PopupMenuItem(
                          value: name,
                          child: Row(
                            children: [
                              Icon(Icons.code_rounded,
                                  size: 16, color: c.cyan),
                              const SizedBox(width: 8),
                              Text(
                                name,
                                style: NeoTheme.fontSans(
                                    fontSize: 13, color: c.textBright),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                child: NeoTheme.sticker(context,
                    text: 'SAMPLES',
                    icon: Icons.auto_awesome_rounded,
                    color: c.cyan, fontSize: 11),
              ),

              // Paste
              GestureDetector(
                onTap: _pasteFromClipboard,
                child: NeoTheme.sticker(context,
                    text: 'PASTE',
                    icon: Icons.content_paste_rounded,
                    color: c.yellow,
                    fontSize: 11),
              ),

              // Clear
              if (_textController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _textController.clear();
                    _runScanImmediately('');
                  },
                  child: NeoTheme.sticker(context,
                      text: 'CLEAR',
                      icon: Icons.close_rounded,
                      color: c.red, fontSize: 11),
                ),

              // Copy Redacted
              if (_findings.isNotEmpty)
                GestureDetector(
                  onTap: _copyRedactedVersion,
                  child: NeoTheme.sticker(context,
                      text: 'COPY REDACTED',
                      icon: Icons.copy_rounded,
                      color: c.green,
                      fontSize: 11),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // INPUT BOX
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mini header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      border: Border(
                        bottom: BorderSide(color: c.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: c.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'buffer.txt',
                          style: NeoTheme.fontMono(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: c.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_textController.text.length} chars · ${_textController.text.split('\n').length} lines',
                          style: NeoTheme.fontMono(
                            fontSize: 10.5,
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    minLines: 5,
                    onChanged: _onTextChanged,
                    style: NeoTheme.fontMono(
                      fontSize: 12.5,
                      height: 1.5,
                      color: c.textBright,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Paste terminal logs, git diffs, curl commands, or .env files here...',
                      hintStyle: NeoTheme.fontMono(
                        fontSize: 12,
                        color: c.textMuted.withValues(alpha: 0.6),
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // FINDINGS HEADER + FILTERS
          if (_findings.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'DETECTED (${_findings.length})',
                  style: NeoTheme.fontSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: c.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                _filterChip(c, null, 'ALL'),
                const SizedBox(width: 5),
                _filterChip(c, Severity.high, 'HIGH'),
                const SizedBox(width: 5),
                _filterChip(c, Severity.medium, 'MED'),
              ],
            ),
            const SizedBox(height: 12),
            ...filteredFindings.map((f) => FindingCard(
                  key: ValueKey('${f.type}_${f.startIndex}'),
                  finding: f,
                )),
          ] else if (_textController.text.isNotEmpty) ...[
            // Clean empty state
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: c.green.withValues(alpha: c.isDark ? 0.35 : 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.green.withValues(alpha: 0.05),
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
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: c.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: c.green.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.shield_rounded, size: 24, color: c.green),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'NO CREDENTIALS DETECTED',
                    style: NeoTheme.fontDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textBright,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scanned with AWS, GitHub, Google, Stripe, Slack, JWT, DB URI and Shannon entropy detectors.',
                    textAlign: TextAlign.center,
                    style: NeoTheme.fontSans(
                      fontSize: 12,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(NeoColors c, Severity? severity, String label) {
    final selected = _selectedSeverityFilter == severity;
    final accent = severity == Severity.high
        ? c.red
        : severity == Severity.medium
            ? c.yellow
            : c.cyan;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedSeverityFilter = severity);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: c.isDark ? 0.20 : 0.14)
              : c.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.5)
                : c.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: NeoTheme.fontMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: selected ? accent : c.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}