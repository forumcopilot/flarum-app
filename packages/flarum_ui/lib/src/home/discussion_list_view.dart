import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/topic_list_skeleton.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';
import 'discussion_actions.dart';
import 'discussion_list_model.dart';
import 'discussion_tile.dart';

/// A list of discussions: pull to refresh, more as the reader nears the end,
/// and a discussion opens at the first post the reader hasn't read. Its row
/// is refreshed on the way back. A refresh that fails keeps the list shown
/// and says why.
class DiscussionListView extends StatelessWidget {
  const DiscussionListView(
      {super.key, required this.site, required this.list, this.emptyMessage, this.onReturn, this.header, this.excerpts = false});

  final SiteContext site;
  final DiscussionListModel list;

  /// What an empty list says, when "No discussions" isn't it.
  final String? emptyMessage;

  /// Called back from a discussion opened here, after its row is read again.
  final VoidCallback? onReturn;

  /// Above the first discussion, scrolling with the list: Home's welcome message.
  final Widget? header;

  /// Whether sticky discussions show their opening words, as on the web's index and tag pages.
  final bool excerpts;

  Future<void> _open(BuildContext context, FlarumDiscussion discussion) async {
    await ThreadPage.open(context, site, discussion.id, near: list.openAt(discussion), title: discussion.title);
    await list.reload(discussion.id);
    onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return RefreshIndicator(onRefresh: () => _refresh(context), child: _body(context, l10n));
  }

  Future<void> _refresh(BuildContext context) async {
    await list.refresh();
    final error = list.error;
    if (error != null && list.items.isNotEmpty && context.mounted) {
      SnackbarHelper.showError(context, describeError(context, error));
    }
  }

  Widget _body(BuildContext context, FlarumLocalizations l10n) {
    if (list.items.isEmpty) {
      if (list.error != null) {
        return EmptyStateView.error(
          message: l10n.discussionsLoadFailed,
          hint: describeError(context, list.error!),
          onRetry: list.refresh,
        );
      }
      if (list.loading) return const TopicListSkeleton();
      return EmptyStateView.scrollable(icon: Icons.forum_outlined, message: emptyMessage ?? l10n.noDiscussions);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 600) list.loadMore();
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: (header == null ? 0 : 1) + list.items.length + 1,
        separatorBuilder: (_, i) => header != null && i == 0 ? const SizedBox.shrink() : const Divider(height: 1),
        itemBuilder: (context, row) {
          if (header case final header? when row == 0) return header;
          final i = header == null ? row : row - 1;
          if (i == list.items.length) {
            if (list.error != null) {
              return TextButton.icon(onPressed: list.retryMore, icon: const Icon(Icons.refresh), label: Text(l10n.retry));
            }
            return list.hasMore
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                : const SizedBox(height: 48);
          }
          final d = list.items[i];
          final unread = list.unreadIn(d);
          final tile = DiscussionTile(
            key: ValueKey(d.id),
            discussion: d,
            unread: unread,
            recipients: list.recipientsOf(d),
            excerpt: excerpts ? list.excerptOf(d) : null,
            onTap: () => _open(context, d),
            onLongPress: () => showDiscussionActions(context, site, list, d),
          );
          if (!list.signedIn || unread == 0) return tile;
          // Swiped towards the end, an unread discussion is marked read; the row stays.
          return Dismissible(
            key: ValueKey('read-${d.id}'),
            direction: DismissDirection.startToEnd,
            background: _MarkReadBackground(label: l10n.markAsRead),
            confirmDismiss: (_) async {
              markDiscussionRead(context, list, d);
              return false;
            },
            child: tile,
          );
        },
      ),
    );
  }
}

/// Behind a row swiped to mark it read: what the swipe does.
class _MarkReadBackground extends StatelessWidget {
  const _MarkReadBackground({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Icon(Icons.done, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
