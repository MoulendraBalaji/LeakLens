import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finding.dart';
import '../services/scanner_service.dart';
import '../theme/terminal_theme.dart';
import '../widgets/finding_card.dart';
import '../widgets/status_banner.dart';

/// Screen allowing the user to paste terminal output, .env contents, or code
/// and perform instant reactive on-device credential scanning.
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

  // Preset demo samples
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
    if (widget.initialText != null &&
        widget.initialText != _textController.text) {
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

  /// Debounces input changes by ~300ms as requested in specification
  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    setState(() {
      _isScanning = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _runScanImmediately(text);
    });
  }

  void _runScanImmediately(String text) {
    final results = ScannerService.instance.scanText(text);
    if (mounted) {
      setState(() {
        _findings = results;
        _isScanning = false;
      });
    }
  }

  /// Copies the original text with all detected secrets masked in place
  void _copyRedactedVersion() {
    final original = _textController.text;
    if (original.isEmpty) return;

    final sanitized =
        ScannerService.instance.generateRedactedDocument(original, _findings);

    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: sanitized));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TerminalTheme.surfaceHighlight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: TerminalTheme.safeGreen),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: TerminalTheme.safeGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Redacted version copied to clipboard!\nAll detected credentials masked with •',
                style: TerminalTheme.fontSans(
                  fontSize: 12.5,
                  color: TerminalTheme.textBright,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    final filteredFindings = _selectedSeverityFilter == null
        ? _findings
        : _findings
            .where((f) => f.severity == _selectedSeverityFilter)
            .toList();

    return SingleChildScrollView(
      // Padding with 100px bottom offset to ensure full clearance above floating dock
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Status Banner (Safe to Push / N Secrets Found)
          StatusBanner(
            findings: _findings,
            isScanning: _isScanning,
            onCopyRedacted: _findings.isNotEmpty ? _copyRedactedVersion : null,
          ),

          const SizedBox(height: 16),

          // Action Toolbar: Presets dropdown, Paste, Clear, Redact
          Row(
            children: [
              // Presets Dropdown
              PopupMenuButton<String>(
                color: TerminalTheme.surface,
                tooltip: 'Load Test Samples',
                onSelected: _loadPreset,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: TerminalTheme.border),
                ),
                itemBuilder: (ctx) => _samplePresets.keys
                    .map(
                      (name) => PopupMenuItem(
                        value: name,
                        child: Row(
                          children: [
                            const Icon(Icons.code_rounded,
                                size: 16, color: TerminalTheme.infoBlue),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: TerminalTheme.fontSans(
                                fontSize: 13,
                                color: TerminalTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: TerminalTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TerminalTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 14, color: TerminalTheme.infoBlue),
                      const SizedBox(width: 6),
                      Text(
                        'Samples',
                        style: TerminalTheme.fontSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: TerminalTheme.textBright,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down,
                          size: 18, color: TerminalTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Paste Button
              IconButton.outlined(
                tooltip: 'Paste from clipboard',
                icon: const Icon(Icons.paste_rounded, size: 16),
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: TerminalTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: TerminalTheme.border),
                ),
                onPressed: _pasteFromClipboard,
              ),

              // Clear Button
              if (_textController.text.isNotEmpty) ...[
                const SizedBox(width: 6),
                IconButton.outlined(
                  tooltip: 'Clear input',
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  style: IconButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: TerminalTheme.alertRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: TerminalTheme.border),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _textController.clear();
                    _runScanImmediately('');
                  },
                ),
              ],

              const Spacer(),

              // Copy Redacted Button
              if (_findings.isNotEmpty)
                FilledButton.icon(
                  onPressed: _copyRedactedVersion,
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: Text(
                    'Copy Redacted',
                    style: TerminalTheme.fontSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: TerminalTheme.safeGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Monospace Terminal Input Box
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF090D13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TerminalTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Terminal window micro-header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: TerminalTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    border: Border(
                      bottom: BorderSide(color: TerminalTheme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: TerminalTheme.safeGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'buffer.txt',
                        style: TerminalTheme.fontMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: TerminalTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_textController.text.length} chars • ${_textController.text.split('\n').length} lines',
                        style: TerminalTheme.fontMono(
                          fontSize: 10,
                          color: TerminalTheme.textMuted,
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
                  style: TerminalTheme.fontMono(
                    fontSize: 12,
                    height: 1.5,
                    color: TerminalTheme.textBright,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Paste terminal logs, git diffs, curl commands, or .env files here...\n\nExample:\nAWS_KEY=AKIAIOSFODNN7EXAMPLE\nSTRIPE_KEY=sk_live_51Abcdef...',
                    hintStyle: TerminalTheme.fontMono(
                      fontSize: 12,
                      color: TerminalTheme.textMuted.withValues(alpha: 0.6),
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

          const SizedBox(height: 20),

          // Findings Section Header
          if (_findings.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'DETECTED SECRETS (${_findings.length})',
                  style: TerminalTheme.fontSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: TerminalTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                // Filter chips
                _buildSeverityFilterChip(null, 'ALL'),
                const SizedBox(width: 4),
                _buildSeverityFilterChip(Severity.high, 'HIGH'),
                const SizedBox(width: 4),
                _buildSeverityFilterChip(Severity.medium, 'MED'),
              ],
            ),
            const SizedBox(height: 12),

            // Findings List Cards
            ...filteredFindings.map((finding) => FindingCard(
                  key: ValueKey('${finding.type}_${finding.startIndex}'),
                  finding: finding,
                )),
          ] else if (_textController.text.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: TerminalTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TerminalTheme.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TerminalTheme.safeGreen.withValues(alpha: 0.15),
                      border: Border.all(
                        color: TerminalTheme.safeGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 26,
                      color: TerminalTheme.safeGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No Credentials Detected',
                    style: TerminalTheme.fontSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TerminalTheme.textBright,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scanned with AWS, GitHub, Google, Stripe, Slack, JWT, and Shannon entropy rules.',
                    textAlign: TextAlign.center,
                    style: TerminalTheme.fontSans(
                      fontSize: 12,
                      color: TerminalTheme.textSecondary,
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

  Widget _buildSeverityFilterChip(Severity? severity, String label) {
    final isSelected = _selectedSeverityFilter == severity;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedSeverityFilter = severity;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? TerminalTheme.borderAccent.withValues(alpha: 0.25)
              : TerminalTheme.surfaceHighlight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? TerminalTheme.borderAccent
                : TerminalTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TerminalTheme.fontMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? TerminalTheme.textBright
                : TerminalTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
