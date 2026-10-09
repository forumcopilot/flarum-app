import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The whole app over the 2.0 test forum's recorded responses: it starts on
/// the forum's discussions, and the Tags tab lists the tags.
void main() {
  testWidgets('the app opens on the forum\'s discussions and has a tags tab', (tester) async {
    FlarumForum.resetForTesting();
    final fixtures = FixtureForum(FlarumVersion.v2, root: 'packages/flarum_core/test/fixtures');
    fixtures.forum();
    final site = SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: const AppForumConfig(name: 'Test forum', baseUrl: FixtureForum.baseUrl).toSite(),
    );

    await tester.pumpWidget(FlarumApp(site: site));
    for (var i = 0; i < 50 && find.byType(DiscussionTile).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(DiscussionTile), findsWidgets);

    await tester.tap(find.text('Tags'));
    for (var i = 0; i < 50 && find.text('Support').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Support'), findsWidgets);
  });
}
