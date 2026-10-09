import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import 'site.dart';

void main() {
  setUp(() {
    FlarumForum.resetForTesting();
    FlarumTokenStore.instance = FlarumTokenStore.memory();
  });

  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;

      setUp(() => fixtures = FixtureForum(version));

      test('every tag, most used first, by slug with its display name', () async {
        fixtures.forum();
        final result = await FlarumTagProxy(testSite()).getAllTagsAsync();

        expect(result.result, isTrue, reason: result.resultText);
        expect(result.total, 7);
        final general = result.items.first;
        expect(general.name, 'general', reason: 'the most discussions');
        expect(general.text, 'General');
        expect(general.id, int.parse(fixtures.tagId('general')));
        expect(general.count, greaterThan(1));
        final rest = result.items.skip(1).map((t) => t.text).toList();
        expect(rest, [...rest]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())), reason: 'ties in name order');
      });

      test('tag search: names starting with the query first, then containing it', () async {
        fixtures.forum();
        final proxy = FlarumTagProxy(testSite());
        expect((await proxy.searchTagsAsync('s')).names, ['support', 'announcements', 'ios', 'question']);
        expect((await proxy.searchTagsAsync('BU')).names, ['bug']);
        expect((await proxy.searchTagsAsync('', limit: 2)).names, hasLength(2));
        expect(fixtures.requests.where((r) => r.path == '/tags'), hasLength(1), reason: 'the tag list is fetched once');
      });

      test('a tag\'s discussions, by slug', () async {
        fixtures.forum();
        final result = await FlarumTagProxy(testSite()).getTopicsByTagAsync('support');
        expect(result.result, isTrue, reason: result.resultText);
        expect(result.forumId, fixtures.tagId('support'));
        expect(result.topics.map((t) => t.id), [fixtures.discussionId('support')]);
        expect((await FlarumTagProxy(testSite()).getTopicsByTagAsync('nope')).result, isFalse);
      });
    });
  }
}
