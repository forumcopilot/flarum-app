import 'attributes.dart';
import 'flarum_client.dart';
import 'flarum_exception.dart';
import 'json_api.dart';
import 'models/discussion.dart';
import 'models/forum_info.dart';
import 'models/notification.dart';
import 'models/post.dart';
import 'models/user.dart';

/// How to order a discussion list. These are the forum home's views.
enum DiscussionSort {
  latest('-lastPostedAt'),
  top('-commentCount'),
  newest('-createdAt'),
  oldest('createdAt');

  const DiscussionSort(this.param);

  final String param;
}

/// One page of a list. Flarum pages by offset; [hasMore] comes from the
/// presence of `links.next`, which is never followed (see [JsonApiDocument.hasNext]).
class FlarumPage<T> {
  const FlarumPage(this.items, {required this.offset, required this.hasMore});

  final List<T> items;

  /// The page's offset; null for a page fetched around a post ([FlarumApi.postsNear]).
  final int? offset;
  final bool hasMore;

  int? get nextOffset => offset == null ? null : offset! + items.length;
}

/// A signed-in session: the API token and the reader's user id.
class FlarumSession {
  const FlarumSession({required this.token, required this.userId});

  final String token;
  final String userId;
}

/// Flarum's REST API for one forum, the same calls on 1.8 and 2.0.
///
/// Every query parameter sent here is one both versions accept; keep it that
/// way, because 2.0 rejects unknown parameters with HTTP 400.
class FlarumApi {
  FlarumApi(this.client);

  final FlarumClient client;

  /// The most items Flarum returns per page; larger limits are cut to this.
  static const maxPageSize = 50;

  static const _discussionIncludes = 'user,lastPostedUser,tags';

  /// The forum's settings and, when signed in, the reader (`actor`).
  Future<FlarumForumInfo> forumInfo() async => FlarumForumInfo.fromDocument(await client.get(''));

  /// Signs in with a username or email and password, and keeps the token on [client].
  ///
  /// This is the native form path. It fails on forums that guard log-in with a
  /// CAPTCHA (Turnstile, reCAPTCHA), which is why the app signs in through a web view.
  /// [remember] asks for a long-lived token instead of a 1-hour session token.
  Future<FlarumSession> logIn(String identification, String password, {bool remember = true}) async {
    final json = await client.postJson('/token', {
      'identification': identification,
      'password': password,
      if (remember) 'remember': 1,
    });
    final session = FlarumSession(token: json['token'] as String, userId: '${json['userId']}');
    client.token = session.token;
    return session;
  }

  /// Signs out: revokes the reader's token on the forum, then clears it from [client].
  ///
  /// Flarum has no "revoke this token" call. The token's id is found in
  /// `/access-tokens`, where only a token presented as the remember cookie is
  /// marked current, and deleted by id. Works the same on 1.8 and 2.0.
  ///
  /// Returns false if the forum accepted the token but marked none current, so
  /// nothing was revoked. A token the forum already rejects counts as revoked.
  /// Other failures (e.g. no network) are rethrown and the token is kept, so
  /// the caller can retry.
  Future<bool> logOut() async {
    if (client.token == null) return true;
    var revoked = true;
    try {
      final tokens = await client.getWithRememberCookie('/access-tokens');
      final current = tokens.data.where((token) => token.attributes.boolean('isCurrent') ?? false).firstOrNull;
      if (current == null) {
        revoked = false;
      } else {
        await client.delete('/access-tokens/${current.id}');
      }
    } on FlarumApiException catch (e) {
      if (!e.isUnauthorized) rethrow;
    }
    client.token = null;
    return revoked;
  }

  /// A page of discussions. [tagSlug] limits it to a tag, [following] to
  /// discussions the reader follows, and [query] runs a full-text search.
  Future<FlarumPage<FlarumDiscussion>> discussions({
    DiscussionSort sort = DiscussionSort.latest,
    String? tagSlug,
    bool following = false,
    String? query,
    int offset = 0,
    int limit = 20,
  }) async {
    final document = await client.get('/discussions', query: {
      if (tagSlug != null) 'filter[tag]': tagSlug,
      if (following) 'filter[subscription]': 'following',
      if (query != null) 'filter[q]': query,
      'sort': sort.param,
      ..._page(offset, limit),
      'include': _discussionIncludes,
    });
    return FlarumPage(
      [for (final resource in document.data) FlarumDiscussion.fromResource(resource, document)],
      offset: offset,
      hasMore: document.hasNext,
    );
  }

  Future<FlarumDiscussion> discussion(String id) async {
    final document = await client.get('/discussions/$id', query: {'include': _discussionIncludes});
    return FlarumDiscussion.fromResource(document.single, document);
  }

  /// A page of a discussion's posts in number order, through `/posts` (the same
  /// on both versions) rather than the discussion's own `posts` relationship.
  Future<FlarumPage<FlarumPost>> posts(String discussionId, {int offset = 0, int limit = 20}) async {
    final document = await client.get('/posts', query: {
      'filter[discussion]': discussionId,
      'sort': 'number',
      ..._page(offset, limit),
      'include': 'user',
    });
    return _postPage(document, offset);
  }

  /// A page of posts around post [number], for opening a discussion at the
  /// reader's last read post or a linked post.
  ///
  /// The page contains [number], but its position in the page differs by
  /// version: 2.0 centres it, while 1.x places it by creation time and can
  /// land a post or two off-centre. Find the post by its number, not by index.
  Future<FlarumPage<FlarumPost>> postsNear(String discussionId, int number, {int limit = 20}) async {
    // 1.x refuses page[near] together with a sort parameter, so none is sent.
    final document = await client.get('/posts', query: {
      'filter[discussion]': discussionId,
      'page[near]': '$number',
      'page[limit]': '${_clampLimit(limit)}',
      'include': 'user',
    });
    return _postPage(document, null);
  }

  Future<FlarumUser> user(String id) async => FlarumUser.fromResource((await client.get('/users/$id')).single);

  /// A page of the reader's notifications, newest first.
  ///
  /// Listing them resets the reader's "new" badge on the website
  /// (`newNotificationCount`), so poll [forumInfo]'s actor counts first and list
  /// only when they rise.
  Future<FlarumPage<FlarumNotification>> notifications({int offset = 0, int limit = 20}) async {
    final document = await client.get('/notifications', query: {
      ..._page(offset, limit),
      'include': 'fromUser,subject',
    });
    return FlarumPage(
      [for (final resource in document.data) FlarumNotification.fromResource(resource, document)],
      offset: offset,
      hasMore: document.hasNext,
    );
  }

  FlarumPage<FlarumPost> _postPage(JsonApiDocument document, int? offset) => FlarumPage(
        [for (final resource in document.data) FlarumPost.fromResource(resource, document)],
        offset: offset,
        hasMore: document.hasNext,
      );

  static Map<String, String> _page(int offset, int limit) =>
      {'page[offset]': '$offset', 'page[limit]': '${_clampLimit(limit)}'};

  static int _clampLimit(int limit) => limit.clamp(1, maxPageSize);
}
