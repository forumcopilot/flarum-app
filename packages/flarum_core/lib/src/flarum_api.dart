import 'package:dio/dio.dart' show MultipartFile;

import 'attributes.dart';
import 'flarum_client.dart';
import 'flarum_exception.dart';
import 'json_api.dart';
import 'models/dialog.dart';
import 'models/discussion.dart';
import 'models/draft.dart';
import 'models/flag.dart';
import 'models/forum_info.dart';
import 'models/notification.dart';
import 'models/poll.dart';
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
  oldest('createdAt'),

  /// By title, A to Z and Z to A: 2.0 only (1.x refuses `sort=title` with 400).
  titleAz('title'),
  titleZa('-title');

  const DiscussionSort(this.param);

  final String param;

  /// The sorts [version]'s website offers.
  static List<DiscussionSort> offeredOn(FlarumVersion? version) =>
      version == FlarumVersion.v1 ? const [latest, top, newest, oldest] : values;
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

  /// A thread's posts with their authors, who replied to them and their polls with the reader's
  /// votes, as the web loads them. (fof/polls includes its own by default, but only when the
  /// request names none.)
  static const _postIncludes =
      'user,discussion,mentionedBy,mentionedBy.user,mentionedBy.discussion,likes,polls,polls.options,polls.myVotes,polls.myVotes.option';

  /// The extension an include comes from, for those a forum may not run: flarum/tags' `tags`,
  /// flarum/mentions' `mentionedBy…`, flarum/likes' `likes`, fof/byobu's `recipientUsers` and
  /// fof/polls' `polls…`; null for core's. A forum without the extension refuses the whole request
  /// (400 invalid_parameter), as the census found on real forums.
  static String? _extensionOf(String include) => switch (include) {
        'tags' => 'tags',
        'likes' => 'likes',
        'recipientUsers' => 'byobu',
        _ when include.startsWith('mentionedBy') => 'mentions',
        _ when include == 'polls' || include.startsWith('polls.') => 'polls',
        _ => null,
      };

  static bool _fromExtension(String include) => _extensionOf(include) != null;

  /// The extension includes this forum refused: left off from then on.
  final _refusedIncludes = <String>{};

  /// GET [path] with [query]'s includes; when the forum refuses ones from an extension it doesn't
  /// run ([_fromExtension]), sent again without them. Only when that works are they given up, so
  /// a request refused for another reason fails as it was. With more than one extension's
  /// includes, each is tried on its own, once, to give up only those the forum refuses (neither
  /// version's 400 says which: 1.x names none, 2.0 the first).
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
      final core = [...wanted.where((i) => !_fromExtension(i))];
      try {
        var document = await client.get(path, query: including(core));
        final groups = <String, List<String>>{};
        for (final include in optional) {
          (groups[_extensionOf(include)!] ??= []).add(include);
        }
        if (groups.length == 1) {
          _refusedIncludes.addAll(optional);
          return document;
        }
        final accepted = <List<String>>[];
        for (final group in groups.values) {
          try {
            final answer = await client.get(path, query: including([...core, ...group]));
            accepted.add(group);
            document = answer;
          } on FlarumApiException catch (refused) {
            if (refused.statusCode != 400) rethrow;
            _refusedIncludes.addAll(group);
          }
        }
        // None or one accepted: the answer is in hand; more, and they're asked for together.
        if (accepted.length > 1) document = await client.get(path, query: including([...core, ...accepted.expand((g) => g)]));
        return document;
      } catch (_) {
        Error.throwWithStackTrace(e, stack);
      }
    }
  }

  /// The forum's settings and, when signed in, the reader (`actor`).
  Future<FlarumForumInfo> forumInfo() async {
    final info = FlarumForumInfo.fromDocument(await client.get(''));
    _version = info.version;
    // Without fof/polls (or on 2.0 with discussion polls off, which drops its includes too) the
    // forum has no `canStartPolls`: its includes are left off from the start, sparing a refused
    // request and the tries after it, which forums that limit bursts of requests refuse too.
    if (!info.attributes.containsKey('canStartPolls')) {
      _refusedIncludes.addAll(_postIncludes.split(',').where((include) => _extensionOf(include) == 'polls'));
    }
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

  /// Registers this phone for the signed-in reader's pushes on a forum running the Flapp extension
  /// (`POST /flapp-push/devices`): the [handle] the relay gave the phone for this forum, the
  /// [platform] (`android` or `ios`), the [app] and the phone's [locale]. Returns the device's id.
  ///
  /// The device hangs on the token that registers it, which must be sent in the header, as
  /// [client] does; ending that sign-in on the website removes the device too. Registering the
  /// same handle again moves it to this reader and token. A forum keeps 10 devices per reader.
  Future<String> registerFlappDevice({
    required String handle,
    required String platform,
    required String app,
    String? locale,
  }) async {
    final answer = await client.postJson('/flapp-push/devices', {
      'handle': handle,
      'platform': platform,
      'app': app,
      if (locale != null) 'locale': locale,
    });
    final data = answer['data'];
    final id = data is Map ? data['id'] : null;
    if (id is! String || id.isEmpty) throw const FormatException('The forum answered without a device id');
    return id;
  }

  /// Stops pushes to this phone from the forum (`DELETE /flapp-push/devices/{id}`). A device the
  /// forum no longer has (it went with its token, or the relay said it was gone) counts as deleted.
  Future<void> deleteFlappDevice(String id) async {
    try {
      await client.delete('/flapp-push/devices/$id');
    } on FlarumApiException catch (e) {
      if (!e.isNotFound) rethrow;
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
    bool private = false,
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
      if (private) 'filter[private]': '1',
      if (author != null) 'filter[author]': author,
      if (created != null) 'filter[created]': created,
      if (query != null) 'filter[q]': query,
    };
    // Once filter[q] is present, 1.x ignores every other filter key: its search
    // takes those conditions as gambits inside q. 2.0 is the reverse: it reads
    // only filter keys and treats gambits in q as search words.
    // 1.x's bookmarked and private filters (fof/byobu) are gambits only: the key alone lists everything.
    final gambits = (query != null && filters.length > 1 || bookmarked || private) && await version() == FlarumVersion.v1;
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
          if (private) 'is:private',
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
      'include': [
        _discussionIncludes,
        if (withRelevantPost) 'mostRelevantPost,mostRelevantPost.user',
        // Who each private discussion is with.
        if (private) 'recipientUsers',
      ].join(','),
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
  Future<FlarumDiscussion> startDiscussion(String title, String content,
      {List<String> tagIds = const [], FlarumNewPoll? poll}) async {
    final document = await client.post('/discussions', {
      'data': {
        'type': 'discussions',
        // fof/polls puts the poll on the first post; a poll it refuses refuses the discussion
        // (422, pointing at the poll's field).
        'attributes': {'title': title, 'content': content, if (poll != null) 'poll': poll.toJson()},
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

  /// Starts a private discussion (fof/byobu) with the users [recipientIds]; the reader is one of
  /// its people too. It takes no tags: 2.0's byobu drops them, and 1.x's doesn't ask for any.
  /// Members may have only one other person in it unless the forum lets them add more
  /// (`canAddMoreThanTwoUserRecipients`); more is refused with 403.
  Future<FlarumDiscussion> startPrivateDiscussion(String title, String content, List<String> recipientIds) async {
    final document = await client.post('/discussions', {
      'data': {
        'type': 'discussions',
        'attributes': {'title': title, 'content': content},
        'relationships': {'recipientUsers': _users(recipientIds)},
      },
    });
    return FlarumDiscussion.fromResource(document.single, document);
  }

  /// The people in private discussion [id] (fof/byobu).
  Future<List<FlarumUser>> recipients(String id) async {
    final document = await client.get('/discussions/$id', query: {'include': 'recipientUsers'});
    return [for (final user in document.findAll(document.single.toMany('recipientUsers'))) FlarumUser.fromResource(user)];
  }

  /// Sets who's in private discussion [id]: the whole list, as [userIds] (fof/byobu).
  Future<List<FlarumUser>> setRecipients(String id, List<String> userIds) async {
    final document = await client.patch('/discussions/$id', {
      'data': {
        'type': 'discussions',
        'id': id,
        // 2.0 rc.8 fails with 500 on an update with only relationships (see setBestAnswer).
        'attributes': <String, Object?>{},
        'relationships': {'recipientUsers': _users(userIds)},
      },
    });
    return [for (final user in document.findAll(document.single.toMany('recipientUsers'))) FlarumUser.fromResource(user)];
  }

  static Map<String, Object> _users(List<String> ids) => {
        'data': [
          for (final id in ids) {'type': 'users', 'id': id},
        ],
      };

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

  /// Discussion [discussionId]'s first post, alone and without its relations: its opening words
  /// for a list (flarum/sticky's excerpt, which 1.x's lists send only with the first post). Null
  /// when it's gone.
  Future<FlarumPost?> firstPost(String discussionId) async {
    final document = await client.get('/posts', query: {
      'filter[discussion]': discussionId,
      'filter[number]': '1',
      'page[limit]': '1',
    });
    final first = document.data.firstOrNull;
    return first == null ? null : FlarumPost.fromResource(first, document);
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
  Future<FlarumUser> userBySlug(String slug) async {
    final document = await client.get('/users/${Uri.encodeComponent(slug)}', query: {'bySlug': 'true'});
    return FlarumUser.fromResource(document.single, document: document);
  }

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

  /// The posts user [userId] likes, newest first (flarum/likes' `likedBy` filter), as the web's
  /// Likes tab on a profile lists them.
  Future<FlarumPage<FlarumPost>> likedPosts(String userId, {int offset = 0, int limit = 20}) async {
    final document = await client.get('/posts', query: {
      'filter[likedBy]': userId,
      'filter[type]': 'comment',
      'sort': '-createdAt',
      ..._page(offset, limit),
      'include': 'user,discussion',
    });
    return _postPage(document, offset);
  }

  /// The posts that mention user [userId], newest first (flarum/mentions' `mentioned` filter), as
  /// the web's Mentions tab on a profile lists them.
  Future<FlarumPage<FlarumPost>> mentionedPosts(String userId, {int offset = 0, int limit = 20}) async {
    final document = await client.get('/posts', query: {
      'filter[mentioned]': userId,
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

  /// Each tag's latest discussion (the one last posted in), by tag id, as the web's Tags page shows
  /// it under each tag. Tags with none the reader may see are left out.
  Future<Map<String, FlarumDiscussion>> tagsLatestDiscussions() async {
    final document = await client.get('/tags', query: {'include': 'lastPostedDiscussion'});
    return {
      for (final tag in document.data)
        if (document.find(tag.toOne('lastPostedDiscussion')) case final discussion?)
          tag.id: FlarumDiscussion.fromResource(discussion, document),
    };
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

  /// The forum's flagged posts, newest first, for its moderators (flarum/flags): each flag with who
  /// raised it and the post, its author and its discussion (the endpoint's default includes). 1.x
  /// sends one flag per post, all at once; 2.0 pages them. Listing them clears the moderator's
  /// new-flag count, as opening the web's list does.
  Future<FlarumPage<FlarumFlag>> flags({int offset = 0, int limit = 20}) async {
    final document = await client.get('/flags', query: _page(offset, limit));
    return FlarumPage(
      [for (final resource in document.data) FlarumFlag.fromResource(resource, document)],
      offset: offset,
      hasMore: document.hasNext,
    );
  }

  /// Dismisses every flag on post [postId] (the web's Dismiss Flag).
  Future<void> dismissFlags(String postId) => client.delete('/posts/$postId/flags');

  /// Puts discussion [id] in [tagIds] (flarum/tags), as the web's Edit Tags does. 2.0 rc.8 fails
  /// with 500 on a PATCH with relationships alone, so it carries empty attributes too.
  Future<FlarumDiscussion> setDiscussionTags(String id, List<String> tagIds) async {
    final document = await client.patch('/discussions/$id', {
      'data': {
        'type': 'discussions',
        'id': id,
        'attributes': <String, Object?>{},
        'relationships': {
          'tags': {
            'data': [for (final tag in tagIds) {'type': 'tags', 'id': tag}],
          },
        },
      },
    });
    return FlarumDiscussion.fromResource(document.single, document);
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

  /// fof/terms' policies: 1.x has its own routes, 2.0 an API resource.
  // ---- fof/drafts: the reader's own, saved with `canSaveDrafts`. Nothing on the forum deletes one
  // once it's posted: the writer's app does. ----

  /// The reader's drafts, the latest first. 2.0 pages them; 1.x sends them all, in no order.
  Future<FlarumPage<FlarumDraft>> drafts({int offset = 0, int limit = 20}) async {
    if (await version() == FlarumVersion.v2) {
      final document = await client.get('/drafts', query: {'sort': '-updatedAt', ..._page(offset, limit)});
      return FlarumPage(
        [for (final resource in document.data) FlarumDraft.fromResource(resource)],
        offset: offset,
        hasMore: document.hasNext,
        total: _total(document),
      );
    }
    final document = await client.get('/drafts');
    final epoch = DateTime.utc(1970);
    // Saved within the same second, the later has the higher id.
    final all = [for (final resource in document.data) FlarumDraft.fromResource(resource)]
      ..sort((a, b) => switch ((b.updatedAt ?? epoch).compareTo(a.updatedAt ?? epoch)) {
            0 => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0),
            final order => order,
          });
    return FlarumPage(all, offset: 0, hasMore: false, total: all.length);
  }

  /// Saves a draft, or draft [id] again: a reply to [discussionId], or a new discussion with its
  /// [title] and [tagIds], or a private one with [recipientIds]. [content] mustn't be empty (2.0
  /// refuses it). On 1.x a saved draft's title and text can't be emptied, only changed.
  Future<FlarumDraft> saveDraft({
    String? id,
    String? title,
    required String content,
    String? discussionId,
    List<String> tagIds = const [],
    List<String> recipientIds = const [],
  }) async {
    final relationships =
        FlarumDraft.relationshipsFor(discussionId: discussionId, tagIds: tagIds, recipientIds: recipientIds);
    final v2 = await version() == FlarumVersion.v2;
    final body = {
      'data': {
        'type': 'drafts',
        if (id != null) 'id': id,
        'attributes': {
          if (title != null && title.isNotEmpty) 'title': title,
          'content': content,
          // 2.0 keeps them as an attribute, and needs one on create, empty or not.
          if (v2) 'relationships': relationships,
        },
        // 1.x takes them as JSON:API's own (and leaves a draft's as they were when there are none).
        if (!v2 && relationships.isNotEmpty) 'relationships': relationships,
      },
    };
    final document = id == null ? await client.post('/drafts', body) : await client.patch('/drafts/$id', body);
    return FlarumDraft.fromResource(document.single);
  }

  /// Deletes draft [id]: the writer posted it, or threw it away.
  Future<void> deleteDraft(String id) => client.delete('/drafts/$id');

  // ---- fof/polls: polls belong to posts, and a thread's posts come with theirs. ----

  /// fof/polls' routes: `/fof/polls` on 1.x, `/polls` on 2.0.
  Future<String> _pollsPath() async => await version() == FlarumVersion.v2 ? '/polls' : '/fof/polls';

  /// Votes in poll [id] for [optionIds], the reader's whole choice: an empty list takes their vote
  /// back, another set changes it (`canChangeVote`). Each id once: the forum would count a
  /// repeated one twice. The poll as it stands after, with the reader's votes and, once they've
  /// voted, its results.
  Future<FlarumPoll> votePoll(String id, List<String> optionIds) async {
    final document = await client.patch('${await _pollsPath()}/$id/votes', {
      'data': {'optionIds': optionIds.toSet().toList()},
    });
    return FlarumPoll.fromResource(document.single, document);
  }

  /// Who voted for what in poll [id], for a reader who may see it (`canSeeVoters`: a public poll
  /// whose results they see).
  Future<List<FlarumPollVote>> pollVotes(String id) async {
    final document = await client.get('${await _pollsPath()}/$id', query: {'include': 'votes,votes.user,votes.option'});
    return [
      for (final vote in document.findAll(document.single.toMany('votes')))
        if (vote.toOne('option')?.id ?? vote.attributes.string('optionId') case final optionId?)
          FlarumPollVote(
            optionId: optionId,
            user: switch (document.find(vote.toOne('user'))) {
              final user? => FlarumUser.fromResource(user),
              null => null,
            },
          ),
    ];
  }

  Future<String> _policiesPath() async => await version() == FlarumVersion.v2 ? '/fof-terms-policies' : '/fof/terms/policies';

  /// Accepts policy [id] (fof/terms) for the reader, which gives them back their permissions once
  /// they've accepted every one they must. Forum info read before this is out of date.
  Future<void> acceptPolicy(String id) async {
    await client.postEmpty('${await _policiesPath()}/$id/accept');
  }

  // ---- Moderation. Each answers 403 for a reader without the permission (the model's `can…`). ----

  /// Locks discussion [id] (flarum/lock), or unlocks it: only moderators may reply while it's locked.
  Future<FlarumDiscussion> setLocked(String id, bool locked) => _patchDiscussion(id, {'isLocked': locked});

  /// Pins discussion [id] to the top of its lists (flarum/sticky), or unpins it.
  Future<FlarumDiscussion> setSticky(String id, bool sticky) => _patchDiscussion(id, {'isSticky': sticky});

  /// Renames discussion [id]: its author may too, for a while after starting it (by default).
  Future<FlarumDiscussion> renameDiscussion(String id, String title) => _patchDiscussion(id, {'title': title});

  /// Hides discussion [id] from everyone but moderators (and restores it): Flarum's soft delete.
  Future<FlarumDiscussion> setDiscussionHidden(String id, bool hidden) => _patchDiscussion(id, {'isHidden': hidden});

  /// Deletes discussion [id] for good, its posts with it.
  Future<void> deleteDiscussion(String id) => client.delete('/discussions/$id');

  /// Hides post [id] (and restores it): its author may hide their own until someone replies.
  Future<FlarumPost> setPostHidden(String id, bool hidden) => _patchPost(id, {'isHidden': hidden});

  /// Deletes post [id] for good.
  Future<void> deletePost(String id) => client.delete('/posts/$id');

  /// Approves post [id], held for approval (flarum/approval); a discussion's first post approves
  /// the discussion too.
  Future<FlarumPost> approvePost(String id) => _patchPost(id, {'isApproved': true});

  /// Suspends user [id] (flarum/suspend) until [until], or lifts it (null): they keep only a guest's
  /// permissions until then. [message] is shown to them, [reason] to moderators.
  Future<FlarumUser> suspend(String id, DateTime? until, {String? reason, String? message}) async {
    final document = await client.patch('/users/$id', {
      'data': {
        'type': 'users',
        'id': id,
        'attributes': {
          'suspendedUntil': until?.toUtc().toIso8601String(),
          if (until != null) ...{'suspendReason': reason, 'suspendMessage': message},
        },
      },
    });
    return FlarumUser.fromResource(document.single);
  }

  // ---- flarum/messages (2.0's direct messages). ----

  /// The reader's dialogs, the latest first, with their people and last message.
  Future<FlarumPage<FlarumDialog>> dialogs({int offset = 0, int limit = 20}) async {
    final document = await client.get('/dialogs', query: {
      'sort': '-lastMessageAt',
      ..._page(offset, limit),
      'include': 'users,lastMessage,lastMessageUser',
    });
    return FlarumPage(
      [for (final resource in document.data) FlarumDialog.fromResource(resource, document)],
      offset: offset,
      hasMore: document.hasNext,
      total: _total(document),
    );
  }

  /// The reader's dialog with user [userId] alone, if they have one: flarum/messages can't filter
  /// dialogs by person, so this reads the reader's list, the latest first, up to [pages] pages (a
  /// first message to them would find an older one on the forum anyway).
  Future<FlarumDialog?> dialogWith(String userId, {int pages = 5}) async {
    var offset = 0;
    for (var i = 0; i < pages; i++) {
      final page = await dialogs(offset: offset);
      for (final dialog in page.items) {
        if (dialog.users.length == 2 && dialog.users.any((user) => user.id == userId)) return dialog;
      }
      if (!page.hasMore) break;
      offset += page.items.length;
    }
    return null;
  }

  /// Dialog [id], with its people.
  Future<FlarumDialog> dialog(String id) async {
    final document = await client.get('/dialogs/$id', query: {'include': 'users'});
    return FlarumDialog.fromResource(document.single, document);
  }

  /// A page of dialog [dialogId]'s messages, the newest first, with their authors.
  Future<FlarumPage<FlarumDialogMessage>> dialogMessages(String dialogId, {int offset = 0, int limit = 20}) async {
    final document = await client.get('/dialog-messages', query: {
      'filter[dialog]': dialogId,
      ..._page(offset, limit),
      'include': 'user',
    });
    return FlarumPage(
      [for (final resource in document.data) FlarumDialogMessage.fromResource(resource, document)],
      offset: offset,
      hasMore: document.hasNext,
      total: _total(document),
    );
  }

  /// Sends [content] in dialog [dialogId], or to [userIds]: the forum finds the dialog it has with
  /// them, or starts one. The message, with its dialog's id.
  Future<FlarumDialogMessage> sendMessage(String content, {String? dialogId, List<String> userIds = const []}) async {
    final document = await client.post('/dialog-messages', {
      'data': {
        'type': 'dialog-messages',
        'attributes': {
          'content': content,
          if (dialogId == null) 'users': [for (final id in userIds) {'id': id}],
        },
        if (dialogId != null)
          'relationships': {
            'dialog': {
              'data': {'type': 'dialogs', 'id': dialogId},
            },
          },
      },
    });
    return FlarumDialogMessage.fromResource(document.single, document);
  }

  /// Records that the reader has read dialog [dialogId] up to message [messageId].
  Future<void> markDialogRead(String dialogId, String messageId) async {
    await client.patch('/dialogs/$dialogId', {
      'data': {
        'type': 'dialogs',
        'id': dialogId,
        'attributes': {'lastReadMessageId': int.tryParse(messageId) ?? messageId},
      },
    });
  }

  /// Marks all the reader's conversations read (flarum/messages, 2.0), as the messages page's
  /// Mark all as read does.
  Future<void> markAllDialogsRead() => client.postEmpty('/dialogs/read');

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

  /// Changes the reader [userId]'s [preferences] (the forum's settings page): each key as given,
  /// the rest as they were. `notify_<type>_alert` and `_email` are its notification grid.
  Future<void> savePreferences(String userId, Map<String, Object?> preferences) async {
    await client.patch('/users/$userId', {
      'data': {
        'type': 'users',
        'id': userId,
        'attributes': {'preferences': preferences},
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
