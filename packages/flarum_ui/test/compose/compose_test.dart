import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/compose/compose_page.dart';
import 'package:flarum_ui/src/compose/composers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const _fixtures = '../flarum_core/test/fixtures';

SiteContext _site() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [FlarumLocalizations.delegate, KitLocalizations.delegate, ...FlarumLocalizations.localizationsDelegates],
      home: home,
    );

Future<void> _pumpUntil(WidgetTester tester, Finder finder, {bool gone = false}) async {
  for (var i = 0; i < 60 && finder.evaluate().isEmpty != gone; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, gone ? findsNothing : findsWidgets);
}

/// Lets page transitions and the buttons' entrances finish: a tap while a page slides in, or the
/// Reply button fades in, lands on nothing.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

/// The text field of the composer: the post's text (the last field), or its title.
Finder _field({bool title = false}) =>
    title ? find.widgetWithText(TextField, 'Title') : find.byType(TextField).last;

void main() {
  setUp(FlarumForum.resetForTesting);

  testWidgets('the composer asks for text, and shows why the forum refused', (tester) async {
    Object? sent;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ComposePage(
            site: _site(),
            title: 'Reply',
            onSubmit: (_, content) async {
              sent = content;
              if (content == 'too fast') throw FlarumApiException(429, const [FlarumApiError(code: 'too_many_requests')]);
              if (content == 'bad tags') throw const ComposeProblem('Choose a primary tag.');
              return null;
            },
          ),
        )),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text('Please enter some content'), findsOneWidget);
    expect(sent, isNull);

    await tester.enterText(_field(), 'too fast');
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text("You're posting too quickly. Wait a few seconds and try again."), findsOneWidget);
    expect(find.byType(ComposePage), findsOneWidget, reason: 'stays open');

    await tester.enterText(_field(), 'bad tags');
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text('Choose a primary tag.'), findsOneWidget);

    await tester.enterText(_field(), 'fine');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.byType(ComposePage), findsNothing, reason: 'sent, and closed');
    expect(sent, 'fine');
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version, root: _fixtures));

      testWidgets('Reply on a thread posts, and the thread opens again at the reply', (tester) async {
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        await tester.pumpWidget(_app(ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome'))));
        await _pumpUntil(tester, find.byType(PostTile));
        await _settle(tester);

        await tester.tap(find.text('Reply'));
        await _pumpUntil(tester, find.byType(ComposePage));
        await _settle(tester);
        expect(find.text('Welcome to the test forum'), findsWidgets, reason: 'the composer names the discussion');
        await tester.enterText(_field(), WriteSamples.reply);
        await tester.tap(find.text('Send'));
        await _pumpUntil(tester, find.byType(ComposePage), gone: true);

        final post = fixtures.requests.singleWhere((r) => r.method == 'POST' && r.path == '/posts');
        expect((post.data as Map)['data']['relationships']['discussion']['data']['id'], fixtures.discussionId('welcome'));
        expect(fixtures.requests.last.queryParameters['page[near]'], '2', reason: 'opened again at the reply, post 2');
        await _close(tester);
      });

      testWidgets('a post\'s menu starts a reply to it, or a quote of it', (tester) async {
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        await tester.pumpWidget(_app(ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome'))));
        await _pumpUntil(tester, find.byType(PostTile));

        await _settle(tester);
        await tester.tap(find.byIcon(Icons.more_vert).first);
        await _settle(tester);
        expect(find.text('Edit'), findsNothing, reason: 'not the reader\'s to edit');
        await tester.tap(find.text('Quote'));
        await _pumpUntil(tester, find.byType(ComposePage));
        await _settle(tester);
        final text = tester.widget<TextField>(_field()).controller!.text;
        final first = fixtures.seed['posts'] is Map ? ((fixtures.seed['posts'] as Map)['welcome'] as List).first : null;
        expect(text, startsWith('> @"admin"#p$first '));
        await _close(tester);
      });

      testWidgets('typing @ and a name offers members to mention', (tester) async {
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        await tester.pumpWidget(_app(Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ComposePage(site: _site(), title: 'Reply', onSubmit: (_, __) async => null),
            )),
            child: const Text('open'),
          ),
        )));
        await tester.tap(find.text('open'));
        await _settle(tester);
        await tester.tap(_field());
        await tester.enterText(_field(), 'Thanks @bo');
        await _pumpUntil(tester, find.widgetWithText(ActionChip, 'bob'));
        await tester.tap(find.widgetWithText(ActionChip, 'bob'));
        await tester.pump();
        expect(tester.widget<TextField>(_field()).controller!.text, 'Thanks @"bob"#${fixtures.userId('bob')} ');
        expect(find.byType(ActionChip), findsNothing, reason: 'the strip goes once one is picked');
        await _close(tester);
      });

      testWidgets('an edit opens on the post\'s source and saves it', (tester) async {
        fixtures.forum();
        // The reply the write fixtures recorded: bob's, his to edit.
        final reply = jsonDecode(File('$_fixtures/${version.name}/write_reply.json').readAsStringSync())['body']['data'];
        final post = FlarumPost(
          id: reply['id'] as String,
          number: 2,
          contentType: 'comment',
          content: WriteSamples.reply,
          contentHtml: '<p>${WriteSamples.reply}</p>',
          canEdit: true,
        );
        FlarumPost? saved;
        await tester.pumpWidget(_app(Builder(
          builder: (context) => TextButton(
            onPressed: () async => saved = await composeEdit(context, _site(), post),
            child: const Text('open'),
          ),
        )));
        await tester.tap(find.text('open'));
        await _pumpUntil(tester, find.byType(ComposePage));
        await _settle(tester);
        expect(find.text('Edit post'), findsOneWidget);
        expect(tester.widget<TextField>(_field()).controller!.text, WriteSamples.reply);
        await tester.enterText(_field(), WriteSamples.edit);
        await tester.tap(find.text('Save'));
        await _pumpUntil(tester, find.byType(ComposePage), gone: true);
        expect(saved?.source, WriteSamples.edit);
        await _close(tester);
      });

      testWidgets('Start a discussion asks for its tags, then starts it', (tester) async {
        final forum = fixtures.forum();
        await tester.runAsync(forum.refresh);
        await tester.pumpWidget(_app(HomePage(site: _site())));
        await _pumpUntil(tester, find.byType(DiscussionTile));
        await _settle(tester);

        await tester.tap(find.text('Start a discussion'));
        await _pumpUntil(tester, find.byType(ComposePage));
        await _settle(tester);
        await tester.enterText(_field(title: true), WriteSamples.title);
        await tester.enterText(_field(), WriteSamples.content);
        await tester.tap(find.text('Send'));
        await tester.pump();
        expect(find.text('Choose a primary tag.'), findsOneWidget, reason: 'the forum asks for one');

        await tester.tap(find.text('Choose tags'));
        await _settle(tester);
        await tester.tap(find.text('General'));
        await tester.pump();
        await tester.tap(find.text('Done'));
        await _settle(tester);
        await tester.tap(find.text('Send'));
        await _pumpUntil(tester, find.byType(ThreadPage));

        final start = fixtures.requests.singleWhere((r) => r.method == 'POST' && r.path == '/discussions');
        expect((start.data as Map)['data']['relationships']['tags']['data'], [
          {'type': 'tags', 'id': fixtures.tagId('general')},
        ]);
        await _close(tester);
      });
    });
  }
}
