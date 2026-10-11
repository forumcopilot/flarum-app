import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

SiteContext _site() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}

/// Answers by path, as a forum with the ID slug driver would: the user is found as /u/1, not by
/// username. Keeps what was asked.
class _IdSlugForum implements HttpClientAdapter {
  final requests = <Uri>[];
  final _forum = (jsonDecode(File('../flarum_core/test/fixtures/v2/forum_guest.json').readAsStringSync())
      as Map<String, dynamic>)['body'];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final uri = options.uri;
    requests.add(uri);
    final (status, body) = switch (uri.path) {
      '/api' => (200, _forum),
      '/api/users/1' when uri.queryParameters['bySlug'] == 'true' => (200, {
          'data': {
            'type': 'users',
            'id': '1',
            'attributes': {'username': 'huseyinfiliz', 'displayName': 'Hüseyin', 'slug': '1'},
          },
        }),
      '/api/posts' || '/api/discussions' => (200, {'data': <Object>[]}),
      _ => (404, errors('404', 'not_found')),
    };
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/vnd.api+json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(FlarumForum.resetForTesting);

  testWidgets('a profile is found by slug, and its lists by the username the forum returns', (tester) async {
    final adapter = _IdSlugForum();
    FlarumForum.forTesting(FixtureForum.baseUrl, Dio()..httpClientAdapter = adapter);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: UserPage(site: _site(), slug: '1')));
    await _pumpUntil(tester, find.text('@huseyinfiliz'));
    await tester.pump(const Duration(milliseconds: 200));
    final lists = adapter.requests.where((uri) => uri.path == '/api/posts' || uri.path == '/api/discussions');
    expect(lists, hasLength(2));
    for (final uri in lists) {
      expect(uri.query, contains('huseyinfiliz'), reason: '${uri.path} filters by the username, not the slug');
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version, root: '../flarum_core/test/fixtures'));

      testWidgets('a profile shows the user, their posts and their discussions', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: UserPage(site: _site(), slug: 'bob')));
        await _pumpUntil(tester, find.text('@bob'));
        await _pumpUntil(tester, find.byType(ListTile));
        expect(find.textContaining('Joined'), findsOneWidget);

        await tester.tap(find.text('Discussions'));
        await _pumpUntil(tester, find.text('Feature request: dark mode'));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('a mention in a thread opens the profile', (tester) async {
        fixtures.forum();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: ThreadPage(site: _site(), discussionId: fixtures.discussionId('welcome')),
        ));
        await _pumpUntil(tester, find.text('@bob'));
        await tester.tap(find.text('@bob').first);
        await _pumpUntil(tester, find.byType(UserPage));
        await _pumpUntil(tester, find.text('@bob'));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    });
  }
}
