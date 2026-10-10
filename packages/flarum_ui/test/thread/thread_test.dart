import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

const _fixtures = '../flarum_core/test/fixtures';

SiteContext _site() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: Site(
        id: null,
        name: 'Test forum',
        url: FixtureForum.baseUrl,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: FixtureForum.baseUrl,
        siteType: FlarumProxyFactory.siteType,
        language: null,
      ),
    );

/// Pumps until [finder] shows (or, with [gone], stops showing), for pages
/// that load from the fixtures.
Future<void> _pumpUntil(WidgetTester tester, Finder finder, {bool gone = false}) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty != gone; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, gone ? findsNothing : findsWidgets);
}

/// Closes the page and lets what it sends on the way out (the read mark) finish.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUp(FlarumForum.resetForTesting);

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version, root: _fixtures));

      test('a thread opens at its start and pages forward', () async {
        final model = ThreadModel(fixtures.forum(), fixtures.discussionId('long'));
        await model.open();
        expect(model.total, 60);
        expect(model.posts.map((p) => p.number), List.generate(20, (i) => i + 1));
        expect(model.hasPrevious, isFalse);
        expect(model.hasNext, isTrue);

        await model.loadNext();
        expect(model.posts.map((p) => p.number), List.generate(40, (i) => i + 1));
        model.dispose();
      });

      test('a thread opened at a post pages both ways from there', () async {
        final model = ThreadModel(fixtures.forum(), fixtures.discussionId('long'));
        await model.open(near: 21);
        expect(model.indexOfNumber(21), greaterThanOrEqualTo(0));
        expect(model.start, greaterThan(0));
        final start = model.start;

        expect(await model.loadPrevious(), start);
        expect(model.start, 0);
        expect(model.posts.first.number, 1);

        await model.loadNext();
        expect(model.posts.map((p) => p.number), List.generate(model.posts.length, (i) => i + 1),
            reason: 'one run of posts, no gaps or repeats');
        model.dispose();
      });

      test('reading is reported once it pauses, and only forward', () async {
        final model = ThreadModel(fixtures.forum(), fixtures.discussionId('long'), readDelay: Duration.zero);
        await model.open();
        model
          ..reportRead(15) // alice has read up to 20 already
          ..reportRead(24)
          ..reportRead(26);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final marks = fixtures.requests.where((r) => r.method == 'PATCH').toList();
        expect(marks, hasLength(1));
        expect(((marks.single.data as Map)['data'] as Map)['attributes'], {'lastReadPostNumber': 26});
        model.dispose();
      });

      test('a guest\'s reading is not reported', () async {
        final model = ThreadModel(fixtures.forum(signedIn: false), fixtures.discussionId('welcome'), readDelay: Duration.zero);
        model.reportRead(3);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(fixtures.requests.where((r) => r.method == 'PATCH'), isEmpty);
        model.dispose();
      });

      testWidgets('the page shows the posts, their authors and bodies', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.byType(PostTile));
        expect(find.text('Welcome to the test forum'), findsOneWidget, reason: 'the title');
        expect(find.byType(FlarumContent), findsWidgets);
        expect(find.text('admin'), findsWidgets);
        await _close(tester);
      });

      testWidgets('who replied to a post, and the list of replies', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.text('bob and alice replied to this.'));
        await tester.tap(find.text('bob and alice replied to this.'));
        await _pumpUntil(tester, find.text('Replies'));
        expect(find.text('Post #3'), findsOneWidget, reason: "bob's reply, in this discussion");
        expect(find.text('Formatting samples'), findsWidgets, reason: "alice's, in another one");
        await tester.tap(find.text('Post #3'));
        await tester.pump(const Duration(seconds: 1));
        await _close(tester);
      });

      testWidgets('opened part-way down, it offers the posts before', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('long'), near: 21),
        ));
        await _pumpUntil(tester, find.text('Post 21 of 60.'));
        await tester.drag(find.byType(PostTile).first, const Offset(0, 2000));
        await tester.pump();
        await _pumpUntil(tester, find.text('Load earlier posts'));
        await tester.tap(find.text('Load earlier posts'));
        await _pumpUntil(tester, find.text('Load earlier posts'), gone: true);
        expect(find.text('Post 1 of 60.'), findsNothing, reason: 'the reader stays where they were');
        await _close(tester);
      });
    });
  }

  group('forum links', () {
    const base = 'https://forum.test';
    test('a discussion, with or without slug and post number', () {
      expect(ForumLink.parse('$base/d/5-welcome/2', base), const DiscussionLink('5', 2));
      expect(ForumLink.parse('$base/d/5', base), const DiscussionLink('5'));
      expect(ForumLink.parse('$base/d/5-welcome', base), const DiscussionLink('5'));
    });

    test('users and tags', () {
      expect(ForumLink.parse('$base/u/bob', base), const UserLink('bob'));
      expect(ForumLink.parse('$base/t/support', base), const TagLink('support'));
    });

    test('a forum in a folder, and other sites', () {
      expect(ForumLink.parse('https://ex.com/forum/d/7/3', 'https://ex.com/forum'), const DiscussionLink('7', 3));
      expect(ForumLink.parse('https://ex.com/d/7', 'https://ex.com/forum'), isNull);
      expect(ForumLink.parse('https://forum.test.evil.com/d/5', base), isNull);
      expect(ForumLink.parse('$base/settings', base), isNull);
    });
  });

  testWidgets('event posts read as the web words them', (tester) async {
    late FlarumLocalizations l10n;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      l10n = flarumL10n(context);
      return const SizedBox();
    })));
    FlarumPost event(String type, Object? content) => FlarumPost(
          id: '1',
          number: 2,
          contentType: type,
          content: content,
          author: const FlarumUser(id: '2', username: 'alice', displayName: 'Alice'),
        );
    expect(EventPostNotice.describe(event('discussionRenamed', ['Old', 'New']), l10n).$2,
        'Alice changed the title from “Old” to “New”.');
    expect(EventPostNotice.describe(event('discussionLocked', {'locked': true}), l10n).$2, 'Alice locked the discussion.');
    expect(EventPostNotice.describe(event('discussionLocked', {'locked': false}), l10n).$2,
        'Alice unlocked the discussion.');
    expect(EventPostNotice.describe(event('discussionStickied', {'sticky': true}), l10n).$2,
        'Alice stickied the discussion.');
    expect(EventPostNotice.describe(event('discussionMerged', null), l10n).$2, 'Alice changed the discussion.');
  });

  test('replies are worded as the web words them', () {
    final l10n = lookupFlarumLocalizations(const Locale('en'));
    FlarumPostReply by(String name) =>
        FlarumPostReply(id: name, author: FlarumUser(id: name, username: name, displayName: name));
    FlarumPost post(int count, List<String> names) =>
        FlarumPost(id: '1', number: 1, contentType: 'comment', mentionedByCount: count, mentionedBy: [for (final n in names) by(n)]);
    expect(repliedBy(post(1, ['bob']), l10n), 'bob replied to this.');
    expect(repliedBy(post(3, ['bob', 'alice', 'alice']), l10n), 'bob and alice replied to this.');
    expect(repliedBy(post(4, ['bob', 'alice', 'carol']), l10n), 'bob, alice and 2 others replied to this.');
    expect(repliedBy(post(2, ['bob']), l10n), 'bob and 1 other replied to this.', reason: '2.0 lists only some');
    expect(repliedBy(post(2, []), l10n), '2 replies');
  });
}
