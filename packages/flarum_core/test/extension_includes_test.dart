import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// A forum without flarum/mentions or flarum/tags refuses a request that includes their
/// relationships (400 invalid_parameter), as some census forums do.
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

  test('posts without flarum/mentions: sent again without mentionedBy, which stays off', () async {
    final adapter = ScriptedAdapter([refused, noPosts, noPosts]);
    final forum = api(adapter);
    await forum.posts('1');
    expect(include(adapter, 0), contains('mentionedBy'));
    expect(include(adapter, 1), 'user,discussion');
    await forum.postsNear('1', 5);
    expect(include(adapter, 2), 'user,discussion', reason: 'no second refusal');
    expect(adapter.requests, hasLength(3));
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
