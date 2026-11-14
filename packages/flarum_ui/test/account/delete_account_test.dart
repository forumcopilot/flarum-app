import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/account/forum_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:intl/intl.dart';

/// alice deletes her account from Profile → Account and Privacy → Delete Account, replayed from
/// flarum_core's erasure_* fixtures (flarum/gdpr, which both test forums run): the request with her
/// password alone (flarum/gdpr leaves the reason optional, and the app asks none), the email it waits for, a cancellation, a confirmed request, and a forum without the
/// extension, where only its staff can delete accounts.
void main() {
  const root = '../flarum_core/test/fixtures';
  final site = SiteContext(
    siteType: FlarumProxyFactory.siteType,
    site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
  );

  Future<FixtureForum> openDeleteAccount(WidgetTester tester, FlarumVersion version,
      {Set<String> states = const {}, void Function(FixtureForum)? before}) async {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
    final fixtures = FixtureForum(version, root: root, states: states);
    before?.call(fixtures);
    final forum = fixtures.forum();
    await tester.runAsync(forum.refresh);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AccountPage(site: site)));
    await tester.scrollUntilVisible(find.text('Account and Privacy'), 200);
    await tester.tap(find.text('Account and Privacy'));
    await tester.pumpAndSettle();
    expect(find.text('Have the forum erase your account'), findsOneWidget);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    return fixtures;
  }

  /// Scrolls the page (the first scrollable: each text field has its own) until [finder] is built.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  String day(String iso) => DateFormat.yMMMd('en_US').format(DateTime.parse(iso).toLocal());

  for (final version in FlarumVersion.values) {
    final forumName = version == FlarumVersion.v1 ? 'flarum-app test forum (1.8)' : 'flarum-app test forum (2.0)';

    testWidgets('Flarum ${version.name}: the request says each step, sends the password, and can be cancelled',
        (tester) async {
      final fixtures = await openDeleteAccount(tester, version);
      expect(fixtures.requests.last.queryParameters, {'include': 'erasureRequest'});

      expect(find.text('Delete your account on $forumName'), findsOneWidget);
      expect(find.text('$forumName emails a link to alice@flarumapp.local.'), findsOneWidget);
      expect(find.text('Open the link to confirm. Nothing happens until you do.'), findsOneWidget);
      expect(find.text('Within 30 days, the forum erases your account. Until then you can cancel here.'), findsOneWidget);
      expect(find.textContaining('Erasing anonymizes the account'), findsOneWidget,
          reason: 'the test forums anonymize, as flarum/gdpr does by default');

      await scrollTo(tester, find.widgetWithText(TextField, 'Password'));
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'secret');
      await scrollTo(tester, find.text('Request Account Deletion'));
      await tester.tap(find.text('Request Account Deletion'));
      await tester.pumpAndSettle();

      final sent = fixtures.requests.lastWhere((r) => r.method == 'POST').data as Map;
      expect(sent['meta'], {'password': 'secret'});
      expect(sent['data']['attributes'], isEmpty, reason: 'no reason: the app asks only for the password');
      expect(find.widgetWithText(TextField, 'Reason (optional)'), findsNothing);

      expect(find.text('Check your email'), findsOneWidget);
      expect(
          find.text('On ${day('2026-11-14T03:40:00+00:00')}, $forumName sent a link to alice@flarumapp.local. '
              'Open it to confirm that you want your account erased.'),
          findsOneWidget);

      await scrollTo(tester, find.text('Cancel Request'));
      await tester.tap(find.text('Cancel Request'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel your request?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel Request'));
      await tester.pumpAndSettle();
      final cancel = fixtures.requests.last;
      expect(cancel.path, version == FlarumVersion.v2 ? '/user-erasure-requests/29/cancel' : '/user-erasure-requests/4');
      expect(find.text('Request cancelled. Your account stays.'), findsOneWidget);
      await scrollTo(tester, find.text('Request Account Deletion'));
      expect(find.text('Request Account Deletion'), findsOneWidget, reason: 'the form again');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Flarum ${version.name}: a wrong password is said under the field',
        (tester) async {
      await openDeleteAccount(tester, version, states: {'wrongPassword'});
      await scrollTo(tester, find.widgetWithText(TextField, 'Password'));
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'wrong');
      await scrollTo(tester, find.text('Request Account Deletion'));
      await tester.tap(find.text('Request Account Deletion'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('Incorrect password.'));
      expect(find.text('Check your email'), findsNothing);
    });

    testWidgets('Flarum ${version.name}: a request waiting for its email offers a new link and Cancel', (tester) async {
      await openDeleteAccount(tester, version, states: {'erasureAwaiting'});
      expect(find.text('Check your email'), findsOneWidget);
      await scrollTo(tester, find.text('Cancel Request'));
      expect(find.text('Cancel Request'), findsOneWidget);
      await scrollTo(tester, find.text('Send a New Link'));
      await tester.tap(find.text('Send a New Link'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(TextField, 'Password'));
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget, reason: 'asking again needs the password');
      await scrollTo(tester, find.widgetWithText(TextButton, 'Cancel'));
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('Flarum ${version.name}: a confirmed request says by when the account goes', (tester) async {
      await openDeleteAccount(tester, version, states: {'erasureConfirmed'});
      expect(find.text('Deletion confirmed'), findsOneWidget);
      expect(
          find.text('You confirmed on ${day('2026-11-14T04:05:00+00:00')}. The forum erases your account by '
              "${day('2026-12-14T04:05:00+00:00')} at the latest, and emails you when it's done."),
          findsOneWidget);
      await scrollTo(tester, find.text('Cancel Request'));
      expect(find.widgetWithText(TextField, 'Password'), findsNothing);
    });

    testWidgets('Flarum ${version.name}: without flarum/gdpr, the staff are asked, on the forum, logged in',
        (tester) async {
      final opened = <String>[];
      ForumWebPage.webViewForTesting = (url, cookie) {
        opened.add('$url');
        return const Text("the forum's page");
      };
      addTearDown(() => ForumWebPage.webViewForTesting = null);
      final fixtures = await openDeleteAccount(tester, version, before: (fixtures) {
        final forum = jsonDecode(File('$root/${version.name}/forum.json').readAsStringSync())['body'] as Map<String, dynamic>;
        (forum['data']['attributes'] as Map)
          ..remove('erasureAnonymizationAllowed')
          ..remove('erasureDeletionAllowed');
        fixtures.replies['GET '] = forum;
      });
      expect(fixtures.requests.where((r) => r.path.startsWith('/users')), isEmpty, reason: 'nothing to ask the forum');
      expect(find.text("Ask the forum's staff"), findsOneWidget);
      expect(find.textContaining("doesn't let members delete their own accounts from an app"), findsOneWidget);
      expect(find.text('Request Account Deletion'), findsNothing);
      await scrollTo(tester, find.text('Open the Forum'));
      await tester.tap(find.text('Open the Forum'));
      await tester.pumpAndSettle();
      expect(opened.single, '${FixtureForum.baseUrl}/');
    });
  }
}
