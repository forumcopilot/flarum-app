/// Rendered post HTML as plain text: tags dropped, block ends as line
/// breaks, the common entities decoded. Good enough to quote from.
String plainText(String html) {
  var text = html
      .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|li|h\d|blockquote|pre)>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');
  const entities = {'&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&#39;': "'", '&nbsp;': ' '};
  entities.forEach((entity, char) => text = text.replaceAll(entity, char));
  return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

/// [text] cut to [length] characters at most, as Flarum's `truncate` cuts an excerpt: the cut
/// marked with an ellipsis.
String truncateText(String text, int length) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return flat.length <= length ? flat : '${flat.substring(0, length)}...';
}

/// A post's opening words as Flarum shows them in a list (flarum/sticky's excerpt): its text, cut
/// at 175 characters; null when there's none.
String? flarumExcerpt(String? html) {
  if (html == null) return null;
  final text = truncateText(plainText(html), 175);
  return text.isEmpty ? null : text;
}
