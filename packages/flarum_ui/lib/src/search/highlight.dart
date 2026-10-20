import 'package:flutter/painting.dart';

/// The words of [query] worth marking: two letters or more, without duplicates.
List<String> queryWords(String query) =>
    {for (final word in query.toLowerCase().split(RegExp(r'\s+'))) if (word.length >= 2) word}.toList();

/// [text] with every word of [query] in bold, as the web's search marks its results.
List<TextSpan> highlighted(String text, String query, {TextStyle? bold}) {
  final words = queryWords(query);
  if (words.isEmpty || text.isEmpty) return [TextSpan(text: text)];
  final pattern = RegExp(words.map(RegExp.escape).join('|'), caseSensitive: false);
  final spans = <TextSpan>[];
  var at = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > at) spans.add(TextSpan(text: text.substring(at, match.start)));
    spans.add(TextSpan(text: match.group(0), style: bold ?? const TextStyle(fontWeight: FontWeight.w700)));
    at = match.end;
  }
  if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
  return spans;
}

/// About [length] characters of [text] around the first word of [query] it holds, with an ellipsis
/// where it was cut, as the web's `highlight(text, query, 175)` shows a result; its start when
/// no word is in it.
String excerptAround(String text, String query, {int length = 175}) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.length <= length) return flat;
  final words = queryWords(query);
  var first = -1;
  for (final word in words) {
    final i = flat.toLowerCase().indexOf(word);
    if (i >= 0 && (first < 0 || i < first)) first = i;
  }
  if (first < 0) return '${flat.substring(0, length).trimRight()}…';
  final start = (first - length ~/ 3).clamp(0, flat.length - length);
  final end = start + length;
  return '${start > 0 ? '…' : ''}${flat.substring(start, end).trim()}${end < flat.length ? '…' : ''}';
}
