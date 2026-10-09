import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_search_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/results/fc_search_result.dart';

import '../flarum_api.dart';
import '../models/discussion.dart';
import '../models/post.dart';
import '../models/tag.dart';
import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_post_proxy.dart';
import 'flarum_topic_proxy.dart';

/// Search, through Flarum's full-text search: discussions come most relevant
/// first, each with the post that matches best as its excerpt; posts come from
/// 2.0's post search, or on 1.x from each matching discussion's best post
/// (see [FlarumApi.searchPosts]).
///
/// Flarum keeps no search state, so there's no search id; pages are offsets.
class FlarumSearchProxy implements IFCSearchProxy {
  FlarumSearchProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  @override
  Future<FCSearchTopicResult> searchTopicAsync(String searchString, int startNum, int lastNum, String? searchId) async {
    try {
      final query = searchString.trim();
      if (query.isEmpty) return FCSearchTopicResult(result: true, resultText: '', totalTopicNum: 0, topics: const []);
      final (offset, limit) = _range(startNum, lastNum);
      final page = await _forum.api.discussions(query: query, sort: null, withRelevantPost: true, offset: offset, limit: limit);
      return FCSearchTopicResult(
        result: true,
        resultText: '',
        totalTopicNum: _total(page),
        topics: await FlarumTopicProxy(siteContext).topics(page.items),
        hasMore: page.hasMore,
      );
    } catch (e) {
      return FCSearchTopicResult(result: false, resultText: _describe(e), totalTopicNum: 0, topics: const []);
    }
  }

  @override
  Future<FCSearchPostResult> searchPostAsync(String searchString, int startNum, int lastNum, String? searchId) async {
    try {
      final query = searchString.trim();
      if (query.isEmpty) return FCSearchPostResult(result: true, resultText: '', totalPostNum: 0, posts: const []);
      final (offset, limit) = _range(startNum, lastNum);
      final page = await _forum.api.searchPosts(query, offset: offset, limit: limit);
      return FCSearchPostResult(
        result: true,
        resultText: '',
        totalPostNum: _total(page),
        posts: _posts(page.items),
        hasMore: page.hasMore,
      );
    } catch (e) {
      return FCSearchPostResult(result: false, resultText: _describe(e), totalPostNum: 0, posts: const []);
    }
  }

  /// [forumId] and [onlyIn] are tag ids (any of them), [notIn] tags to leave
  /// out, [searchTime] a number of seconds back to the discussion's start.
  ///
  /// Flarum searches titles and posts together, so [titleOnly] keeps the
  /// results whose title has every word of [keywords]; a page can come back
  /// short. An author's discussions are the ones they started, which makes
  /// [startedBy] the only behaviour; [topicId] doesn't apply.
  @override
  Future<FCSearchDataResultTopic> advanceSearchTopicAsync(
    String keywords,
    int page,
    int perpage,
    String? searchId,
    bool titleOnly,
    String? userId,
    String? searchUser,
    String? forumId,
    String? topicId,
    List<String>? onlyIn,
    List<String>? notIn,
    bool startedBy,
    int? searchTime,
  ) async {
    try {
      final query = keywords.trim();
      final offset = _offset(page, perpage);
      final author = await _author(searchUser, userId);
      final tags = await _tags([if (forumId != null && forumId.isNotEmpty) forumId, ...?onlyIn]);
      final result = await _forum.api.discussions(
        query: query.isEmpty ? null : query,
        sort: query.isEmpty ? DiscussionSort.latest : null,
        tagSlug: tags.isEmpty ? null : tags.map((t) => t.slug).join(','),
        excludeTagSlugs: [for (final tag in await _tags(notIn ?? const [])) tag.slug],
        author: author,
        createdSince: searchTime == null || searchTime <= 0 ? null : DateTime.now().subtract(Duration(seconds: searchTime)),
        withRelevantPost: query.isNotEmpty,
        offset: offset,
        limit: perpage,
      );
      final discussions = titleOnly && query.isNotEmpty
          ? [for (final d in result.items) if (_titleHas(d, query)) d]
          : result.items;
      return FCSearchDataResultTopic(
        result: true,
        resultText: '',
        totalTopicNum: titleOnly ? offset + discussions.length + (result.hasMore ? 1 : 0) : _total(result),
        topics: await FlarumTopicProxy(siteContext).topics(discussions),
        hasMore: result.hasMore,
      );
    } catch (e) {
      return FCSearchDataResultTopic(result: false, resultText: _describe(e), totalTopicNum: 0, topics: const []);
    }
  }

  /// [topicId] searches one discussion (2.0 only), [forumId] or the first of
  /// [onlyIn] one tag. With no [keywords], an author's posts are listed newest
  /// first. [titleOnly], [notIn] and [startedBy] don't apply to posts.
  @override
  Future<FCSearchDataResultPost> advanceSearchPostAsync(
    String keywords,
    int page,
    int perpage,
    String? searchId,
    bool titleOnly,
    String? userId,
    String? searchUser,
    String? forumId,
    String? topicId,
    List<String>? onlyIn,
    List<String>? notIn,
    bool startedBy,
  ) async {
    try {
      final query = keywords.trim();
      final offset = _offset(page, perpage);
      final author = await _author(searchUser, userId);
      final FlarumPage<FlarumPost> result;
      if (query.isNotEmpty) {
        final tags = await _tags([if (forumId != null && forumId.isNotEmpty) forumId, ...?onlyIn]);
        result = await _forum.api.searchPosts(
          query,
          author: author,
          discussionId: topicId,
          tag: tags.firstOrNull,
          offset: offset,
          limit: perpage,
        );
      } else if (author != null) {
        result = await _forum.api.userPosts(author, offset: offset, limit: perpage);
      } else {
        return FCSearchDataResultPost(result: true, resultText: '', totalPostNum: 0, posts: const []);
      }
      return FCSearchDataResultPost(
        result: true,
        resultText: '',
        totalPostNum: _total(result),
        posts: _posts(result.items),
        hasMore: result.hasMore,
      );
    } catch (e) {
      return FCSearchDataResultPost(result: false, resultText: _describe(e), totalPostNum: 0, posts: const []);
    }
  }

  // ---- Helpers ----

  /// The username to search by: [username] as given, or [userId]'s.
  Future<String?> _author(String? username, String? userId) async {
    if (username != null && username.isNotEmpty) return username;
    if (userId == null || userId.isEmpty) return null;
    return (await _forum.api.user(userId)).username;
  }

  /// The tags with [ids]. An id the forum doesn't have fails the search
  /// rather than quietly searching everywhere.
  Future<List<FlarumTag>> _tags(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final byId = {for (final tag in await _forum.tags()) tag.id: tag};
    return [for (final id in ids) byId[id] ?? (throw StateError('This forum has no tag $id'))];
  }

  static bool _titleHas(FlarumDiscussion d, String query) {
    final title = d.title.toLowerCase();
    return query.toLowerCase().split(RegExp(r'\s+')).every(title.contains);
  }

  static List<FCPost> _posts(List<FlarumPost> posts) => [
        for (final post in posts)
          FlarumPostProxy.toPost(post, topicId: post.discussionId ?? '', topicTitle: post.discussionTitle),
      ];

  /// The forum's total when it gives one (2.0); otherwise what's been seen, plus one if there's more.
  static int _total(FlarumPage<Object?> page) =>
      page.total ?? (page.offset ?? 0) + page.items.length + (page.hasMore ? 1 : 0);

  static (int, int) _range(int startNum, int lastNum) {
    final offset = startNum < 0 ? 0 : startNum;
    return (offset, lastNum >= offset ? lastNum - offset + 1 : 20);
  }

  static int _offset(int page, int perpage) => (page < 1 ? 0 : page - 1) * perpage;

  static String _describe(Object e) => switch (e) {
        UnsupportedError(:final message?) => message,
        StateError(:final message) => message,
        _ => describeFlarumError(e),
      };
}
