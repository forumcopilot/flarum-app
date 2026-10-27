import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// A forum without flarum/mentions, flarum/tags or fof/polls refuses a request that includes their
/// relationships (400 invalid_parameter), as some census forums do, without saying which.
void main() {
  const refused = (400, {
    'errors': [
      {'status': '400', 'code': 'invalid_parameter'},
    ],
  });
  const noPosts = (200, {'data': <Object>[]});
  const discussion = (200, {
    'data': {'type': 'discussions', 'id': '1', 'attributes': {'title': 'Hello'}},
  });

  FlarumApi api(ScriptedAdapter adapter) => FlarumApi(FlarumClient(FixtureForum.baseUrl, dio: adapter.dio()));
  String? include(ScriptedAdapter adapter, int i) => adapter.requests[i].queryParameters['include'] as String?;

  const pollIncludes = 'polls,polls.options,polls.myVotes,polls.myVotes.option';

  /// A post's includes from Flarum itself: its author with their groups (the web's badges).
  const core = 'user,user.groups,discussion';

  test('posts without flarum/mentions: each extension tried once, and only mentionedBy stays off', () async {
    // Refused; without any extension's; mentions alone, refused; likes alone; polls alone; fof/geoip
    // alone; the three.
    final adapter = ScriptedAdapter([refused, noPosts, refused, noPosts, noPosts, noPosts, noPosts, noPosts]);
    final forum = api(adapter);
    await forum.posts('1');
    expect(include(adapter, 0), contains('mentionedBy'));
    expect(include(adapter, 1), core);
    expect(include(adapter, 2), '$core,mentionedBy,mentionedBy.user,mentionedBy.discussion');
    expect(include(adapter, 3), '$core,likes');
    expect(include(adapter, 4), '$core,$pollIncludes');
    expect(include(adapter, 5), '$core,ipInfo');
    expect(include(adapter, 6), '$core,likes,$pollIncludes,ipInfo');
    await forum.postsNear('1', 5);
    expect(include(adapter, 7), '$core,likes,$pollIncludes,ipInfo', reason: 'no second refusal');
    expect(adapter.requests, hasLength(8));
  });

  test('posts without fof/polls, flarum/likes or fof/geoip: one extension accepted is the answer already', () async {
    final adapter = ScriptedAdapter([refused, noPosts, noPosts, refused, refused, refused, noPosts]);
    final forum = api(adapter);
    await forum.posts('1');
    expect(adapter.requests, hasLength(6));
    await forum.posts('1');
    expect(include(adapter, 6), '$core,mentionedBy,mentionedBy.user,mentionedBy.discussion');
  });

  test('a forum whose info has no canStartPolls is asked for no poll includes at all', () async {
    const withoutPolls = (200, {
      'data': {
        'type': 'forums',
        'id': '1',
        'attributes': {'title': 'No polls', 'baseUrl': FixtureForum.baseUrl},
      },
    });
    final adapter = ScriptedAdapter([withoutPolls, noPosts]);
    final forum = api(adapter);
    await forum.forumInfo();
    await forum.posts('1');
    expect(include(adapter, 1), isNot(contains('polls')));
    expect(include(adapter, 1), contains('mentionedBy'));
    expect(adapter.requests, hasLength(2), reason: 'nothing refused');
  });

  test('discussions without flarum/tags: sent again without tags', () async {
    final adapter = ScriptedAdapter([refused, discussion, discussion]);
    final forum = api(adapter);
    expect((await forum.discussion('1')).title, 'Hello');
    expect(include(adapter, 0), 'user,lastPostedUser,tags');
    expect(include(adapter, 1), 'user,lastPostedUser');
    await forum.discussion('1');
    expect(include(adapter, 2), 'user,lastPostedUser');
  });

  test('a request refused for another reason fails as it was, and keeps its includes', () async {
    final adapter = ScriptedAdapter([refused, refused, noPosts]);
    final forum = api(adapter);
    await expectLater(forum.posts('1'), throwsA(isA<FlarumApiException>().having((e) => e.statusCode, 'status', 400)));
    await forum.posts('1');
    expect(include(adapter, 2), contains('mentionedBy'));
  });
}
