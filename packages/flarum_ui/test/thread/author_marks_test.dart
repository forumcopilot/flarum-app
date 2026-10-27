import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/profile/user_card_sheet.dart';
import 'package:flarum_ui/src/widgets/author_marks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

/// What the web shows beside a post's author on discuss.flarum.org: their groups as badges and,
/// with fof/geoip, the country the post came from; and on their card, their bio (fof/user-bio).
void main() {
  SiteContext site() => SiteContext(
        siteType: FlarumProxyFactory.siteType,
        site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
      );

  const author = FlarumUser(
    id: '7',
    username: 'ClaudiusH',
    displayName: 'ClaudiusH',
    bio: 'PM at Glowing Blue. German language pack.',
    groups: [
      FlarumGroup(id: '8', nameSingular: 'Flarum Team', color: '#e7672e', icon: 'fa-duotone fa-comments'),
      FlarumGroup(id: '24', nameSingular: 'Translator', icon: 'fa-duotone fa-not-a-material-match'),
      FlarumGroup(id: '9', nameSingular: 'Hidden', isHidden: true),
    ],
  );

  test('a country code is its flag', () {
    expect(countryFlag('ch'), '🇨🇭');
    expect(countryFlag('TR'), '🇹🇷');
    expect(countryFlag(null), isNull);
    expect(countryFlag('unknown'), isNull);
  });

  testWidgets("a post's author has their groups' badges and the post's country beside their name", (tester) async {
    FlarumForum.resetForTesting();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: PostTile(
          site: site(),
          post: const FlarumPost(
            id: '1',
            number: 2,
            contentType: 'comment',
            contentHtml: '<p>Done earlier today already.</p>',
            author: author,
            authorCountryCode: 'CH',
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('ClaudiusH'), findsOneWidget);
    expect(find.text('🇨🇭'), findsOneWidget);
    expect(find.byType(GroupIconBadge), findsNWidgets(2), reason: 'not the hidden group');
    expect(find.bySemanticsLabel('Flarum Team'), findsOneWidget);
    expect(find.byIcon(Icons.forum_outlined), findsOneWidget, reason: "the group's icon (fa-comments)");
    expect(find.text('T'), findsOneWidget, reason: "the Translator's initial: its icon has no Material match");
  });

  testWidgets("a member's card has their bio", (tester) async {
    FlarumForum.resetForTesting();
    final fixtures = FixtureForum(FlarumVersion.v2, root: '../flarum_core/test/fixtures');
    fixtures.forum();
    fixtures.replies['GET /users/ClaudiusH'] = {
      'data': {
        'type': 'users',
        'id': '7',
        'attributes': {'username': 'ClaudiusH', 'displayName': 'ClaudiusH', 'bioHtml': '<p>PM at Glowing Blue.</p>'},
      },
    };
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showUserCard(context, site(), author, onOpenProfile: () {}),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('PM at Glowing Blue.'), findsOneWidget);
  });
}
