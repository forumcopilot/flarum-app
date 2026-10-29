import 'dart:convert';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/theme/forum_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fixtures = '../flarum_core/test/fixtures';

ForumPalette _palette(String hex) => ForumPalette(light: DiscourseScheme.fromHex({'tertiary': hex}));

/// An app that holds several forums, as Flapp does: its own list, each forum pushed over it.
class _Host extends StatelessWidget {
  const _Host(this.forums);

  final Map<String, FlarumForumPage Function()> forums;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: FlarumForumTheme.current,
        builder: (context, palette, _) => MaterialApp(
          theme: AppTheme.themeFor(Brightness.light, palette),
          localizationsDelegates: FlarumHost.localizationsDelegates,
          supportedLocales: FlarumHost.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('My forums')),
              body: Column(children: [
                for (final MapEntry(key: name, value: page) in forums.entries)
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page())),
                    child: Text(name),
                  ),
              ]),
            ),
          ),
        ),
      );
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder, {bool gone = false}) async {
  for (var i = 0; i < 60 && finder.evaluate().isEmpty != gone; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, gone ? findsNothing : findsWidgets);
}

/// Pumps until [finder] shows, then through the page transition, so taps land where the page rests.
Future<void> _arrive(WidgetTester tester, Finder finder) async {
  await _pumpUntil(tester, finder);
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUp(() {
    // The drawer has introduced itself already (its own test below), so it doesn't open over them.
    SharedPreferences.setMockInitialValues({'forum_drawer_introduced': true});
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
    FlarumForumTheme.reset();
  });

  group('the forums\' colours', () {
    test('are on the app while a forum is open, the innermost one\'s', () async {
      await FlarumForumTheme.update('https://one.test', _palette('#D22929'));
      await FlarumForumTheme.update('https://two.test/', _palette('#48BF83'));
      expect(FlarumForumTheme.current.value, isNull, reason: 'no forum open');

      await FlarumForumTheme.enter('https://one.test/');
      expect(FlarumForumTheme.current.value, _palette('#D22929'));
      expect(AppTheme.palette.value, _palette('#D22929'), reason: 'forum_kit\'s widgets read it there');

      await FlarumForumTheme.enter('https://two.test');
      expect(FlarumForumTheme.current.value, _palette('#48BF83'));
      await FlarumForumTheme.leave('https://two.test');
      expect(FlarumForumTheme.current.value, _palette('#D22929'));
      await FlarumForumTheme.leave('https://one.test');
      expect(FlarumForumTheme.current.value, isNull);
    });

    test('learned on one run are there on the next, until the forum drops them', () async {
      await FlarumForumTheme.update('https://one.test', _palette('#D22929'));
      FlarumForumTheme.reset();
      expect(FlarumForumTheme.paletteFor('https://one.test'), isNull);

      await FlarumForumTheme.loadRemembered();
      expect(FlarumForumTheme.paletteFor('https://one.test'), _palette('#D22929'));

      await FlarumForumTheme.update('https://one.test', null);
      FlarumForumTheme.reset();
      await FlarumForumTheme.loadRemembered();
      expect(FlarumForumTheme.paletteFor('https://one.test'), isNull);
    });

    test('remembered by an earlier version, they lose the stock dark scheme it kept with them', () async {
      final old = ForumPalette(
        light: DiscourseScheme.fromHex({'tertiary': '#D22929'}),
        dark: DiscourseScheme.fromHex({'tertiary': '#D22929'}, fallback: DiscourseScheme.dark),
      );
      SharedPreferences.setMockInitialValues({
        'flarum_forum_palettes': jsonEncode({'https://one.test': old.toJson()}),
      });
      await FlarumForumTheme.loadRemembered();
      expect(FlarumForumTheme.paletteFor('https://one.test'), _palette('#D22929'));
    });

    test('a directory\'s hex without "#" makes the same palette as the forum\'s own', () {
      expect(flarumPaletteOf('4d698e', null), flarumPaletteOf('#4D698E', '#4D698E'));
      expect(flarumPaletteOf(null, '#ffffff'), isNull);
    });
  });

  testWidgets('a 1.x and a 2.0 forum open from the host\'s list, each in turn, and Back returns to it',
      (tester) async {
    final one = FixtureForum(FlarumVersion.v1, root: _fixtures)..forum(url: 'https://one.test');
    final two = FixtureForum(FlarumVersion.v2, root: _fixtures)..forum(url: 'https://two.test');
    await FlarumForumTheme.update('https://two.test', _palette('#48BF83'));
    await tester.pumpWidget(_Host({
      'One': () => FlarumForumPage(site: FlarumHost.site(name: 'Forum one', url: 'https://one.test')),
      'Two': () => FlarumForumPage(site: FlarumHost.site(name: 'Forum two', url: 'https://two.test')),
    }));

    await tester.tap(find.text('One'));
    await _arrive(tester, find.byType(DiscussionTile));
    expect(find.text('flarum-app test forum (1.8)'), findsOneWidget, reason: 'the home has the forum\'s own title');
    expect(find.byType(AppShell), findsOneWidget);
    expect(one.requests, isNotEmpty);
    expect(two.requests, isEmpty, reason: 'nothing goes to a forum that isn\'t open');
    expect(FlarumForumTheme.current.value, flarumPaletteOf('#4D698E', '#4D698E'),
        reason: 'the forum\'s colours, from its GET /api');

    // The forum's bar has ☰, as the Discourse app's does: Back (the system's) returns to the host.
    expect(find.byType(BackButton), findsNothing);
    await tester.binding.handlePopRoute();
    await _pumpUntil(tester, find.byType(AppShell), gone: true);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('My forums'), findsOneWidget);
    await tester.pump();
    expect(FlarumForumTheme.current.value, isNull, reason: 'the host\'s screens keep the host\'s colours');

    final page = find.byType(FlarumForumPage);
    await tester.tap(find.text('Two'));
    await _arrive(tester, find.byType(DiscussionTile));
    expect(find.text('flarum-app test forum (2.0)'), findsOneWidget);
    expect(page, findsOneWidget);
    expect(two.requests.any((r) => r.path == '/discussions'), isTrue);
    expect(FlarumForumTheme.paletteFor('https://two.test'), flarumPaletteOf('#4D698E', '#4D698E'),
        reason: 'the forum\'s own colours replace the directory\'s');
    await _close(tester);
  });

  testWidgets('a forum that doesn\'t answer opens in the colours the host gave it', (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _fixtures)..forum(url: 'https://two.test');
    fixtures.offline = true;
    await FlarumForumTheme.update('https://two.test', _palette('#48BF83'));
    await tester.pumpWidget(_Host({
      'Two': () => FlarumForumPage(site: FlarumHost.site(name: 'Forum two', url: 'https://two.test')),
    }));
    await tester.tap(find.text('Two'));
    await _arrive(tester, find.byType(AppShell));
    expect(Theme.of(tester.element(find.byType(AppShell))).colorScheme,
        AppTheme.themeFor(Brightness.light, _palette('#48BF83')).colorScheme);
    expect(FlarumForumTheme.current.value, _palette('#48BF83'));
    expect(find.text('Forum two'), findsOneWidget, reason: 'the host\'s name for it, with no title from the forum');
    await _close(tester);
  });

  testWidgets('a forum opened at a discussion has its home under it', (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _fixtures)..forum(url: 'https://two.test');
    await tester.pumpWidget(_Host({
      'Two': () => FlarumForumPage(
            site: FlarumHost.site(name: 'Forum two', url: 'https://two.test'),
            link: DiscussionLink(fixtures.discussionId('welcome')),
          ),
    }));
    await tester.tap(find.text('Two'));
    await _arrive(tester, find.byType(PostTile));
    expect(find.byType(ThreadPage), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await _pumpUntil(tester, find.byType(ThreadPage), gone: true);
    await _pumpUntil(tester, find.byType(DiscussionTile));
    await _close(tester);
  });

  testWidgets('a forum opened from a push opens what it names and marks the notification read', (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _fixtures)..forum(url: 'https://two.test');
    fixtures.replies['PATCH /notifications/7'] = <String, Object>{};
    await tester.pumpWidget(_Host({
      'Two': () => FlarumForumPage(
            site: FlarumHost.site(name: 'Forum two', url: 'https://two.test'),
            link: ForumLink.fromPush({'discussion_id': fixtures.discussionId('welcome'), 'post_number': '2'}),
            notificationId: '7',
          ),
    }));
    await tester.tap(find.text('Two'));
    await _arrive(tester, find.byType(PostTile));

    expect(find.byType(ThreadPage), findsOneWidget);
    expect(fixtures.requests.where((r) => r.method == 'PATCH' && r.path == '/notifications/7'), hasLength(1));
    await _close(tester);
  });

  testWidgets('a push naming a user by id opens their profile', (tester) async {
    final fixtures = FixtureForum(FlarumVersion.v2, root: _fixtures)..forum(url: 'https://two.test');
    await tester.pumpWidget(_Host({
      'Two': () => FlarumForumPage(
            site: FlarumHost.site(name: 'Forum two', url: 'https://two.test'),
            link: UserIdLink(fixtures.userId('bob')),
          ),
    }));
    await tester.tap(find.text('Two'));
    await _arrive(tester, find.byType(UserPage));

    expect(fixtures.requests.map((r) => r.path), containsAllInOrder(['/users/${fixtures.userId('bob')}', '/users/bob']));
    await _close(tester);
  });

  testWidgets('a forum opened again this run opens at once', (tester) async {
    FixtureForum(FlarumVersion.v1, root: _fixtures).forum(url: 'https://one.test');
    await tester.pumpWidget(_Host({
      'One': () => FlarumForumPage(site: FlarumHost.site(name: 'Forum one', url: 'https://one.test')),
    }));
    await tester.tap(find.text('One'));
    await _arrive(tester, find.byType(DiscussionTile));
    await tester.binding.handlePopRoute();
    await _pumpUntil(tester, find.byType(AppShell), gone: true);
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('One'));
    await tester.pump();
    // A pushed route's first frame is built offstage.
    expect(find.byType(AppShell, skipOffstage: false), findsOneWidget);
    expect(find.byType(CircularProgressIndicator, skipOffstage: false), findsNothing, reason: 'no spinner on the way');
    await _close(tester);
  });

  testWidgets('the profile tab leaves the appearance to a host that offers it', (tester) async {
    FixtureForum(FlarumVersion.v2, root: _fixtures).forum(url: 'https://two.test');
    await tester.pumpWidget(_Host({
      'Two': () => FlarumForumPage(site: FlarumHost.site(name: 'Forum two', url: 'https://two.test')),
    }));
    await tester.tap(find.text('Two'));
    await _arrive(tester, find.byType(DiscussionTile));
    await tester.tap(find.text('Profile'));
    await _pumpUntil(tester, find.byType(AccountPage));
    expect(find.text('Color Scheme'), findsNothing);
    await _close(tester);
  });

  testWidgets('pushed over a host, the drawer opens once by itself to say where it is; then only from ☰',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    FixtureForum(FlarumVersion.v2, root: _fixtures).forum(url: 'https://two.test');
    await tester.pumpWidget(_Host({
      'Two': () => FlarumForumPage(site: FlarumHost.site(name: 'Forum two', url: 'https://two.test')),
    }));
    await tester.tap(find.text('Two'));
    await _arrive(tester, find.byType(DiscussionTile));
    await _pumpUntil(tester, find.byType(ForumDrawer));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Tap ☰ to open this again'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getBool('forum_drawer_introduced'), isTrue);

    // Closed, it stays closed; the edge means Back here, so it opens from ☰.
    await tester.tapAt(const Offset(780, 300));
    await _pumpUntil(tester, find.byType(ForumDrawer), gone: true);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await _pumpUntil(tester, find.byType(ForumDrawer));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Tap ☰ to open this again'), findsNothing, reason: 'the introduction is said once');
    await _close(tester);
  });
}
