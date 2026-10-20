import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/topic_list_skeleton.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';
import 'discussion_list_model.dart';
import 'discussion_tile.dart';

/// A list of discussions: pull to refresh, more as the reader nears the end,
/// and a discussion opens at the first post the reader hasn't read. Its row
/// is refreshed on the way back. A refresh that fails keeps the list shown
/// and says why.
class DiscussionListView extends StatelessWidget {
  const DiscussionListView({super.key, required this.site, required this.list, this.emptyMessage, this.onReturn});

  final SiteContext site;
  final DiscussionListModel list;

  /// What an empty list says, when "No discussions" isn't it.
  final String? emptyMessage;

  /// Called back from a discussion opened here, after its row is read again.
  final VoidCallback? onReturn;

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
        itemCount: list.items.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
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
          return DiscussionTile(
            key: ValueKey(d.id),
            discussion: d,
            unread: list.unreadIn(d),
            recipients: list.recipientsOf(d),
            onTap: () => _open(context, d),
          );
        },
      ),
    );
  }
}
