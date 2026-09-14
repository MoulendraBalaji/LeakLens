/// Service responsible for generating on-device plain-English explanations
/// of why detected credentials pose a security risk, including blast radius
/// and containment guidance.
class RiskExplainerService {
  RiskExplainerService._();
  static final RiskExplainerService instance = RiskExplainerService._();

  /// Generates a concise, plain-English explanation for why a finding is hazardous.
  String explainRisk({
    required String type,
    required String snippet,
    double? entropy,
  }) {
    final lowerType = type.toLowerCase();

    if (lowerType.contains('aws access key')) {
      return 'Grants programmatic access to AWS services. Attackers can provision rogue EC2 instances, exfiltrate private S3 data, or compromise cloud IAM.';
    }
    if (lowerType.contains('aws secret')) {
      return 'Paired with an AWS Key ID to sign API calls. Direct leak exposes root or delegated cloud infrastructure to automated bot scrapers within seconds.';
    }
    if (lowerType.contains('github')) {
      return 'Authorizes repository write access, git pushes, actions workflows, or org secrets. Enables supply-chain tampering and code extraction.';
    }
    if (lowerType.contains('google api')) {
      return 'Authorizes Google Cloud, Maps, or Firebase APIs. Can incur unlimited billing charges or expose private Firebase realtime databases.';
    }
    if (lowerType.contains('slack')) {
      return 'Grants access to internal team communications, private channels, file uploads, and bot webhooks. High risk of social engineering or corporate data leak.';
    }
    if (lowerType.contains('stripe secret')) {
      return 'Unrestricted access to Stripe merchant account. Attackers can issue unauthorized refunds, drain payouts, or siphon customer payment records.';
    }
    if (lowerType.contains('stripe publishable')) {
      return 'Client-side publishable key. Low direct threat, but should not be bundled in backend repositories or logs with customer data.';
    }
    if (lowerType.contains('private key')) {
      return 'Cryptographic private key (RSA/EC/SSH). Allows decrypting encrypted traffic, forging TLS sessions, or obtaining root SSH access to remote servers.';
    }
    if (lowerType.contains('jwt')) {
      return 'Session or bearer token containing signed user claims. If active, grants authenticated access to user account without entering credentials.';
    }
    if (lowerType.contains('database')) {
      return 'Live database connection URI with embedded credentials. Grants direct read/write access to production records and table structures.';
    }
    if (lowerType.contains('high-entropy') || lowerType.contains('env')) {
      final entStr = entropy != null ? ' (Shannon entropy: ${entropy.toStringAsFixed(2)})' : '';
      return 'Secret environment variable with high randomness$entStr. Characteristic of generated API tokens or production master passwords.';
    }
    if (lowerType.contains('bearer')) {
      return 'Bearer authorization token. Transmitted in HTTP headers to bypass login prompts; grants full API caller identity if intercepted.';
    }

    return 'High-value confidential credential. Accidental exposure allows unauthorized systems to authenticate as your service.';
  }

  /// Provides actionable mitigation advice for the user.
  String getMitigationAdvice(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('aws')) {
      return '1. Revoke key immediately in AWS IAM Console.\n2. Rotate credentials across deployed services.\n3. Add .env or credentials file to .gitignore.';
    }
    if (lowerType.contains('github')) {
      return '1. Revoke token under GitHub Settings -> Developer Settings -> Personal access tokens.\n2. Invalidate active GitHub Actions secrets.\n3. Verify repository audit logs.';
    }
    if (lowerType.contains('stripe')) {
      return '1. Roll API key under Stripe Dashboard -> Developers -> API Keys.\n2. Check Recent Events for suspicious charges.\n3. Ensure secret keys never leave server-side environments.';
    }
    if (lowerType.contains('private key')) {
      return '1. Delete the compromised private key immediately.\n2. Generate a new keypair (ssh-keygen or openssl).\n3. Replace public keys across all authorized_keys servers.';
    }
    if (lowerType.contains('slack')) {
      return '1. Invalidate token in Slack App Management.\n2. Check Slack workspace audit logs for anomalous bot calls.';
    }
    return '1. Invalidate or rotate the exposed secret immediately.\n2. Scrub git history using git-filter-repo if already committed.\n3. Verify secret is removed from shell history.';
  }

  /// Builds prompt representation for local Gemma / MediaPipe on-device LLM inference.
  String buildGemmaPrompt({
    required String secretType,
    required String redactedSnippet,
  }) {
    return '''
<start_of_turn>user
You are LeakLens on-device security auditor. In one concise sentence, explain why exposing this $secretType credential ($redactedSnippet) poses an immediate security risk and its blast radius.<end_of_turn>
<start_of_turn>model
''';
  }
}
