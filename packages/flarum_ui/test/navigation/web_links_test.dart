import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/navigation/web_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  final site = SiteContext(
    siteType: FlarumProxyFactory.siteType,
    site: const AppForumConfig(name: 'Test forum', baseUrl: 'https://forum.test/').toSite(),
  );

  test("a discussion's link is the website's: Flarum's slug as it comes, the post after it", () {
    // Flarum's slug already starts with the id (both versions; see the fixtures).
    expect(WebLinks.discussion(site, '3', slug: '3-welcome-to-the-test-forum'), 'https://forum.test/d/3-welcome-to-the-test-forum');
    expect(WebLinks.discussion(site, '3', slug: '3-welcome-to-the-test-forum', near: 4),
        'https://forum.test/d/3-welcome-to-the-test-forum/4');
    expect(WebLinks.discussion(site, '3', slug: '3-welcome', near: 1), 'https://forum.test/d/3-welcome', reason: 'the first post is the discussion');
    expect(WebLinks.discussion(site, '3'), 'https://forum.test/d/3');
    expect(WebLinks.discussion(site, '3', slug: '3'), 'https://forum.test/d/3', reason: 'the ID slug driver');
    expect(WebLinks.discussion(site, '3', slug: 'welcome'), 'https://forum.test/d/3-welcome', reason: 'a slug without its id');
  });
}
