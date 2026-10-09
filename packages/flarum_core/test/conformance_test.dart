@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/test/test_exports.dart' as fc;

/// The SDK's shared proxy suites (forumcopilot_sdk lib/test), run against a live test forum:
/// the conformance check the plan asks for. They expect `result: true` from every method, so in
/// Phase 2 the write methods (Phase 3) fail by design; the summary at the end is the report.
/// Only the proxies Flarum implements are driven. Signs in as carol, whose read state no fixture
/// depends on. Skipped by default; run against one forum with
///
///   FLARUM_URL=http://127.0.0.1:8082 FLARUM_SEED=/var/www/flarumapp/tools/seed-v2.json \
///   FLARUM_TEST_PASSWORD=… flutter test --run-skipped -t live test/conformance_test.dart
Future<void> main() async {
  final url = Platform.environment['FLARUM_URL'];
  final seedFile = Platform.environment['FLARUM_SEED'];
  if (url == null || seedFile == null) {
    test('conformance', () {}, skip: 'set FLARUM_URL, FLARUM_SEED and FLARUM_TEST_PASSWORD');
    return;
  }
  final seed = jsonDecode(File(seedFile).readAsStringSync()) as Map<String, dynamic>;
  final site = SiteContext(
    siteType: FlarumProxyFactory.siteType,
    site: Site(
      id: null,
      name: 'Test forum',
      url: url,
      description: '',
      logoUrl: null,
      backgroundUrl: null,
      endpoint: null,
      baseUrl: url,
      siteType: FlarumProxyFactory.siteType,
      language: null,
    ),
  );
  FlarumTokenStore.instance = FlarumTokenStore.memory();
  FlarumProxyFactory.register();
  SiteProxyFactory.initialize(site);

  final config = fc.TestConfig(
    forumId: (seed['tags'] as Map)['general'] as String,
    passwordProtectedForumId: (seed['tags'] as Map)['general'] as String,
    topicId: (seed['discussions'] as Map)['welcome'] as String,
    postId: ((seed['posts'] as Map)['welcome'] as List).first as String,
    userId: (seed['users'] as Map)['bob'] as String,
    username: 'carol',
    password: Platform.environment['FLARUM_TEST_PASSWORD'] ?? '',
    conversationId: '',
    messageId: '',
    attachmentId: '',
    groupId: '',
    testUrl: '$url/d/${(seed['discussions'] as Map)['welcome']}',
    forumPassword: '',
    email: 'carol@example.com',
  );

  // Before the groups: some suites decide while being declared whether to run signed in.
  await fc.authenticateForTests(SiteProxyFactory.getUserProxy(), config);
  tearDownAll(() async {
    fc.TestResultTracker().printSummary();
    await SiteProxyFactory.getUserProxy().logoutUserAsync();
  });

  group('IFCConfigProxy', () => fc.runConfigProxyTests(SiteProxyFactory.getConfigProxy(), config));
  group('IFCForumProxy', () => fc.runForumProxyTests(SiteProxyFactory.getForumProxy(), config));
  group('IFCTopicProxy',
      () => fc.runTopicProxyTests(SiteProxyFactory.getTopicProxy(), SiteProxyFactory.getForumProxy(), config));
  group(
      'IFCPostProxy',
      () => fc.runPostProxyTests(SiteProxyFactory.getPostProxy(), SiteProxyFactory.getTopicProxy(),
          SiteProxyFactory.getForumProxy(), config));
  group('IFCUserProxy', () => fc.runUserProxyTests(SiteProxyFactory.getUserProxy(), config));
  group('IFCSearchProxy',
      () => fc.runSearchProxyTests(SiteProxyFactory.getSearchProxy(), SiteProxyFactory.getForumProxy(), config));
  group(
      'IFCSubscriptionProxy',
      () => fc.runSubscriptionProxyTests(SiteProxyFactory.getSubscriptionProxy(), SiteProxyFactory.getForumProxy(),
          SiteProxyFactory.getTopicProxy(), config));
  group(
      'IFCSocialProxy',
      () => fc.runSocialProxyTests(SiteProxyFactory.getSocialProxy(), SiteProxyFactory.getPostProxy(),
          SiteProxyFactory.getTopicProxy(), SiteProxyFactory.getForumProxy(), config));
}
