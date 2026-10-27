import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// alice edits her profile, replayed from the fixtures recorded as she did (record_fixtures.dart's
/// `profile_*`): a nickname, one too long, and her username back.
void main() {
  for (final version in FlarumVersion.values) {
    testWidgets('Flarum ${version.name}: Edit Profile saves the display name as it is changed, with Undo',
        (tester) async {
      FlarumForum.resetForTesting();
      FlarumTokenStore.instance = FlarumTokenStore.memory();
      final fixtures = FixtureForum(version, root: '../flarum_core/test/fixtures');
      final forum = fixtures.forum();
      await tester.runAsync(forum.refresh);
      final site = SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );
      await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: AccountPage(site: site)));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Edit Profile'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Display Name'), findsOneWidget);
      expect(find.text('@alice'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget, reason: "the username: admins' alone");
      await tester.tap(find.text('Username'));
      await tester.pump();
      expect(find.text("Only the forum's admins can change usernames."), findsOneWidget);

      // Her picture: the camera or her photos; nothing to remove yet.
      await tester.tap(find.byTooltip('Change Profile Picture'));
      await tester.pumpAndSettle();
      expect(find.text('Take photo'), findsOneWidget);
      expect(find.text('Choose from Library'), findsOneWidget);
      expect(find.text('Remove Picture'), findsNothing);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // A name the forum refuses: its reason under the field, which keeps what was typed.
      await tester.tap(find.text('Display Name'));
      await tester.pumpAndSettle();
      expect(find.text('Leave it empty to show your username, @alice.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), WriteSamples.nicknameTooLong);
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('150 characters'), findsOneWidget);

      await tester.enterText(find.byType(TextField), WriteSamples.nickname);
      await tester.pumpAndSettle();
      expect(find.textContaining('150 characters'), findsNothing, reason: 'typing clears it');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Display name saved.'), findsOneWidget);
      expect(find.widgetWithText(ListTile, WriteSamples.nickname), findsOneWidget);

      // Undo: her username again, as the web puts it back.
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, WriteSamples.nickname), findsNothing);
      expect(find.widgetWithText(ListTile, 'alice'), findsOneWidget);

      final nicknames = [
        for (final r in fixtures.requests)
          if (r.method == 'PATCH') (r.data as Map)['data']['attributes']['nickname'],
      ];
      expect(nicknames, [WriteSamples.nicknameTooLong, WriteSamples.nickname, 'alice']);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
