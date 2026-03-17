class StringUtils {
  /// Unescapes common HTML entities that might be returned by the backend
  /// due to sanitization (e.g., &#x27; for single quote).
  static String unescapeHtml(String? text) {
    if (text == null || text.isEmpty) return '';

    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&#96;', '`');
  }
}
