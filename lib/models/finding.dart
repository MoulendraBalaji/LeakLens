import 'package:flutter/material.dart';

/// Severity levels for detected credential leaks.
enum Severity {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case Severity.high:
        return 'HIGH';
      case Severity.medium:
        return 'MEDIUM';
      case Severity.low:
        return 'LOW';
    }
  }

  Color get color {
    switch (this) {
      case Severity.high:
        return const Color(0xFFF85149); // Terminal alert red
      case Severity.medium:
        return const Color(0xFFD29922); // Terminal warning amber
      case Severity.low:
        return const Color(0xFF58A6FF); // Terminal info blue
    }
  }

  Color get backgroundColor {
    switch (this) {
      case Severity.high:
        return const Color(0x26F85149);
      case Severity.medium:
        return const Color(0x26D29922);
      case Severity.low:
        return const Color(0x2658A6FF);
    }
  }

  IconData get icon {
    switch (this) {
      case Severity.high:
        return Icons.dangerous_rounded;
      case Severity.medium:
        return Icons.warning_amber_rounded;
      case Severity.low:
        return Icons.info_outline_rounded;
    }
  }
}

/// A credential leak finding detected by LeakLens.
class Finding {
  final String type;
  final String matchedText;
  final String redactedText;
  final int lineNumber;
  final Severity severity;
  final String explanation;
  final int startIndex;
  final int endIndex;
  final String? contextLine;

  const Finding({
    required this.type,
    required this.matchedText,
    required this.redactedText,
    required this.lineNumber,
    required this.severity,
    required this.explanation,
    required this.startIndex,
    required this.endIndex,
    this.contextLine,
  });

  /// Factory helper that automatically redacts the secret with the 4-prefix/4-suffix mask.
  factory Finding.create({
    required String type,
    required String matchedText,
    required int lineNumber,
    required Severity severity,
    required String explanation,
    required int startIndex,
    required int endIndex,
    String? contextLine,
  }) {
    final redacted = redactSnippet(matchedText);
    return Finding(
      type: type,
      matchedText: matchedText,
      redactedText: redacted,
      lineNumber: lineNumber,
      severity: severity,
      explanation: explanation,
      startIndex: startIndex,
      endIndex: endIndex,
      contextLine: contextLine,
    );
  }

  /// Redacts a string by preserving only the first 4 and last 4 characters,
  /// masking the remainder with bullet points (•).
  static String redactSnippet(String text) {
    if (text.isEmpty) return '••••••••';
    if (text.length <= 8) {
      if (text.length <= 4) {
        return '••••••••';
      }
      final prefix = text.substring(0, 1);
      final suffix = text.substring(text.length - 1);
      final bullets = '•' * (text.length - 2);
      return '$prefix$bullets$suffix';
    }

    final prefix = text.substring(0, 4);
    final suffix = text.substring(text.length - 4);
    final bullets = '•' * (text.length - 8);
    return '$prefix$bullets$suffix';
  }

  @override
  String toString() =>
      'Finding($type, line $lineNumber, $severity: $redactedText)';
}
