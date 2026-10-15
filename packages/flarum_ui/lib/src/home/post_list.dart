import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';

/// Posts from across the forum, a page at a time, from [load]: a user's, the reader's bookmarks.
class PostListModel extends ChangeNotifier {
  PostListModel(this.load);

  /// A page of posts from [offset].
  final Future<FlarumPage<FlarumPost>> Function(int offset) load;

  final List<FlarumPost> items = [];
  bool hasMore = true;
  bool loading = false;
  Object? error;
  bool _disposed = false;

  Future<void> refresh() => _load(reset: true);

  Future<void> loadMore() async {
    if (loading || !hasMore || error != null) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    loading = true;
    if (reset) error = null;
    _notify();
    try {
      final page = await load(reset ? 0 : items.length);
      if (reset) items.clear();
      items.addAll(page.items);
      hasMore = page.hasMore;
      error = null;
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// [model]'s posts: each its discussion's title over its words, opening the thread at it.
class PostList extends StatelessWidget {
  const PostList(
      {super.key, required this.site, required this.model, required this.emptyMessage, required this.failedMessage, this.onReturn});

  final SiteContext site;
  final PostListModel model;
  final String emptyMessage;
  final String failedMessage;

  /// Called back from a thread opened here, where what the reader did there can change the list
  /// (a post's bookmark taken off).
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    if (model.items.isEmpty) {
      if (model.error != null) {
        return EmptyStateView.error(message: failedMessage, hint: describeError(context, model.error!), onRetry: model.refresh);
      }
      if (model.loading) return const Center(child: CircularProgressIndicator());
      return EmptyStateView(icon: Icons.chat_bubble_outline, message: emptyMessage);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) model.loadMore();
        return false;
      },
      child: ListView.separated(
        itemCount: model.items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final post = model.items[i];
          final created = post.createdAt;
          final discussion = post.discussionId;
          return ListTile(
            title: Text(post.discussionTitle ?? l10n.aDiscussion, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(plainText(post.contentHtml ?? ''), maxLines: 3, overflow: TextOverflow.ellipsis),
            trailing: created == null
                ? null
                : Text(formatTimeAgo(created.toLocal(), context),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            onTap: discussion == null
                ? null
                : () async {
                    await ThreadPage.open(context, site, discussion, near: post.number, title: post.discussionTitle);
                    onReturn?.call();
                  },
          );
        },
      ),
    );
  }
}
