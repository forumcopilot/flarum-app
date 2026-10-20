import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/l10n/generated/flarum_localizations.dart';
import 'package:flarum_ui/src/compose/tag_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';

FlarumTag _tag(String id, String name, {bool primary = true, String? parent, int? position}) => FlarumTag(
      id: id,
      name: name,
      slug: name.toLowerCase(),
      isPrimary: primary,
      isChild: parent != null,
      parentId: parent,
      position: position,
      canStartDiscussion: true,
    );

void main() {
  final general = _tag('1', 'General', position: 0);
  final support = _tag('2', 'Support', position: 1);
  final ios = _tag('3', 'iOS', parent: '2', position: 0);
  final bug = _tag('4', 'bug', primary: false);
  final question = _tag('5', 'question', primary: false);
  final tags = [general, support, ios, bug, question];
  const rules = FlarumTagRules(minPrimary: 1, maxPrimary: 1, minSecondary: 0, maxSecondary: 1);
  final l10n = lookupFlarumLocalizations(const Locale('en'));

  test('the forum\'s tag rules, with a child going with its parent', () {
    expect(tagRuleProblem([], rules, l10n), 'Choose a primary tag.');
    expect(tagRuleProblem([general], rules, l10n), isNull);
    expect(tagRuleProblem([support, ios], rules, l10n), isNull, reason: 'a child is not a second primary tag');
    expect(tagRuleProblem([general, support], rules, l10n), 'Choose only 1 primary tag.');
    expect(tagRuleProblem([general, bug, question], rules, l10n), 'Choose at most 1 more tag.');
    expect(tagRuleProblem([], null, l10n), isNull, reason: 'no flarum/tags, no rules');
    expect(tagRuleProblem([], const FlarumTagRules(minPrimary: 1, maxPrimary: 1, minSecondary: 0, maxSecondary: 0, canBypass: true), l10n),
        isNull);
  });

  testWidgets('choosing a child chooses its parent; another primary tag replaces it', (tester) async {
    List<FlarumTag>? chosen;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: FlarumLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => chosen = await TagPickerPage.open(context, tags: tags, rules: rules),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a primary tag.'), findsOneWidget);

    await tester.tap(find.text('iOS'));
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Support')).value, isTrue);

    await tester.tap(find.text('General'));
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Support')).value, isFalse);
    expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'iOS')).value, isFalse);

    await tester.tap(find.text('bug'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(chosen?.map((t) => t.name), ['General', 'bug']);
  });
}
