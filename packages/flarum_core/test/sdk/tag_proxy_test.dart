import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flarum_core/testing.dart';
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
        expect(result.total, 17, reason: "the seed's 7 and community_seed.php's 10");
        final general = result.items.singleWhere((t) => t.name == 'general');
        expect(general.text, 'General');
        expect(general.id, int.parse(fixtures.tagId('general')));
        expect(general.count, greaterThan(1));
        for (var i = 1; i < result.items.length; i++) {
          final (a, b) = (result.items[i - 1], result.items[i]);
          expect(a.count > b.count || (a.count == b.count && a.text.toLowerCase().compareTo(b.text.toLowerCase()) <= 0), isTrue,
              reason: 'most used first, ties in name order: ${a.name} before ${b.name}');
        }
      });

      test('tag search: names starting with the query first, then containing it', () async {
        fixtures.forum();
        final proxy = FlarumTagProxy(testSite());
        expect((await proxy.searchTagsAsync('s')).names,
            ['showcase', 'support', 'recommendations', 'books', 'announcements', 'ios', 'question']);
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
