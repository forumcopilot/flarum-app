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
    // A plural's branches (`=1{post}`, `other{posts}`) follow a word or `=1`; placeholders don't.
    Set<String> placeholders(String message) =>
        {for (final m in RegExp(r'(?<![=A-Za-z0-9_])\{(\w+)[,}]').allMatches(message)) m[1]!};
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

  test('a phone in a language the app lacks gets English, not the first language in the list', () {
    // Flutter falls back to the first supported locale; l10n.yaml puts English first.
    expect(FlarumLocalizations.supportedLocales.first, const Locale('en'));
    expect(basicLocaleListResolution(const [Locale('sv', 'SE')], FlarumLocalizations.supportedLocales), const Locale('en'));
    expect(basicLocaleListResolution(const [Locale('de', 'AT')], FlarumLocalizations.supportedLocales), const Locale('de'));
  });
}
