import 'dart:convert';
import 'dart:io';

import 'package:flarum_ui/l10n/generated/flarum_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every language has every string, with the English placeholders', () {
    Map<String, dynamic> arb(String file) => jsonDecode(File('lib/l10n/$file').readAsStringSync()) as Map<String, dynamic>;
    final english = arb('flarum_en.arb');
    final keys = english.keys.where((k) => !k.startsWith('@'));
    Set<String> placeholders(String message) => {for (final m in RegExp(r'\{(\w+)[,}]').allMatches(message)) m[1]!};
    for (final file in Directory('lib/l10n').listSync().map((f) => f.uri.pathSegments.last)) {
      if (!file.endsWith('.arb') || file == 'flarum_en.arb') continue;
      final language = arb(file);
      for (final key in keys) {
        expect(language[key], isA<String>(), reason: '$file lacks $key');
        expect(placeholders(language[key] as String), placeholders(english[key] as String), reason: '$file $key');
      }
    }
  });

  test('plurals read right in languages with more than two forms', () {
    final ru = lookupFlarumLocalizations(const Locale('ru'));
    expect(ru.userStats(1, 5), '1 обсуждение · 5 сообщений');
    expect(ru.userStats(3, 21), '3 обсуждения · 21 сообщение');
    final ja = lookupFlarumLocalizations(const Locale('ja'));
    expect(ja.repliedByMore('alice', 'bob', 3), 'alice、bobほか3件の返信があります。');
    final de = lookupFlarumLocalizations(const Locale('de'));
    expect(de.eventRenamed('alice', 'Alt', 'Neu'), 'alice hat den Titel von „Alt“ in „Neu“ geändert.');
  });
}
