import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/utils/html_colors.dart';
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

  for (final brightness in Brightness.values) {
    testWidgets('a tag\'s name reads in the page\'s own text colour, its colour kept to a mark (${brightness.name})',
        (tester) async {
      const support = FlarumTag(id: '9', name: 'Support', slug: 'support', isPrimary: true, color: '#e67e22');
      const bug = FlarumTag(id: '7', name: 'bug', slug: 'bug', isPrimary: false, color: '#e74c3c');
      const plain = FlarumTag(id: '8', name: 'misc', slug: 'misc', isPrimary: false);
      final theme = brightness == Brightness.light ? AppTheme.lightTheme : AppTheme.darkTheme;
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: const Scaffold(body: Column(children: [TagLabel(tag: support), TagLabel(tag: bug), TagLabel(tag: plain)])),
      ));
      final scheme = theme.colorScheme;
      for (final name in ['Support', 'bug', 'misc']) {
        final color = tester.widget<Text>(find.text(name)).style!.color!;
        expect(color, scheme.onSurfaceVariant, reason: name);
        // Under 4.5:1 is what the old labels gave white on Flarum's orange (2.85:1).
        expect(contrastRatio(color, name == 'Support' ? scheme.surface : scheme.surfaceContainerHighest),
            greaterThanOrEqualTo(4.5), reason: name);
      }
      final mark = tester.widget<Container>(find.descendant(of: find.byType(TagMark), matching: find.byType(Container)));
      expect((mark.decoration! as BoxDecoration).color, tagMarkColor(const Color(0xFFE67E22), scheme.surface),
          reason: 'the primary tag\'s own colour, as its mark');
      final chip = tester.widget<DecoratedBox>(
          find.ancestor(of: find.text('bug'), matching: find.byType(DecoratedBox)).first);
      expect((chip.decoration as BoxDecoration).color, scheme.surfaceContainerHighest, reason: 'a neutral chip');
    });
  }

  test('text on a tag colour is whichever of white and black reads better', () {
    expect(textOn(const Color(0xFFE67E22)), Colors.black87, reason: "Flarum's orange: white was 2.85:1");
    expect(textOn(const Color(0xFF27AE60)), Colors.black87, reason: "Flarum's green: white was 2.87:1");
    expect(textOn(const Color(0xFF34495E)), Colors.white, reason: 'a dark navy');
  });

  testWidgets("a tag's description shows both its lines, at a large text size too", (tester) async {
    FixtureForum(FlarumVersion.v2, root: '../flarum_core/test/fixtures').forum();
    final site = SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );
    const description = 'Questions about installing, upgrading and running the forum, from the first steps on a '
        'new server to backups, moving hosts and the extensions that keep it going';
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final scale in [1.0, 1.5]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: FlarumLocalizations.localizationsDelegates,
        home: TagPage(
            site: site,
            tag: const FlarumTag(id: '9', name: 'Support', slug: 'support', isPrimary: true, description: description)),
      ));
      await tester.pump();
      final bar = tester.getRect(find.byType(AppBar));
      final text = tester.getRect(find.text(description));
      expect(tester.renderObject<RenderParagraph>(find.text(description)).didExceedMaxLines, isTrue,
          reason: 'a long one is cut at two lines, with an ellipsis');
      expect(text.top, greaterThanOrEqualTo(bar.top + kToolbarHeight - 0.5), reason: 'under the title at ${scale}x');
      expect(text.bottom, lessThanOrEqualTo(bar.bottom + 0.5), reason: 'inside the bar at ${scale}x');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  testWidgets("each tag shows its latest discussion, as the web's Tags page, which opens at its last post",
      (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: '../flarum_core/test/fixtures');
    final recorded = jsonDecode(File('../flarum_core/test/fixtures/v2/tags.json').readAsStringSync())['body'] as Map;
    final support = (recorded['data'] as List).cast<Map>().firstWhere((t) => t['attributes']['slug'] == 'support');
    final crashes = fixtures.discussionId('long');
    // The tags as recorded, Support's latest discussion with them.
    fixtures.replies['GET /tags'] = {
      ...recorded,
      'data': [
        for (final tag in (recorded['data'] as List).cast<Map>())
          tag == support
              ? {
                  ...tag,
                  'relationships': {
                    ...(tag['relationships'] as Map? ?? const {}),
                    'lastPostedDiscussion': {
                      'data': {'type': 'discussions', 'id': crashes},
                    },
                  },
                }
              : tag,
      ],
      'included': [
        ...(recorded['included'] as List? ?? const []),
        {
          'type': 'discussions',
          'id': crashes,
          'attributes': {'title': 'Long thread for paging tests', 'lastPostNumber': 60, 'lastPostedAt': '2026-10-08T17:52:29+00:00'},
        },
      ],
    };
    fixtures.forum();
    final site = SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: TagsPage(site: site)));
    for (var i = 0; i < 20 && find.text('Long thread for paging tests').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Long thread for paging tests'), findsOneWidget, reason: "under Support, its latest");
    await tester.tap(find.text('Long thread for paging tests'));
    for (var i = 0; i < 20 && find.byType(ThreadPage).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.widget<ThreadPage>(find.byType(ThreadPage)).near, 60, reason: 'at its last post');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
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
