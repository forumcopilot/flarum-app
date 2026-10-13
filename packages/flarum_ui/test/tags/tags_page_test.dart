import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  setUp(FlarumForum.resetForTesting);

  testWidgets('a forum without flarum/tags says so on the Tags tab, not that loading failed', (tester) async {
    final adapter = ScriptedAdapter([(404, errors('404', 'not_found'))]);
    FlarumForum.forTesting(FixtureForum.baseUrl, adapter.dio());
    final site = SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'No tags', baseUrl: FixtureForum.baseUrl).toSite(),
    );
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: TagsPage(site: site)));
    for (var i = 0; i < 20 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text("This forum doesn't use tags."), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  for (final version in FlarumVersion.values) {
    testWidgets('Flarum ${version.name}: a tag link opens the tag in the app, by its slug', (tester) async {
      FixtureForum(version, root: '../flarum_core/test/fixtures').forum();
      final site = SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );
      final opened = <String, bool>{};
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: FlarumLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Column(children: [
            for (final slug in ['general', 'no-such-tag'])
              TextButton(
                onPressed: () async => opened[slug] = await TagPage.openBySlug(context, site, slug),
                child: Text(slug),
              ),
          ]),
        ),
      ));
      await tester.tap(find.text('no-such-tag'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(opened['no-such-tag'], isFalse, reason: 'left for the web');

      await tester.tap(find.text('general'));
      for (var i = 0; i < 20 && find.byType(TagPage).evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(opened['general'], isTrue);
      expect(find.byType(TagPage), findsOneWidget);
    });
  }
}
