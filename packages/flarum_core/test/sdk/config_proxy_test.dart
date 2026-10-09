import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../support/fixtures.dart';
import 'site.dart';

void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() {
        FlarumForum.resetForTesting();
        fixtures = FixtureForum(version);
      });

      test('reads the forum and the extensions it runs from GET /api', () async {
        fixtures.forum();
        final config = await FlarumConfigProxy(testSite()).getConfig(FixtureForum.baseUrl);

        expect(config.forumType, 'flarum');
        expect(config.systemVersion, version == FlarumVersion.v2 ? '2' : '1');
        expect(config.isOpen, isTrue);
        expect(config.userId, fixtures.userId('alice'));
        // flags, byobu, fof/follow-tags, flarum/tags and nicknames are on both test forums.
        expect(config.reportPost, isTrue);
        expect(config.reportPm, isTrue);
        expect(config.conversation, isTrue);
        expect(config.inboxStat, isTrue);
        expect(config.subscribeForum, isTrue);
        expect(config.getForum, isTrue);
        expect(config.updateProfile, isTrue);
        expect(config.searchUser, isTrue);
        expect(config.regUrl, FixtureForum.baseUrl);
        expect(config.markForum, isFalse);
        expect(config.markPmUnread, isFalse);
      });

      test('detects flarum/messages from the reader on 2.0 only', () async {
        final forum = fixtures.forum();
        await forum.refresh();
        expect(forum.extensions.messages, version == FlarumVersion.v2);
        expect(forum.extensions.byobu, isTrue);
      });

      test('a guest gets the forum, with no user', () async {
        fixtures.forum(signedIn: false);
        final config = await FlarumConfigProxy(testSite()).getConfig(FixtureForum.baseUrl);
        expect(config.guestOkay, isTrue);
        expect(config.userId, '');
      });

      test('reads GET /api once, and again when asked to refresh', () async {
        fixtures.forum();
        final proxy = FlarumConfigProxy(testSite());
        await proxy.getConfig(FixtureForum.baseUrl);
        await proxy.getConfig(FixtureForum.baseUrl);
        expect(fixtures.requests, hasLength(1));
        await proxy.getConfig(FixtureForum.baseUrl, forceRefresh: true);
        expect(fixtures.requests, hasLength(2));
      });
    });
  }

  test('the factory serves Flarum\'s proxies and refuses the ones not built yet', () {
    FlarumProxyFactory.register();
    final site = testSite();
    SiteProxyFactory.initialize(site);
    expect(SiteProxyFactory.getConfigProxy(), isA<FlarumConfigProxy>());
    expect(SiteProxyFactory.getPostProxy(), isA<FlarumPostProxy>());
    expect(SiteProxyFactory.getUserProxy(), isA<FlarumUserProxy>());
    expect(SiteProxyFactory.getSearchProxy, throwsUnimplementedError);
  });
}
