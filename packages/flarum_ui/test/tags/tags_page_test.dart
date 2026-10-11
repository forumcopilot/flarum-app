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
}
