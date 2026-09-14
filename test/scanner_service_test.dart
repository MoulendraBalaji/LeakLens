import 'package:flutter_test/flutter_test.dart';
import 'package:leak_lens/models/finding.dart';
import 'package:leak_lens/services/scanner_service.dart';

void main() {
  group('Shannon Entropy Calculation', () {
    test('Calculates zero entropy for uniform strings', () {
      expect(ScannerService.calculateShannonEntropy(''), 0.0);
      expect(ScannerService.calculateShannonEntropy('aaaaaaaaaaaa'), 0.0);
    });

    test('Calculates low entropy for repetitive text', () {
      final ent = ScannerService.calculateShannonEntropy('abcabcabcabc');
      expect(ent, lessThan(2.0));
    });

    test('Calculates high entropy for random secret keys', () {
      // 32-char random hex/alphanumeric key
      final ent = ScannerService.calculateShannonEntropy('9f8A!2bC#8xL0qWz@4mK7vP1');
      expect(ent, greaterThan(3.5));
    });
  });

  group('Redaction Masking Helper', () {
    test('Redacts >8 char string with first 4 and last 4 characters preserved', () {
      final redacted = Finding.redactSnippet('AKIAIOSFODNN7EXAMPLE');
      expect(redacted.startsWith('AKIA'), isTrue);
      expect(redacted.endsWith('MPLE'), isTrue);
      expect(redacted.contains('•'), isTrue);
      expect(redacted.length, equals(20));
      expect(redacted, equals('AKIA••••••••••••MPLE'));
    });

    test('Handles short strings gracefully without crashing', () {
      expect(Finding.redactSnippet(''), equals('••••••••'));
      expect(Finding.redactSnippet('abc'), equals('••••••••'));
      expect(Finding.redactSnippet('12345678'), equals('1••••••8'));
    });
  });

  group('Detector Patterns', () {
    final scanner = ScannerService.instance;

    test('Detects AWS Access Key ID', () {
      const text = 'export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE';
      final findings = scanner.scanText(text);
      expect(findings.length, greaterThanOrEqualTo(1));
      final finding = findings.firstWhere((f) => f.type.contains('AWS Access Key ID'));
      expect(finding.matchedText, equals('AKIAIOSFODNN7EXAMPLE'));
      expect(finding.redactedText, equals('AKIA••••••••••••MPLE'));
      expect(finding.severity, equals(Severity.high));
      expect(finding.lineNumber, equals(1));
    });

    test('Detects GitHub Classic and Fine-Grained PATs', () {
      const text = '''
# Test Config
GITHUB_TOKEN=ghp_123456789012345678901234567890123456
NEW_TOKEN=github_pat_11ABCD123456789012345678901234567890123456789012345678901234567890123456789012
''';
      final findings = scanner.scanText(text);
      expect(findings.length, equals(2));
      expect(findings[0].type, contains('GitHub'));
      expect(findings[0].lineNumber, equals(2));
      expect(findings[1].type, contains('GitHub'));
      expect(findings[1].lineNumber, equals(3));
    });

    test('Detects Google API Key', () {
      const text = 'const apiKey = "AIzaSyD-1234567890abcdefghijklmnopqrst";';
      final findings = scanner.scanText(text);
      expect(findings.length, equals(1));
      expect(findings.first.type, equals('Google API Key'));
      expect(findings.first.matchedText, equals('AIzaSyD-1234567890abcdefghijklmnopqrst'));
      expect(findings.first.severity, equals(Severity.high));
    });

    test('Detects Slack bot and user tokens', () {
      const text = 'SLACK_BOT_TOKEN="xoxb-9999999999mocktokenforexample9999"';
      final findings = scanner.scanText(text);
      expect(findings.length, greaterThanOrEqualTo(1));
      expect(findings.first.type, equals('Slack Token'));
      expect(findings.first.severity, equals(Severity.high));
    });

    test('Detects Stripe Live Secret and Publishable keys', () {
      const text = '''
STRIPE_SECRET=sk_test_51Abcdefghijklmnopqrstuvwx987654321
STRIPE_PUBLIC=pk_test_51Abcdefghijklmnopqrstuvwx987654321
''';
      final findings = scanner.scanText(text);
      expect(findings.length, equals(2));
      final secret = findings.firstWhere((f) => f.type.contains('Secret'));
      final publishable = findings.firstWhere((f) => f.type.contains('Publishable'));

      expect(secret.severity, equals(Severity.high));
      expect(publishable.severity, equals(Severity.medium));
    });

    test('Detects Private Key PEM block', () {
      const text = '''
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0mY8...
fake_private_key_content_here
-----END RSA PRIVATE KEY-----
''';
      final findings = scanner.scanText(text);
      expect(findings.length, equals(1));
      expect(findings.first.type, equals('Private Key Block'));
      expect(findings.first.severity, equals(Severity.high));
    });

    test('Detects JSON Web Token (JWT)', () {
      const text = 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      final findings = scanner.scanText(text);
      expect(findings.length, greaterThanOrEqualTo(1));
      expect(findings.any((f) => f.type.contains('JWT') || f.type.contains('Bearer')), isTrue);
    });

    test('Detects High-Entropy .env values on secret variable names', () {
      const text = '''
DATABASE_PASSWORD=z9#kL2!vP0@xQ8^mC4&wR1
APP_NAME=my_awesome_application
''';
      final findings = scanner.scanText(text);
      expect(findings.length, equals(1));
      expect(findings.first.type, contains('High-Entropy'));
      expect(findings.first.matchedText, equals('z9#kL2!vP0@xQ8^mC4&wR1'));
    });

    test('Does not flag low-entropy standard variables', () {
      const text = '''
APP_DEBUG=true
PORT=8080
ENVIRONMENT=production
USER_SECRET_NAME=short
LOW_ENTROPY_KEY=aaaaaaaaaaaa
''';
      final findings = scanner.scanText(text);
      expect(findings.isEmpty, isTrue);
    });
  });

  group('In-Place Document Redaction', () {
    final scanner = ScannerService.instance;

    test('Generates safe redacted document replacing secrets', () {
      const text = '''
AWS_KEY=AKIAIOSFODNN7EXAMPLE
GITHUB_PAT=ghp_123456789012345678901234567890123456
PORT=3000
''';
      final findings = scanner.scanText(text);
      expect(findings.length, equals(2));

      final redactedDoc = scanner.generateRedactedDocument(text, findings);
      expect(redactedDoc.contains('AKIAIOSFODNN7EXAMPLE'), isFalse);
      expect(redactedDoc.contains('ghp_123456789012345678901234567890123456'), isFalse);
      expect(redactedDoc.contains('AKIA••••••••••••MPLE'), isTrue);
      expect(redactedDoc.contains(Finding.redactSnippet('ghp_123456789012345678901234567890123456')), isTrue);
      expect(redactedDoc.contains('PORT=3000'), isTrue);
    });
  });
}
