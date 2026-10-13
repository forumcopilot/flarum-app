import 'package:flutter/services.dart' show TextEditingValue, TextSelection;

/// Formatting-toolbar actions, in the markup Flarum formats: Markdown (flarum/markdown), with
/// BBCode (flarum/bbcode) only where Markdown has no spelling, as for underline. Adapted from
/// discourse_ui's DiscourseMarkup.
///
/// Spoilers are Flarum's own Markdown: `>!` before each line of a block, `||` around inline
/// words. BBCode's `[spoiler]` stays literal text on a stock forum, and so does `[video]`: a
/// video's link alone on its line is what fof/formatting's MediaEmbed turns into a player.
class FlarumMarkup {
  const FlarumMarkup._();

  /// The toolbar actions this class emits. A toolbar offers no other: [apply] returns the value
  /// untouched for anything else, which reads as a dead button.
  static const Set<String> supportedActions = <String>{
    'B', 'I', 'U', 'S', 'URL', 'IMG', 'VIDEO', 'QUOTE', 'CODE', 'SPOILER', 'LIST', 'LIST=1', '*',
  };

  /// Applies [tag] to [value]: wraps the selection when there is one, else inserts empty markers
  /// with the cursor between them. The value unchanged for an unknown tag.
  static TextEditingValue apply(TextEditingValue value, String tag) {
    final start = value.selection.start;
    final end = value.selection.end;
    final selectedText = (start >= 0 && end > start) ? value.text.substring(start, end) : '';

    // Markdown marks these line by line.
    if (tag == 'LIST' || tag == 'LIST=1' || tag == '*') return _applyLines(value, tag, selectedText);
    if (tag == 'QUOTE' || (tag == 'SPOILER' && selectedText.contains('\n'))) {
      return _applyLines(value, tag, selectedText);
    }

    final markers = _markersFor(tag, selectedText);
    if (markers == null) return value;
    final (:prefix, :suffix) = markers;

    // start < 0: no cursor in the field; append.
    if (start < 0) {
      final newText = '${value.text}$prefix$suffix';
      return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newText.length - suffix.length));
    }
    final String newText;
    final int cursor;
    if (start == end) {
      newText = value.text.replaceRange(start, start, '$prefix$suffix');
      cursor = start + prefix.length;
    } else {
      newText = value.text.replaceRange(start, end, '$prefix$selectedText$suffix');
      cursor = start + prefix.length + selectedText.length + suffix.length;
    }
    return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: cursor.clamp(0, newText.length)));
  }

  static ({String prefix, String suffix})? _markersFor(String tag, String selectedText) => switch (tag) {
        'B' => (prefix: '**', suffix: '**'),
        'I' => (prefix: '*', suffix: '*'),
        // Markdown has no underline; flarum/bbcode has [u].
        'U' => (prefix: '[u]', suffix: '[/u]'),
        'S' => (prefix: '~~', suffix: '~~'),
        'URL' => (prefix: '[', suffix: '](url)'),
        'IMG' => (prefix: '![](', suffix: ')'),
        'VIDEO' => (prefix: '\n', suffix: '\n'),
        'CODE' => selectedText.contains('\n') ? (prefix: '```\n', suffix: '\n```') : (prefix: '`', suffix: '`'),
        'SPOILER' => (prefix: '||', suffix: '||'),
        _ => null,
      };

  /// Lists, quotes and block spoilers: a marker at the start of each selected line, or a starter
  /// marker on a line of its own.
  static TextEditingValue _applyLines(TextEditingValue value, String tag, String selectedText) {
    final start = value.selection.start;
    final end = value.selection.end;
    final insertAt = start < 0 ? value.text.length : start;
    String marker(int n) => switch (tag) {
          'LIST=1' => '$n. ',
          'QUOTE' => '> ',
          'SPOILER' => '>! ',
          _ => '- ',
        };

    var replacement = StringBuffer();
    if (selectedText.isNotEmpty) {
      var n = 1;
      for (final line in selectedText.split('\n')) {
        if (line.trim().isEmpty && tag != 'QUOTE' && tag != 'SPOILER') continue;
        replacement.writeln('${marker(n++)}${line.trimRight()}');
      }
    } else {
      replacement.write(marker(1));
    }
    var text = replacement.toString();
    // A marker starts a line.
    if (insertAt > 0 && value.text[insertAt - 1] != '\n') text = '\n$text';

    final newText = value.text.replaceRange(insertAt, start < 0 ? insertAt : end, text);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: (insertAt + text.length).clamp(0, newText.length)),
    );
  }

  /// A user mention as flarum/mentions writes it: `@"Display name"#id`.
  static String userMention(String displayName, String userId) => '@"${_name(displayName)}"#$userId';

  /// A reply to a post, as the web's Reply button starts one: `@"Display name"#p<post id>`.
  static String postMention(String displayName, String postId) => '@"${_name(displayName)}"#p$postId';

  /// A quote of a post as the web's Quote button writes it: the post mention, then the words,
  /// every line behind `> `, and a blank line to write under.
  static String quote(String displayName, String postId, String text) {
    final lines = text.trim().split('\n');
    return '> ${postMention(displayName, postId)} ${lines.join('\n> ')}\n\n';
  }

  /// A display name inside the mention's quotes: a `"` in it would end them.
  static String _name(String displayName) => displayName.replaceAll('"', "'");
}
