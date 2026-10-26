import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/topic_list_skeleton.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../tags/tags_page.dart';
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
      {super.key,
      required this.site,
      required this.list,
      this.emptyMessage,
      this.onReturn,
      this.header,
      this.excerpts = false,
      this.hiddenTagId,
      this.headerSlivers = const [],
      this.refreshEdgeOffset = 0});

  final SiteContext site;
  final DiscussionListModel list;

  /// What an empty list says, when "No discussions" isn't it.
  final String? emptyMessage;

  /// Called back from a discussion opened here, after its row is read again.
  final VoidCallback? onReturn;

  /// Above the first discussion: Home's welcome message.
  final Widget? header;

  /// Whether sticky discussions show their opening words, as on the web's index and tag pages.
  final bool excerpts;

  /// The tag whose page this is: its rows leave it out, as the Discourse app's category page
  /// leaves out the category.
  final String? hiddenTagId;

  /// Above everything, scrolling with the list: the page's header (Home's masthead, a tag's), which
  /// collapses into its bar, and its chips.
  final List<Widget> headerSlivers;

  /// Where the refresh spinner shows: under the header's pinned bar.
  final double refreshEdgeOffset;

  Future<void> _open(BuildContext context, FlarumDiscussion discussion) async {
    await ThreadPage.open(context, site, discussion.id, near: list.openAt(discussion), title: discussion.title);
    await list.reload(discussion.id);
    onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return RefreshIndicator(
      edgeOffset: refreshEdgeOffset,
      onRefresh: () => _refresh(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          // The list's own scrolling, not a row of chips in the header.
          if (n.depth == 0 && list.items.isNotEmpty && n.metrics.extentAfter < 600) list.loadMore();
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [...headerSlivers, ..._body(context, l10n)],
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    await list.refresh();
    final error = list.error;
    if (error != null && list.items.isNotEmpty && context.mounted) {
      SnackbarHelper.showError(context, describeError(context, error));
    }
  }

  List<Widget> _body(BuildContext context, FlarumLocalizations l10n) {
    if (list.items.isEmpty) {
      if (list.error != null) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView.error(
              message: l10n.discussionsLoadFailed,
              hint: describeError(context, list.error!),
              onRetry: list.refresh,
            ),
          ),
        ];
      }
      if (list.loading) return const [SliverToBoxAdapter(child: TopicListSkeleton(shrinkWrap: true))];
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(icon: Icons.forum_outlined, message: emptyMessage ?? l10n.noDiscussions),
        ),
      ];
    }
    return [
      if (header case final header?) SliverToBoxAdapter(child: header),
      SliverList.separated(
        itemCount: list.items.length + 1,
        // Inset to the text, as Material 3's list dividers are (the avatar and its gap).
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
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
                // Room for the Start a Discussion button over the last row.
                : const SizedBox(height: 88);
          }
          final d = list.items[i];
          final unread = list.unreadIn(d);
          final tile = DiscussionTile(
            key: ValueKey(d.id),
            discussion: d,
            unread: unread,
            read: list.signedIn && unread == 0,
            recipients: list.recipientsOf(d),
            excerpt: excerpts ? list.excerptOf(d) : null,
            onTap: () => _open(context, d),
            onLongPress: () => showDiscussionActions(context, site, list, d),
            onTagTap: (tag) => TagPage.open(context, site, tag),
            hiddenTagId: hiddenTagId,
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
    ];
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

/// A sort's name, as the web's sort menu words it.
String discussionSortLabel(DiscussionSort sort, FlarumLocalizations l10n) => switch (sort) {
      DiscussionSort.latest => l10n.latest,
      DiscussionSort.top => l10n.filterTop,
      DiscussionSort.newest => l10n.viewNewest,
      DiscussionSort.oldest => l10n.sortOldest,
      DiscussionSort.titleAz => l10n.sortTitleAz,
      DiscussionSort.titleZa => l10n.sortTitleZa,
    };
