/// Cleans raw OCR output so credential regexes and entropy analysis see the
/// actual characters instead of invisible glyphs ML Kit sometimes injects.
///
/// Conservative by design — only removes known-invisible punctuation and
/// trailing layout whitespace. Never reorders or rewrites real characters.
class OcrTextCleaner {
  OcrTextCleaner._();

  /// Removes soft-hyphens, zero-width joins/spaces, non-breaking spaces and
  /// trims trailing whitespace from every line.
  static String clean(String text) {
    if (text.isEmpty) return text;

    var t = text
        .replaceAll('\u00ad', '') // SOFT HYPHEN
        .replaceAll('\u200b', '') // ZERO WIDTH SPACE
        .replaceAll('\u200c', '') // ZERO WIDTH NON-JOINER
        .replaceAll('\u200d', '') // ZERO WIDTH JOINER
        .replaceAll('\ufeff', '') // ZERO WIDTH NO-BREAK SPACE
        .replaceAll('\u00a0', ' '); // NBSP -> regular space

    final lines = t
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'[ \t]+\n?$'), ''))
        .toList();

    return lines.join('\n').trim();
  }
}