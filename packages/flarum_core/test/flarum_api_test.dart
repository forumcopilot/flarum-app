import 'package:flarum_core/flarum_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/scripted.dart';

/// Every test runs against responses recorded from both test forums.
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum forum;
      late FlarumApi api;

      setUp(() {
        forum = FixtureForum(version);
        api = forum.api();
      });

      group('forumInfo', () {
        test('detects the version', () async {
          expect((await forum.api(signedIn: false).forumInfo()).version, version);
        });

        test('a guest has no actor', () async {
          expect((await forum.api(signedIn: false).forumInfo()).actor, isNull);
        });

        test('reads the reader, colours and tag rules', () async {
          final info = await api.forumInfo();
          expect(info.actor?.username, 'alice');
          expect(info.actor?.unreadNotificationCount, greaterThan(0));
          expect(info.primaryColor, '#4D698E');
          expect(info.colorScheme, version == FlarumVersion.v2 ? 'auto' : isNull);
          // Both versions send the tag limits as strings.
          expect(info.tagRules?.minPrimary, 1);
          expect(info.tagRules?.maxSecondary, 3);
          expect(info.can('canStartDiscussion'), isTrue);
          expect(info.attributes['fof-upload.canUpload'], isTrue);
        });
      });

      group('discussions', () {
        test('sends only the parameters both versions accept', () async {
          await api.discussions();
          expect(forum.requests.single.queryParameters, {
            'sort': '-lastPostedAt',
            'page[offset]': '0',
            'page[limit]': '20',
            'include': 'user,lastPostedUser,tags',
          });
        });

        test('resolves authors, last posters and tags from included', () async {
          final page = await api.discussions();
          final welcome = page.items.singleWhere((d) => d.title == 'Welcome to the test forum');
          expect(welcome.author?.username, 'admin');
          expect(welcome.lastPostedUser?.username, 'carol');
          expect(welcome.tags.map((t) => t.slug), ['general']);
          expect(welcome.commentCount, 4);
          expect(page.items.singleWhere((d) => d.title == 'Forum rules').isSticky, isTrue);
          expect(page.hasMore, isFalse);
        });

        test('filters by tag, with primary, child and secondary tags', () async {
          final page = await api.discussions(tagSlug: 'support');
          final tags = {for (final tag in page.items.single.tags) tag.slug: tag};
          expect(tags.keys, unorderedEquals(['support', 'ios', 'bug']));
          expect(tags['support']!.isPrimary, isTrue);
          expect(tags['ios']!.isChild, isTrue);
          expect(tags['bug']!.isPrimary, isFalse);
          expect(tags['support']!.icon, 'fas fa-life-ring');
        });

        test('searches within a tag in the form the version understands', () async {
          final page = await api.discussions(query: 'thread', tagSlug: 'support');
          expect(page.items.single.title, 'App crashes when opening a long thread');
          final sent = forum.requests.last.queryParameters;
          if (version == FlarumVersion.v1) {
            // 1.x ignores other filter keys once filter[q] is present.
            expect(sent['filter[q]'], 'thread tag:support');
            expect(sent.containsKey('filter[tag]'), isFalse);
          } else {
            expect(sent['filter[q]'], 'thread');
            expect(sent['filter[tag]'], 'support');
          }
        });

        test('lists followed discussions', () async {
          final page = await api.discussions(following: true);
          expect(page.items.single.title, 'Feature request: dark mode');
          expect(page.items.single.subscription, 'follow');
        });

        test('reads one discussion with the reader\'s read state', () async {
          final discussion = await api.discussion(forum.discussionId('welcome'));
          expect(discussion.title, 'Welcome to the test forum');
          expect(discussion.lastPostNumber, 4);
          expect(discussion.lastReadPostNumber, 2);
          expect(discussion.canReply, isTrue);
        });
      });

      group('posts', () {
        test('pages a 60-post discussion by offset, capped at 50', () async {
          final id = forum.discussionId('long');
          final first = await api.posts(id, limit: 50);
          expect(first.items.map((p) => p.number), List.generate(50, (i) => i + 1));
          expect(first.hasMore, isTrue);

          final second = await api.posts(id, offset: first.nextOffset!, limit: 50);
          expect(second.items.map((p) => p.number), List.generate(10, (i) => i + 51));
          expect(second.hasMore, isFalse);
          // The next page is built from the offset; links.next (wrong on 2.0) is never followed.
          expect(forum.requests.last.path, '/posts');
          expect(forum.requests.last.queryParameters['page[offset]'], '50');
        });

        test('a discussion lists its post ids in order, which line up with the offsets', () async {
          final id = forum.discussionId('long');
          final discussion = await api.discussion(id, withPostIds: true);
          expect(discussion.postIds, hasLength(60));
          final page = await api.posts(id, offset: 50, limit: 50);
          expect(page.items.map((p) => p.id), discussion.postIds.sublist(50));
          expect((await api.discussion(id)).postIds, version == FlarumVersion.v1 ? isEmpty : hasLength(60),
              reason: '2.0 always sends them');
        });

        test('fetches a page around a post, which contains it', () async {
          final page = await api.postsNear(forum.discussionId('long'), 30, limit: 5);
          expect(page.items, hasLength(5));
          expect(page.items.map((p) => p.number), contains(30));
          expect(page.offset, isNull);
          // 1.x refuses page[near] with a sort.
          expect(forum.requests.single.queryParameters.containsKey('sort'), isFalse);
        });

        test('reads rendered mentions and authors', () async {
          final page = await api.posts(forum.discussionId('welcome'));
          expect(page.items.map((p) => p.author?.username), ['admin', 'alice', 'bob', 'carol']);
          expect(page.items.every((p) => p.isComment), isTrue);
          final html = page.items.map((p) => p.contentHtml).join();
          expect('UserMention'.allMatches(html), hasLength(3));
          expect('PostMention'.allMatches(html), hasLength(1));
        });
      });

      test('reads another user, without their private counts', () async {
        final bob = await api.user(forum.userId('bob'));
        expect(bob.username, 'bob');
        expect(bob.displayName, 'bob');
        expect(bob.unreadNotificationCount, isNull);
      });

      test('lists notifications with who sent them and what about', () async {
        final page = await api.notifications();
        expect(
          page.items.map((n) => n.contentType),
          containsAll(['postMentioned', 'postLiked', 'byobuPrivateDiscussionReplied']),
        );
        final liked = page.items.firstWhere((n) => n.contentType == 'postLiked');
        expect(liked.fromUser?.username, isNotNull);
        expect(liked.subject?.type, 'posts');
        expect(liked.postId, liked.subject?.id);
        expect(liked.postNumber, 2);
        expect(liked.discussionId, forum.discussionId('welcome'), reason: 'a post subject brings its discussion');
        expect(liked.discussionTitle, 'Welcome to the test forum');
        expect(liked.discussionSlug, '${forum.discussionId('welcome')}-welcome-to-the-test-forum');

        final reply = page.items.firstWhere((n) => n.contentType == 'byobuPrivateDiscussionReplied');
        expect(reply.discussionId, forum.discussionId('private'), reason: 'the subject is the discussion');
        expect(reply.discussionTitle, 'Private: test plan');
        expect(reply.postId, isNull);
        expect(reply.postNumber, 3, reason: 'from content.postNumber');
      });

      group('errors', () {
        test('a missing discussion is not_found', () async {
          final error = await _failure(() => api.discussion('999999'));
          expect(error.isNotFound, isTrue);
          expect(error.errors.single.code, 'not_found');
        });

        test('a guest listing notifications is not_authenticated', () async {
          final error = await _failure(() => forum.api(signedIn: false).notifications());
          expect(error.isUnauthorized, isTrue);
          expect(error.errors.single.code, 'not_authenticated');
        });

        test('an invalid discussion is a validation error naming the field', () async {
          final error = await _failure(() => api.client.post('/discussions', {
                'data': {
                  'type': 'discussions',
                  'attributes': {'title': '', 'content': ''},
                },
              }));
          expect(error.isValidationError, isTrue);
          expect(error.errors.first.pointer, startsWith('/data/'));
          // 1.x stops at the first failed rule; 2.0 reports every invalid field.
          expect(error.errors, hasLength(version == FlarumVersion.v2 ? 2 : 1));
        });

        test('an unknown query parameter is rejected on 2.0 only', () async {
          final call = api.client.get('/posts', query: {'filter[discussion]': forum.discussionId('welcome'), 'foo': 'bar'});
          if (version == FlarumVersion.v2) {
            final error = await _failure(() => call);
            expect(error.statusCode, 400);
            expect(error.errors.single.parameter, 'foo');
          } else {
            expect((await call).data, isNotEmpty);
          }
        });
      });
    });
  }

  test('a page limit above 50 is sent as 50', () async {
    final forum = FixtureForum(FlarumVersion.v2);
    // No fixture exists for this request; only what was sent matters.
    await _failure(() => forum.api().discussions(limit: 200));
    expect(forum.requests.single.queryParameters['page[limit]'], '50');
  });

  test('started since a day asks for that day through tomorrow, in UTC', () async {
    final forum = FixtureForum(FlarumVersion.v2);
    await _failure(() => forum.api().discussions(createdSince: DateTime.utc(2026, 3, 1, 23, 30)));
    final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1)).toIso8601String().substring(0, 10);
    expect(forum.requests.single.queryParameters['filter[created]'], '2026-03-01..$tomorrow');
  });

  test('of several excluded tags, the forum gets one and the page drops the rest', () async {
    Map<String, Object> discussion(String id, String tagId) => {
          'type': 'discussions',
          'id': id,
          'attributes': {'title': 'Discussion $id'},
          'relationships': {
            'tags': {
              'data': [
                {'type': 'tags', 'id': tagId},
              ],
            },
          },
        };
    Map<String, Object> tag(String id, String slug) => {
          'type': 'tags',
          'id': id,
          'attributes': {'name': slug, 'slug': slug},
        };
    final adapter = ScriptedAdapter([
      (200, {
        'data': [discussion('1', '1'), discussion('2', '2')],
        'included': [tag('1', 'general'), tag('2', 'ios')],
      }),
    ]);
    final api = FlarumApi(FlarumClient(FixtureForum.baseUrl, dio: adapter.dio()));

    final page = await api.discussions(excludeTagSlugs: ['support', 'ios']);

    expect(adapter.requests.single.queryParameters['filter[-tag]'], 'support');
    expect(page.items.map((d) => d.id), ['1']);
  });
}

Future<FlarumApiException> _failure(Future<Object?> Function() call) async {
  try {
    await call();
  } on FlarumApiException catch (e) {
    return e;
  }
  fail('Expected a FlarumApiException');
}
