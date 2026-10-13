import 'package:dio/dio.dart' show MultipartFile;

import 'attributes.dart';
import 'flarum_client.dart';
import 'flarum_exception.dart';
import 'json_api.dart';
import 'models/discussion.dart';
import 'models/forum_info.dart';
import 'models/notification.dart';
import 'models/post.dart';
import 'models/tag.dart';
import 'models/upload.dart';
import 'models/user.dart';

/// How to order a discussion list. These are the forum home's views.
enum DiscussionSort {
  /// The forum's default order, so [FlarumApi.discussions] sends no `sort` for it: only then are
  /// stickied discussions pinned to the top. [param] is what that order is.
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
  const FlarumPage(this.items, {required this.offset, required this.hasMore, this.total});

  final List<T> items;

  /// The page's offset; null for a page fetched around a post ([FlarumApi.postsNear]).
  final int? offset;
  final bool hasMore;

  /// How many there are in all, when the forum says: 2.0 does (`meta.page.total`), 1.x doesn't.
  final int? total;

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

  /// A thread's posts with their authors and who replied to them, as the web
  /// loads them.
  static const _postIncludes = 'user,discussion,mentionedBy,mentionedBy.user,mentionedBy.discussion,likes';

  /// Includes from extensions a forum may not run: flarum/tags' `tags`, flarum/mentions'
  /// `mentionedBy…` and flarum/likes' `likes`. A forum without the extension refuses the whole
  /// request (400 invalid_parameter), as the census found on real forums.
  static bool _fromExtension(String include) =>
      include == 'tags' || include == 'likes' || include.startsWith('mentionedBy');

  /// The extension includes this forum refused: left off from then on.
  final _refusedIncludes = <String>{};

  /// GET [path] with [query]'s includes; when the forum refuses ones from an extension it doesn't
  /// run ([_fromExtension]), sent again without them. Only when that works are they given up, so
  /// a request refused for another reason fails as it was.
  Future<JsonApiDocument> _getIncluding(String path, {required Map<String, String> query}) async {
    final wanted = [
      for (final include in (query['include'] ?? '').split(','))
        if (include.isNotEmpty && !_refusedIncludes.contains(include)) include,
    ];
    Map<String, String> including(List<String> includes) => {
          for (final MapEntry(:key, :value) in query.entries)
            if (key != 'include') key: value,
          if (includes.isNotEmpty) 'include': includes.join(','),
        };
    try {
      return await client.get(path, query: including(wanted));
    } on FlarumApiException catch (e, stack) {
      final optional = wanted.where(_fromExtension).toList();
      if (e.statusCode != 400 || optional.isEmpty) rethrow;
      final JsonApiDocument document;
      try {
        document = await client.get(path, query: including([...wanted.where((i) => !_fromExtension(i))]));
      } catch (_) {
        Error.throwWithStackTrace(e, stack);
      }
      _refusedIncludes.addAll(optional);
      return document;
    }
  }

  /// The forum's settings and, when signed in, the reader (`actor`).
  Future<FlarumForumInfo> forumInfo() async {
    final info = FlarumForumInfo.fromDocument(await client.get(''));
    _version = info.version;
    return info;
  }

  FlarumVersion? _version;

  /// The forum's major version, as the last [forumInfo] saw it; fetched once if needed.
  Future<FlarumVersion> version() async => _version ?? (await forumInfo()).version;

  /// Signs in with a username or email and password, and keeps the token on [client].
  ///
  /// This is the native form path. Some CAPTCHA extensions block it (2.0's
  /// flectar/flarum-turnstile answers 422 on `turnstileToken`), which is why the
  /// app signs in through a web view.
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
      final current = await _currentAccessToken();
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

  /// The reader's token as listed in `/access-tokens`. The list is paged, oldest
  /// first, and a reader with many sessions (one per device and sign-in) has
  /// the newest, likely current, one beyond the first page.
  Future<JsonApiResource?> _currentAccessToken() async {
    for (var offset = 0;; offset += maxPageSize) {
      final tokens = await client.getWithRememberCookie('/access-tokens', query: _page(offset, maxPageSize));
      final current = tokens.data.where((token) => token.attributes.boolean('isCurrent') ?? false).firstOrNull;
      if (current != null || !tokens.hasNext || tokens.data.isEmpty) return current;
    }
  }

  /// A page of discussions. [tagSlug] limits it to a tag (or any of several,
  /// joined by commas), [excludeTagSlugs] leaves tags out, [following] keeps
  /// discussions the reader follows, [unread] ones with posts the reader hasn't
  /// read, [sticky] stickied ones, [author] those a user started, and
  /// [createdSince] those started on or after that day. [query] runs a
  /// full-text search; with no [sort] its results come most relevant first,
  /// and [withRelevantPost] brings each one's best-matching post.
  Future<FlarumPage<FlarumDiscussion>> discussions({
    DiscussionSort? sort = DiscussionSort.latest,
    String? tagSlug,
    List<String> excludeTagSlugs = const [],
    bool following = false,
    bool unread = false,
    bool sticky = false,
    bool bookmarked = false,
    String? author,
    DateTime? createdSince,
    String? query,
    bool withRelevantPost = false,
    int offset = 0,
    int limit = 20,
  }) async {
    // Through a day after today, so posts from today in any time zone count.
    final created = createdSince == null ? null : '${_day(createdSince)}..${_day(DateTime.now().add(const Duration(days: 1)))}';
    final filters = {
      if (tagSlug != null) 'filter[tag]': tagSlug,
      // The key takes one tag (2.0 reads `-tag=a,b` as a condition that
      // excludes neither); the rest are dropped from the page below.
      if (excludeTagSlugs.isNotEmpty) 'filter[-tag]': excludeTagSlugs.first,
      if (following) 'filter[subscription]': 'following',
      if (unread) 'filter[unread]': '1',
      if (sticky) 'filter[sticky]': '1',
      if (bookmarked) 'filter[bookmarked]': '1',
      if (author != null) 'filter[author]': author,
      if (created != null) 'filter[created]': created,
      if (query != null) 'filter[q]': query,
    };
    // Once filter[q] is present, 1.x ignores every other filter key: its search
    // takes those conditions as gambits inside q. 2.0 is the reverse: it reads
    // only filter keys and treats gambits in q as search words.
    // 1.x's bookmarked filter is a gambit only: the key alone lists everything.
    final gambits = (query != null && filters.length > 1 || bookmarked) && await version() == FlarumVersion.v1;
    if (gambits) {
      filters
        ..clear()
        ..['filter[q]'] = [
          if (query != null) query,
          if (tagSlug != null) 'tag:$tagSlug',
          for (final slug in excludeTagSlugs) '-tag:$slug',
          if (following) 'is:following',
          if (unread) 'is:unread',
          if (sticky) 'is:sticky',
          if (bookmarked) 'is:bookmarked',
          if (author != null) 'author:$author',
          if (created != null) 'created:$created',
        ].join(' ');
    }
    final document = await _getIncluding('/discussions', query: {
      ...filters,
      // Latest is the forum's own order, so it's left to the forum: only then does flarum/sticky
      // pin stickied discussions to the top, as the web's default view shows them.
      if (sort != null && sort != DiscussionSort.latest) 'sort': sort.param,
      ..._page(offset, limit),
      // 1.x refuses mostRelevantPost.discussion; the post gets its discussion from the row instead.
      'include': withRelevantPost ? '$_discussionIncludes,mostRelevantPost,mostRelevantPost.user' : _discussionIncludes,
    });
    final discussions = [for (final resource in document.data) FlarumDiscussion.fromResource(resource, document)];
    final excluded = gambits ? const <String>{} : excludeTagSlugs.skip(1).toSet();
    return FlarumPage(
      [
        for (final d in discussions)
          if (!d.tags.any((tag) => excluded.contains(tag.slug))) d,
      ],
      offset: offset,
      hasMore: document.hasNext,
      total: _total(document),
    );
  }

  /// Posts matching [query], most relevant first. [author] (a username),
  /// [discussionId] and [tag] narrow it.
  ///
  /// 1.x has no post search: its `/posts` ignores `filter[q]`. There the
  /// results come from the discussion search, one post per discussion (the one
  /// that matches best), so an [author] keeps only the posts they wrote, and
  /// [discussionId] throws [UnsupportedError].
  Future<FlarumPage<FlarumPost>> searchPosts(
    String query, {
    String? author,
    String? discussionId,
    FlarumTag? tag,
    int offset = 0,
    int limit = 20,
  }) async {
    if (await version() == FlarumVersion.v1) {
      if (discussionId != null) throw UnsupportedError('Flarum 1.x can\'t search within a discussion');
      final page = await discussions(
        query: query,
        sort: null,
        tagSlug: tag?.slug,
        withRelevantPost: true,
        offset: offset,
        limit: limit,
      );
      return FlarumPage(
        [
          for (final d in page.items)
            if (d.mostRelevantPost case final post? when author == null || post.author?.username == author) post,
        ],
        offset: offset,
        hasMore: page.hasMore,
      );
    }
    final document = await client.get('/posts', query: {
      'filter[q]': query,
      if (author != null) 'filter[author]': author,
      if (discussionId != null) 'filter[discussion]': discussionId,
      // By id: 2.0's post tag filter refuses slugs (422).
      if (tag != null) 'filter[tag]': tag.id,
      ..._page(offset, limit),
      'include': 'user,discussion',
    });
    return _postPage(document, offset);
  }

  /// One discussion. [withPostIds] also brings the ids of all its posts
  /// ([FlarumDiscussion.postIds]), which a thread pages through.
  Future<FlarumDiscussion> discussion(String id, {bool withPostIds = false}) async {
    // 2.0 lists the post ids by default and refuses `include=posts` (400);
    // 1.x lists them only when asked (and then also sends 20 posts, unused).
    final posts = withPostIds && await version() == FlarumVersion.v1;
    final document = await _getIncluding('/discussions/$id', query: {
      'include': posts ? '$_discussionIncludes,posts' : _discussionIncludes,
    });
    return FlarumDiscussion.fromResource(document.single, document);
  }

  /// Replies in discussion [discussionId] with [content], its source as Markdown and BBCode. The
  /// reply comes back rendered; a forum can hold it for approval (`isApproved` false). A second
  /// post inside the forum's posting throttle (10 seconds by default) is refused with 429.
  Future<FlarumPost> reply(String discussionId, String content) async {
    final document = await client.post('/posts', {
      'data': {
        'type': 'posts',
        'attributes': {'content': content},
        'relationships': {
          'discussion': {
            'data': {'type': 'discussions', 'id': discussionId},
          },
        },
      },
    });
    return FlarumPost.fromResource(document.single, document);
  }

  /// Starts a discussion: its [title], its first post's [content], and with flarum/tags the tags
  /// [tagIds], as many as the forum's tag rules ask. A refusal (422) names what was wrong: 1.x the
  /// first rule that failed, 2.0 every field.
  Future<FlarumDiscussion> startDiscussion(String title, String content, {List<String> tagIds = const []}) async {
    final document = await client.post('/discussions', {
      'data': {
        'type': 'discussions',
        'attributes': {'title': title, 'content': content},
        if (tagIds.isNotEmpty)
          'relationships': {
            'tags': {
              'data': [
                for (final id in tagIds) {'type': 'tags', 'id': id},
              ],
            },
          },
      },
    });
    return FlarumDiscussion.fromResource(document.single, document);
  }

  /// Saves [content] as post [id]'s source. Only someone who may edit it (its author, a
  /// moderator) can: others get 403.
  Future<FlarumPost> editPost(String id, String content) async {
    final document = await client.patch('/posts/$id', {
      'data': {
        'type': 'posts',
        'id': id,
        'attributes': {'content': content},
      },
    });
    return FlarumPost.fromResource(document.single, document);
  }

  /// Likes post [id] for the reader, or takes the like back (flarum/likes).
  Future<FlarumPost> likePost(String id, {required bool liked}) => _patchPost(id, {'isLiked': liked});

  /// Reacts to post [id] with reaction [reactionId] (fof/reactions). A reader has one reaction a
  /// post: another replaces theirs, and theirs again takes it back. (So does null on 2.0; 1.x
  /// fails with 500 on it, so [unreactToPost] sends theirs again.)
  Future<FlarumPost> reactToPost(String id, String reactionId) => _patchPost(id, {'reaction': reactionId});

  /// Takes the reader's reaction [reactionId] to post [id] back.
  Future<FlarumPost> unreactToPost(String id, String reactionId) => reactToPost(id, reactionId);

  /// Bookmarks post [id] for the reader, or takes the bookmark off (fof/bookmarks).
  Future<FlarumPost> bookmarkPost(String id, {required bool bookmarked}) => _patchPost(id, {'bookmarked': bookmarked});

  Future<FlarumPost> _patchPost(String id, Map<String, Object?> attributes) async {
    final document = await client.patch('/posts/$id', {
      'data': {'type': 'posts', 'id': id, 'attributes': attributes},
    });
    return FlarumPost.fromResource(document.single, document);
  }

  /// Bookmarks discussion [id] for the reader, or takes the bookmark off (fof/bookmarks).
  Future<FlarumDiscussion> bookmarkDiscussion(String id, {required bool bookmarked}) =>
      _patchDiscussion(id, {'bookmarked': bookmarked});

  /// The reader's [level] for discussion [id] (flarum/subscriptions): `follow` (told of every
  /// reply), `ignore` (it leaves their lists), or null for neither.
  Future<FlarumDiscussion> setSubscription(String id, String? level) => _patchDiscussion(id, {'subscription': level});

  /// Chooses post [postId] as discussion [id]'s best answer (fof/best-answer), or none (null).
  /// 1.x takes the post's id as an attribute, 0 for none; 2.0 a relationship, with empty
  /// attributes beside it, without which rc.8 fails with 500.
  Future<FlarumDiscussion> setBestAnswer(String id, String? postId) async {
    if (await version() == FlarumVersion.v1) {
      return _patchDiscussion(id, {'bestAnswerPostId': postId == null ? 0 : int.tryParse(postId) ?? postId});
    }
    final document = await client.patch('/discussions/$id', {
      'data': {
        'type': 'discussions',
        'id': id,
        'attributes': <String, Object?>{},
        'relationships': {
          'bestAnswerPost': {'data': postId == null ? null : {'type': 'posts', 'id': postId}},
        },
      },
    });
    return FlarumDiscussion.fromResource(document.single, document);
  }

  Future<FlarumDiscussion> _patchDiscussion(String id, Map<String, Object?> attributes) async {
    final document = await client.patch('/discussions/$id', {
      'data': {'type': 'discussions', 'id': id, 'attributes': attributes},
    });
    return FlarumDiscussion.fromResource(document.single, document);
  }

  /// The reader's [level] for tag [id] (fof/follow-tags): `follow` (new discussions), `lurk`
  /// (every post), `ignore`, `hide`, or null for none. 1.x has its own route; 2.0 takes the tag's
  /// attribute.
  Future<void> setTagSubscription(String id, String? level) async {
    if (await version() == FlarumVersion.v1) {
      await client.post('/tags/$id/subscription', {
        'data': {'subscription': level},
      });
    } else {
      await client.patch('/tags/$id', {
        'data': {
          'type': 'tags',
          'id': id,
          'attributes': {'subscription': level},
        },
      });
    }
  }

  /// The posts the reader bookmarked (fof/bookmarks), newest first.
  Future<FlarumPage<FlarumPost>> bookmarkedPosts({int offset = 0, int limit = 20}) async {
    final document = await client.get('/posts', query: {
      'filter[bookmarked]': '1',
      'sort': '-createdAt',
      ..._page(offset, limit),
      'include': 'user,discussion',
    });
    return _postPage(document, offset);
  }

  /// Uploads [files] through fof/upload, each with the name it should keep; the uploads, each with
  /// the BBCode that puts it in a post. The forum's size limit (2 MB by default) is the server's to
  /// enforce: it refuses a larger file.
  Future<List<FlarumUpload>> upload(List<MultipartFile> files) async {
    final document = await client.postFiles('/fof/upload', 'files[]', files);
    return [for (final resource in document.data) FlarumUpload.fromResource(resource)];
  }

  /// The file at [path], to [upload] as [name].
  static Future<MultipartFile> fileAt(String path, {required String name}) =>
      MultipartFile.fromFile(path, filename: name);

  /// Deletes upload [uuid] (fof/upload): one the writer took back out of their post.
  Future<void> deleteUpload(String uuid) => client.delete('/fof/upload/delete/$uuid');

  /// Records that the reader has read discussion [id] up to post [number].
  /// Flarum keeps one high-water mark per discussion and never lowers it.
  Future<void> markDiscussionRead(String id, int number) async {
    await client.patch('/discussions/$id', {
      'data': {
        'type': 'discussions',
        'id': id,
        'attributes': {'lastReadPostNumber': number},
      },
    });
  }

  /// A page of a discussion's posts in number order, through `/posts` (the same
  /// on both versions) rather than the discussion's own `posts` relationship.
  Future<FlarumPage<FlarumPost>> posts(String discussionId, {int offset = 0, int limit = 20}) async {
    final document = await _getIncluding('/posts', query: {
      'filter[discussion]': discussionId,
      'sort': 'number',
      ..._page(offset, limit),
      'include': _postIncludes,
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
    final document = await _getIncluding('/posts', query: {
      'filter[discussion]': discussionId,
      'page[near]': '$number',
      'page[limit]': '${_clampLimit(limit)}',
      'include': _postIncludes,
    });
    return _postPage(document, null);
  }

  Future<FlarumUser> user(String id) async => FlarumUser.fromResource((await client.get('/users/$id')).single);

  /// What [user]'s posts and discussions are filtered by (`author`): 2.0 resolves it as a slug,
  /// the user's id on forums with the ID slug driver, while 1.x matches the username.
  Future<String> authorKey(FlarumUser user) async =>
      await version() == FlarumVersion.v2 ? (user.slug ?? user.username) : user.username;

  /// A user by slug, as `/u/{slug}` names them: the username, or the id on forums that use the ID
  /// slug driver (where a username 404s). Without `bySlug` Flarum reads it as an id.
  Future<FlarumUser> userBySlug(String slug) async => FlarumUser.fromResource(
      (await client.get('/users/${Uri.encodeComponent(slug)}', query: {'bySlug': 'true'})).single);

  /// Users matching [query]. Needs the forum's "search users" permission
  /// (`canSearchUsers`); guests get 403 by default.
  Future<FlarumPage<FlarumUser>> searchUsers(String query, {int offset = 0, int limit = 20}) async {
    final document = await client.get('/users', query: {'filter[q]': query, ..._page(offset, limit)});
    return FlarumPage(
      [for (final resource in document.data) FlarumUser.fromResource(resource)],
      offset: offset,
      hasMore: document.hasNext,
    );
  }

  /// A user's comments, newest first, with their discussions.
  Future<FlarumPage<FlarumPost>> userPosts(String username, {int offset = 0, int limit = 20}) async {
    final document = await client.get('/posts', query: {
      'filter[author]': username,
      'filter[type]': 'comment',
      'sort': '-createdAt',
      ..._page(offset, limit),
      'include': 'user,discussion',
    });
    return _postPage(document, offset);
  }

  /// Every tag the reader can see, with each child's parent: primary tags
  /// (the forum's tree, two levels) and secondary ones (labels).
  Future<List<FlarumTag>> tags() async {
    final document = await client.get('/tags', query: {'include': 'parent'});
    return [for (final resource in document.data) FlarumTag.fromResource(resource)];
  }

  /// One post, with its discussion and number (for links to it).
  Future<FlarumPost> post(String id) async {
    final document = await client.get('/posts/$id');
    return FlarumPost.fromResource(document.single, document);
  }

  /// The id of post [number] in a discussion, or null if there's none the reader can see.
  Future<String?> postIdByNumber(String discussionId, int number) async {
    final document = await client.get('/posts', query: {
      'filter[discussion]': discussionId,
      'filter[number]': '$number',
    });
    return document.data.isEmpty ? null : document.data.first.id;
  }

  /// Flags post [id] for the forum's moderators (flarum/flags). [reason] is `off_topic`,
  /// `inappropriate` or `spam`, or null for "Other", which needs a [detail]. A second flag from
  /// the same reader replaces the first.
  Future<void> flagPost(String id, {String? reason, String detail = ''}) async {
    await client.post('/flags', {
      'data': {
        'type': 'flags',
        // reasonDetail always, as the web sends it: 1.x checks for an empty one, and takes a
        // flag with neither as having no reason at all.
        'attributes': {'reason': reason, 'reasonDetail': detail},
        'relationships': {
          'post': {
            'data': {'type': 'posts', 'id': id},
          },
        },
      },
    });
  }

  /// Ignores user [id], or stops (fof/ignore-users): the web then folds their posts away and
  /// they can't start a private discussion with the reader. Returns the user as the reader now
  /// sees them.
  Future<FlarumUser> setIgnored(String id, bool ignored) async {
    final document = await client.patch('/users/$id', {
      'data': {
        'type': 'users',
        'id': id,
        'attributes': {'ignored': ignored},
      },
    });
    return FlarumUser.fromResource(document.single);
  }

  /// Marks every discussion read for the reader [userId]: Flarum records the
  /// time, and treats anything older as read. There's no per-tag version.
  Future<void> markAllAsRead(String userId) async {
    await client.patch('/users/$userId', {
      'data': {
        'type': 'users',
        'id': userId,
        // 2.0 wants a date (422 on `true`); 1.x takes any value and records now.
        'attributes': {'markedAllAsReadAt': DateTime.now().toUtc().toIso8601String()},
      },
    });
  }

  /// A page of the reader's notifications, newest first.
  ///
  /// Listing them resets the reader's "new" badge on the website
  /// (`newNotificationCount`), so poll [forumInfo]'s actor counts first and list
  /// only when they rise.
  Future<FlarumPage<FlarumNotification>> notifications({int offset = 0, int limit = 20}) async {
    final document = await client.get('/notifications', query: {
      ..._page(offset, limit),
      // subject.discussion: on 1.x a post subject carries no discussion otherwise.
      'include': 'fromUser,subject,subject.discussion',
    });
    return FlarumPage(
      [for (final resource in document.data) FlarumNotification.fromResource(resource, document)],
      offset: offset,
      hasMore: document.hasNext,
    );
  }

  /// Marks notification [id] read.
  Future<void> markNotificationRead(String id) async {
    await client.patch('/notifications/$id', {
      'data': {
        'type': 'notifications',
        'id': id,
        'attributes': {'isRead': true},
      },
    });
  }

  /// Marks all the reader's notifications read.
  Future<void> markAllNotificationsRead() => client.postEmpty('/notifications/read');

  FlarumPage<FlarumPost> _postPage(JsonApiDocument document, int? offset) => FlarumPage(
        [for (final resource in document.data) FlarumPost.fromResource(resource, document)],
        offset: offset,
        hasMore: document.hasNext,
        total: _total(document),
      );

  static int? _total(JsonApiDocument document) {
    final page = document.meta['page'];
    return page is Map ? int.tryParse('${page['total'] ?? ''}') : null;
  }

  static String _day(DateTime time) => time.toUtc().toIso8601String().substring(0, 10);

  static Map<String, String> _page(int offset, int limit) =>
      {'page[offset]': '$offset', 'page[limit]': '${_clampLimit(limit)}'};

  static int _clampLimit(int limit) => limit.clamp(1, maxPageSize);
}
