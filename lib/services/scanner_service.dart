import 'dart:math' as math;
import '../models/finding.dart';
import 'risk_explainer_service.dart';

/// Core detection engine for LeakLens.
/// Analyzes text entirely on-device using regex patterns, heuristic parsers,
/// and Shannon entropy calculations.
class ScannerService {
  ScannerService._();
  static final ScannerService instance = ScannerService._();

  // -------------------------------------------------------------
  // Regular Expressions for Known Credential Patterns
  // -------------------------------------------------------------

  /// AWS Access Key ID: AKIA followed by 16 alphanumeric uppercase chars
  static final RegExp _awsAccessKeyRegex =
      RegExp(r'\bAKIA[0-9A-Z]{16}\b');

  /// AWS Secret Access Key: often paired with aws_secret_access_key or secret_key
  static final RegExp _awsSecretKeyLabeledRegex = RegExp(
      r'''(?:aws_secret_access_key|aws_secret_key|secret_access_key|aws_secret)\s*[:=]\s*['"]?([A-Za-z0-9/+=]{40})['"]?''',
      caseSensitive: false);

  /// GitHub Personal Access Tokens (Classic, Fine-Grained, and OAuth)
  static final RegExp _githubTokenRegex = RegExp(
      r'\b(?:ghp_[a-zA-Z0-9]{36,40}|github_pat_[a-zA-Z0-9_]{20,85}|gho_[a-zA-Z0-9]{36,40}|ghu_[a-zA-Z0-9]{36,40}|ghs_[a-zA-Z0-9]{36,40}|ghr_[a-zA-Z0-9]{36,40})\b');

  /// Google API Key: AIza followed by 34 to 35 characters
  static final RegExp _googleApiKeyRegex =
      RegExp(r'\bAIza[0-9A-Za-z\-_]{34,35}\b');

  /// Slack Tokens: user, bot, app, refresh tokens
  static final RegExp _slackTokenRegex =
      RegExp(r'\bxox[baprs]-[0-9a-zA-Z]{10,48}\b');

  /// Stripe Keys: Secret and Restricted (High), Publishable (Medium)
  static final RegExp _stripeSecretKeyRegex =
      RegExp(r'\b(?:sk_live|rk_live|sk_test)_[0-9a-zA-Z]{24,99}\b');
  static final RegExp _stripePublishableKeyRegex =
      RegExp(r'\b(?:pk_live|pk_test)_[0-9a-zA-Z]{24,99}\b');

  /// Private Key Blocks (RSA, EC, DSA, OpenSSH)
  static final RegExp _privateKeyBlockRegex = RegExp(
      r'-----BEGIN (?:[A-Z0-9_-]+ )?PRIVATE KEY-----[\s\S]*?-----END (?:[A-Z0-9_-]+ )?PRIVATE KEY-----');

  /// JSON Web Tokens (JWT): Three base64url segments separated by dots
  static final RegExp _jwtRegex = RegExp(
      r'\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b');

  /// Database Connection URI tokens (scheme://...). The exact credential
  /// portion is parsed separately because passwords can legitimately contain
  /// '@' — a naive regex that stops at the first '@' leaks the rest.
  static final RegExp _dbUriCandidateRegex = RegExp(
      r'\b(?:postgres|postgresql|mysql|mongodb|redis|mssql|oracle|sqlite|amqp|rediss)(?:\+[a-z0-9]+)?://\S+',
      caseSensitive: false);

  /// Generic Bearer token in headers or logs
  static final RegExp _bearerTokenRegex = RegExp(
      r'''(?:bearer|authorization:\s*bearer)\s+([a-zA-Z0-9_\-\.]{24,})''',
      caseSensitive: false);

  /// .env line pattern: KEY=VALUE or KEY: VALUE (quoted or unquoted)
  static final RegExp _envLineRegex = RegExp(
      r'''^\s*(?:export\s+)?([A-Za-z0-9_]+)\s*[:=]\s*(?:["']([^"'\r\n]+)["']|([^\r\n\s]+))''',
      multiLine: true);

  /// Key names that strongly suggest credentials
  static final RegExp _sensitiveKeyNameRegex = RegExp(
      r'(.*_)?(SECRET|KEY|TOKEN|PASSWORD|PASSWD|AUTH|PRIVATE|CREDENTIAL|APIKEY|API_KEY|ACCESS_KEY|CLIENT_SECRET)(.*)?',
      caseSensitive: false);

  // -------------------------------------------------------------
  // Shannon Entropy Calculation
  // -------------------------------------------------------------

  /// Calculates Shannon entropy of an input string in bits.
  /// Formula: H = - sum(p_i * log2(p_i))
  static double calculateShannonEntropy(String input) {
    if (input.isEmpty) return 0.0;

    final freqMap = <int, int>{};
    for (final unit in input.codeUnits) {
      freqMap[unit] = (freqMap[unit] ?? 0) + 1;
    }

    final len = input.length.toDouble();
    double entropy = 0.0;
    final log2Const = math.log(2);

    for (final count in freqMap.values) {
      final p = count / len;
      entropy -= p * (math.log(p) / log2Const);
    }

    return entropy;
  }

  // -------------------------------------------------------------
  // Main Detection Function: scanText
  // -------------------------------------------------------------

  /// Scans the given input text entirely on-device and returns a list of [Finding]s.
  List<Finding> scanText(String text) {
    if (text.trim().isEmpty) {
      return const [];
    }

    final findings = <Finding>[];

    // Helper to extract line number from start index
    int getLineNumber(int index) {
      if (index <= 0) return 1;
      final sub = text.substring(0, index);
      return '\n'.allMatches(sub).length + 1;
    }

    // Helper to get line content
    String getContextLine(int startIndex, int endIndex) {
      final lineStart = text.lastIndexOf('\n', startIndex) + 1;
      int lineEnd = text.indexOf('\n', endIndex);
      if (lineEnd == -1) lineEnd = text.length;
      return text.substring(lineStart, lineEnd).trim();
    }

    // 1. AWS Access Key ID
    for (final match in _awsAccessKeyRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'AWS Access Key ID',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'AWS Access Key', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 2. AWS Secret Access Key (labeled)
    for (final match in _awsSecretKeyLabeledRegex.allMatches(text)) {
      final matchedText = match.group(1)!;
      final start = match.start + match.group(0)!.indexOf(matchedText);
      final end = start + matchedText.length;
      findings.add(Finding.create(
        type: 'AWS Secret Access Key',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'AWS Secret Key', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 3. GitHub Personal Access Tokens
    for (final match in _githubTokenRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'GitHub Personal Access Token',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'GitHub Token', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 4. Google API Key
    for (final match in _googleApiKeyRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'Google API Key',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'Google API Key', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 5. Slack Tokens
    for (final match in _slackTokenRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'Slack Token',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'Slack Token', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 6. Stripe Keys (Secret vs Publishable)
    for (final match in _stripeSecretKeyRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'Stripe Secret Key',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'Stripe Secret Key', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }
    for (final match in _stripePublishableKeyRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'Stripe Publishable Key',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.medium,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'Stripe Publishable Key', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 7. Private Key PEM Blocks
    for (final match in _privateKeyBlockRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'Private Key Block',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'Private Key', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 8. JSON Web Tokens (JWT)
    for (final match in _jwtRegex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final start = match.start;
      final end = match.end;
      findings.add(Finding.create(
        type: 'JSON Web Token (JWT)',
        matchedText: matchedText,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'JWT', snippet: matchedText),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 9. Database Connection URIs (password-aware parser)
    for (final match in _dbUriCandidateRegex.allMatches(text)) {
      final token = match.group(0)!;
      final schemeEnd = token.indexOf('://');
      if (schemeEnd <= 0) continue;
      final restStart = schemeEnd + 3;
      if (restStart >= token.length) continue;

      final rest = token.substring(restStart);
      // Passwords may contain '@' — the real separator is the LAST '@'
      // (everything after it up to whitespace is the host[:port]/path).
      final lastAt = rest.lastIndexOf('@');
      if (lastAt < 0) continue;

      final userinfo = rest.substring(0, lastAt);
      final colon = userinfo.indexOf(':');
      if (colon < 0) continue;

      final pass = userinfo.substring(colon + 1);
      if (pass.isEmpty) continue;

      final passIndexInToken = restStart + colon + 1;
      final start = match.start + passIndexInToken;
      final end = start + pass.length;
      findings.add(Finding.create(
        type: 'Database Password',
        matchedText: pass,
        lineNumber: getLineNumber(start),
        severity: Severity.high,
        explanation: RiskExplainerService.instance
            .explainRisk(type: 'Database Password', snippet: pass),
        startIndex: start,
        endIndex: end,
        contextLine: getContextLine(start, end),
      ));
    }

    // 10. Generic Bearer Tokens
    for (final match in _bearerTokenRegex.allMatches(text)) {
      final token = match.group(1);
      if (token != null && token.length >= 24) {
        final start = match.start + match.group(0)!.indexOf(token);
        final end = start + token.length;
        findings.add(Finding.create(
          type: 'Bearer Token',
          matchedText: token,
          lineNumber: getLineNumber(start),
          severity: Severity.high,
          explanation: RiskExplainerService.instance
              .explainRisk(type: 'Bearer Token', snippet: token),
          startIndex: start,
          endIndex: end,
          contextLine: getContextLine(start, end),
        ));
      }
    }

    // 11. .env-style KEY=VALUE lines with Shannon Entropy Analysis
    for (final match in _envLineRegex.allMatches(text)) {
      final key = match.group(1) ?? '';
      final val = match.group(2) ?? match.group(3) ?? '';

      if (key.isNotEmpty && val.length >= 12) {
        // Check if key name matches secret heuristics
        if (_sensitiveKeyNameRegex.hasMatch(key)) {
          final entropy = calculateShannonEntropy(val);
          // Entropy threshold > 3.5 as requested
          if (entropy > 3.5) {
            final fullMatch = match.group(0)!;
            final valIdxInMatch = fullMatch.lastIndexOf(val);
            final start = match.start + (valIdxInMatch != -1 ? valIdxInMatch : 0);
            final end = start + val.length;

            findings.add(Finding.create(
              type: 'High-Entropy Secret ($key)',
              matchedText: val,
              lineNumber: getLineNumber(start),
              severity: entropy > 4.2 ? Severity.high : Severity.medium,
              explanation: RiskExplainerService.instance.explainRisk(
                type: 'High-Entropy Env Secret',
                snippet: val,
                entropy: entropy,
              ),
              startIndex: start,
              endIndex: end,
              contextLine: getContextLine(start, end),
            ));
          }
        }
      }
    }

    // De-duplicate overlapping findings (preferring earlier, more specific findings)
    findings.sort((a, b) => a.startIndex.compareTo(b.startIndex));
    final resolved = <Finding>[];

    for (final f in findings) {
      bool overlaps = false;
      for (final existing in resolved) {
        if (!(f.endIndex <= existing.startIndex ||
            f.startIndex >= existing.endIndex)) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) {
        resolved.add(f);
      }
    }

    return resolved;
  }

  // -------------------------------------------------------------
  // In-Place Document Redaction
  // -------------------------------------------------------------

  /// Replaces all detected secrets in the document with their redacted
  /// representations (first 4 + last 4 + •), leaving non-secret code,
  /// formatting, and structure intact for safe sharing.
  String generateRedactedDocument(String originalText, List<Finding> findings) {
    if (originalText.isEmpty || findings.isEmpty) return originalText;

    // Sort findings descending by startIndex so replacements don't shift offsets
    final sorted = List<Finding>.from(findings)
      ..sort((a, b) => b.startIndex.compareTo(a.startIndex));

    String result = originalText;
    for (final finding in sorted) {
      if (finding.startIndex >= 0 &&
          finding.endIndex <= result.length &&
          finding.startIndex <= finding.endIndex) {
        final before = result.substring(0, finding.startIndex);
        final after = result.substring(finding.endIndex);
        result = '$before${finding.redactedText}$after';
      }
    }

    return result;
  }
}
