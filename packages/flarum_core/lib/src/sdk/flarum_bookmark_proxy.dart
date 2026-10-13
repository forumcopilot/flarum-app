import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_bookmark_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_bookmark.dart';
import 'package:forumcopilot_sdk/models/results/fc_bookmark_result.dart';

import 'flarum_forum.dart';
import 'flarum_forum_proxy.dart' show describeFlarumError;
import 'flarum_post_proxy.dart' show plainText;

/// [IFCBookmarkProxy] on fof/bookmarks: a reader's bookmarks are flags on posts (and
/// discussions), not records of their own, so a bookmark's id is its post's.
class FlarumBookmarkProxy implements IFCBookmarkProxy {
  FlarumBookmarkProxy(this.siteContext);

  final SiteContext siteContext;

  FlarumForum get _forum => FlarumForum.of(siteContext);

  static const _perPage = 20;

  @override
  Future<FCAddBookmarkResult> addPostBookmarkAsync(String postId) async {
    try {
      await _forum.api.bookmarkPost(postId, bookmarked: true);
      return FCAddBookmarkResult(result: true, resultText: '', isBookmarked: true, bookmarkId: int.tryParse(postId));
    } catch (e) {
      return FCAddBookmarkResult(result: false, resultText: describeFlarumError(e));
    }
  }

  @override
  Future<FCRemoveBookmarkResult> removePostBookmarkAsync(String postId) async {
    try {
      await _forum.api.bookmarkPost(postId, bookmarked: false);
      return FCRemoveBookmarkResult(result: true, resultText: '', isBookmarked: false);
    } catch (e) {
      return FCRemoveBookmarkResult(result: false, resultText: describeFlarumError(e));
    }
  }

  /// A bookmark's id is its post's.
  @override
  Future<FCRemoveBookmarkResult> removeBookmarkByIdAsync(int bookmarkId) => removePostBookmarkAsync('$bookmarkId');

  /// The reader's bookmarked posts, newest first, [page] counting from 0.
  @override
  Future<FCBookmarkListResult> getBookmarksAsync({int page = 0}) async {
    try {
      final offset = page * _perPage;
      final posts = await _forum.api.bookmarkedPosts(offset: offset, limit: _perPage);
      return FCBookmarkListResult(
        result: true,
        resultText: '',
        total: offset + posts.items.length + (posts.hasMore ? 1 : 0),
        hasMore: posts.hasMore,
        items: [
          for (final post in posts.items)
            FCBookmark(
              id: int.tryParse(post.id) ?? 0,
              bookmarkableType: 'Post',
              bookmarkableId: int.tryParse(post.id),
              topicId: int.tryParse(post.discussionId ?? ''),
              postNumber: post.number,
              title: post.discussionTitle,
              excerpt: plainText(post.contentHtml ?? ''),
              name: post.author?.displayName,
              username: post.author?.username,
              avatarUrl: post.author?.avatarUrl,
              createdAt: post.createdAt,
            ),
        ],
      );
    } catch (e) {
      return FCBookmarkListResult(result: false, resultText: describeFlarumError(e), total: 0, items: const []);
    }
  }
}
