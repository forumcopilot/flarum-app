import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../app/forum_drawer.dart';
import '../messages/dialog_page.dart';
import '../thread/thread_page.dart';
import 'notification_settings_page.dart';
import 'notifications_model.dart';
import '../widgets/flarum_avatar.dart';
import '../account/log_in_first.dart';

/// The reader's notifications: who did what, where, and when, unread ones
/// highlighted. A tap marks one read and opens the post it's about.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.site, this.onRead, this.onUnreadShown, this.visit = 0});

  final SiteContext site;

  /// The forum marked one or all read: the unread count (the tab's badge) changed.
  final VoidCallback? onRead;

  /// The list's unread rows ([NotificationsModel.unreadShown]) whenever they change; [settled] once
  /// the forum agrees (the list loaded, or a read went through), for the badge to match it.
  final void Function(int? unread, {required bool settled})? onUnreadShown;

  /// Bumped by the host each time the reader comes back to the list: it loads again, as the web's
  /// list does each time it opens, so what came in meanwhile is there.
  final int visit;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final NotificationsModel _model = NotificationsModel(_forum)..addListener(_changed);

  @override
  void initState() {
    super.initState();
    if (_forum.isSignedIn) _refresh();
  }

  @override
  void didUpdateWidget(NotificationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // After this build: the reload notifies the page, which can't rebuild while it's building.
    if (widget.visit != oldWidget.visit && _forum.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refresh();
      });
    }
  }

  Future<void> _refresh() async {
    await _model.refresh();
    _settled();
    // Failed over the list it had: it stays, and the reader learns why it didn't change.
    final error = _model.error;
    if (error != null && _model.items.isNotEmpty && mounted) SnackbarHelper.showError(context, describeError(context, error));
  }

  int? _reported;

  void _settled() => widget.onUnreadShown?.call(_model.unreadShown, settled: true);

  @override
  void dispose() {
    _model
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    final unread = _model.unreadShown;
    if (unread != _reported) {
      _reported = unread;
      widget.onUnreadShown?.call(unread, settled: false);
    }
  }

  Future<void> _open(FlarumNotification n) async {
    _model.markRead(n).then((marked) {
      if (!marked) return;
      widget.onRead?.call();
      _settled();
    });
    // A message (flarum/messages) opens its conversation.
    if (n.dialogId case final dialog?) return DialogPage.open(context, widget.site, dialogId: dialog);
    final discussion = n.discussionId;
    if (discussion == null) return;
    await ThreadPage.open(context, widget.site, discussion, near: n.openAt, title: n.discussionTitle);
  }

  Future<void> _markAllRead() async {
    final l10n = flarumL10n(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _model.markAllRead();
    if (ok) {
      widget.onRead?.call();
      _settled();
    }
    messenger.showSnackBar(
        SnackBar(content: Text(ok ? l10n.allNotificationsMarkedAsRead : l10n.failedToMarkNotificationsRead)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final signedIn = _forum.isSignedIn;
    return Scaffold(
      appBar: AppBar(
        leading: forumDrawerButton(context),
        title: Text(l10n.notifications),
        actions: [
          if (signedIn && _model.items.any((n) => !n.isRead))
            IconButton(icon: const Icon(Icons.done_all), tooltip: l10n.markAllRead, onPressed: _markAllRead),
          // Which notifications come, as the forum's settings page sets them.
          if (signedIn)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.settings,
              onPressed: () => NotificationSettingsPage.open(context, widget.site),
            ),
        ],
      ),
      body: !signedIn
          ? EmptyStateView(
              icon: Icons.notifications_none,
              message: l10n.notificationsSignIn,
              actions: [FilledButton(onPressed: () => logInFirst(context, widget.site), child: Text(l10n.signIn))],
            )
          : RefreshIndicator(onRefresh: _refresh, child: _body(l10n)),
    );
  }

  Widget _body(FlarumLocalizations l10n) {
    if (_model.items.isEmpty) {
      if (_model.error != null) {
        return EmptyStateView.error(
          message: l10n.notificationsLoadFailed,
          hint: describeError(context, _model.error!),
          onRetry: _refresh,
        );
      }
      if (_model.loading) return const Center(child: CircularProgressIndicator());
      return EmptyStateView.scrollable(icon: Icons.notifications_none, message: l10n.noNotificationsYet);
    }
    // Grouped under each discussion's title, as the web groups them (forum-wide ones under the
    // forum's name), in the order the newest of each came in.
    final groups = <String, List<FlarumNotification>>{};
    for (final n in _model.items) {
      groups.putIfAbsent(n.discussionId ?? '', () => []).add(n);
    }
    final rows = <Object>[
      for (final group in groups.entries) ...[
        group.key.isEmpty ? (_forum.info?.title ?? widget.site.site.name) : (group.value.first.discussionTitle ?? l10n.aDiscussion),
        ...group.value,
      ],
    ];
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) _model.loadMore();
        return false;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: rows.length + (_model.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == rows.length) {
            // The next page: loading, or failed, with Retry rather than a spinner that never stops.
            return Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: Center(
                child: _model.error != null && !_model.loading
                    ? TextButton.icon(onPressed: _model.retryMore, icon: const Icon(Icons.refresh), label: Text(l10n.retry))
                    : const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            );
          }
          return switch (rows[i]) {
            final FlarumNotification n => NotificationTile(notification: n, grouped: true, onTap: () => _open(n)),
            final title => _GroupHeader(title: '$title'),
          };
        },
      ),
    );
  }
}

/// A discussion's title over its notifications (or the forum's name over its own), as the web
/// heads each group.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXS),
        child: Text(title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// One notification, as the web lists it: who, their avatar marked with the kind (a like's
/// thumbs-up, a mention's @), the line, a line of the post it's about, and when; unread ones on a
/// tinted row. [grouped] under its discussion's title, the line leaves the title out.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap, this.grouped = false});

  final FlarumNotification notification;
  final VoidCallback? onTap;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = flarumL10n(context);
    final n = notification;
    final created = n.createdAt;
    final excerpt = switch (n.postHtml) {
      final html? => plainText(html).replaceAll(RegExp(r'\s+'), ' ').trim(),
      null => null,
    };
    final muted = theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);
    return Material(
      color: n.isRead ? Colors.transparent : colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: ListTile(
        onTap: onTap,
        leading: switch (n.fromUser) {
          final user? => Stack(
              clipBehavior: Clip.none,
              children: [
                FlarumAvatar(user: user),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: ExcludeSemantics(
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: Icon(iconFor(n), size: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          // From the forum itself (a suspension, an export): its kind, as the web shows it.
          null => CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(iconFor(n), color: colorScheme.onSecondaryContainer),
            ),
        },
        title: Text(
          grouped ? line(n, l10n) : message(n, l10n),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (excerpt != null && excerpt.isNotEmpty) Text(excerpt, maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
            if (created != null) Text(formatTimeAgo(created.toLocal(), context), style: muted),
          ],
        ),
      ),
    );
  }

  /// [n]'s kind, in the icons the web marks notifications with (Font Awesome there).
  static IconData iconFor(FlarumNotification n) => switch (n.contentType) {
        'postLiked' => Icons.thumb_up,
        'postReacted' => Icons.emoji_emotions_outlined,
        'postMentioned' => Icons.reply,
        'userMentioned' || 'groupMentioned' => Icons.alternate_email,
        'newPost' || 'newPostInTag' || 'newDiscussionInTag' || 'newDiscussionTag' => Icons.star,
        'discussionRenamed' => Icons.edit,
        'discussionLocked' => Icons.lock,
        'byobuPrivateDiscussionCreated' ||
        'byobuPrivateDiscussionReplied' ||
        'byobuPrivateDiscussionAdded' ||
        'byobuRecipientRemoved' ||
        'byobuMadePublic' =>
          Icons.map_outlined,
        'awardedBestAnswer' || 'bestAnswerInDiscussion' || 'selectBestAnswer' => Icons.check_circle_outline,
        'messageReceived' => Icons.chat_bubble_outline,
        'userSuspended' => Icons.block,
        'userUnsuspended' => Icons.check_circle_outline,
        'gdprExportAvailable' => Icons.download_outlined,
        _ => Icons.notifications_outlined,
      };

  /// [n]'s line under its discussion's title, in the web's own words ("alice liked your post").
  static String line(FlarumNotification n, FlarumLocalizations l10n) {
    final user = n.fromUser?.displayName ?? l10n.someone;
    return switch (n.contentType) {
      'newPost' || 'newPostInTag' => l10n.notifLineNewPost(user),
      'postLiked' => l10n.notifLinePostLiked(user),
      'postReacted' => l10n.notifLinePostReacted(user),
      'postMentioned' => l10n.notifLinePostMentioned(user),
      'userMentioned' => l10n.notifLineUserMentioned(user),
      'groupMentioned' => l10n.notifLineGroupMentioned(user),
      'discussionRenamed' => l10n.notifLineRenamed(user),
      'discussionLocked' => l10n.notifLineLocked(user),
      'newDiscussionInTag' => l10n.notifLineNewDiscussion(user),
      'newDiscussionTag' => l10n.notifLineMovedToTag(user),
      'byobuPrivateDiscussionCreated' => l10n.notifLinePrivateCreated(user),
      'byobuPrivateDiscussionReplied' => l10n.notifLinePrivateReplied(user),
      'byobuPrivateDiscussionAdded' => l10n.notifLinePrivateAdded(user),
      'byobuRecipientRemoved' => l10n.notifLinePrivateRemoved(user),
      'byobuMadePublic' => l10n.notifLineMadePublic(user),
      'awardedBestAnswer' => l10n.notifLineBestAnswerAwarded(user),
      'bestAnswerInDiscussion' => l10n.notifLineBestAnswerChosen(user),
      'selectBestAnswer' => l10n.notifLineBestAnswerPending,
      _ => message(n, l10n),
    };
  }

  /// [n]'s line, worded as the web words it.
  static String message(FlarumNotification n, FlarumLocalizations l10n) {
    final user = n.fromUser?.displayName ?? l10n.someone;
    final title = n.discussionTitle ?? l10n.aDiscussion;
    return switch (n.contentType) {
      'newPost' || 'newPostInTag' => l10n.notifNewPost(user, title),
      'postLiked' => l10n.notifPostLiked(user, title),
      'postReacted' => l10n.notifPostReacted(user, title),
      'postMentioned' => l10n.notifPostMentioned(user, title),
      'userMentioned' => l10n.notifUserMentioned(user, title),
      'groupMentioned' => l10n.notifGroupMentioned(user, title),
      'discussionRenamed' => l10n.notifRenamed(user, title),
      'discussionLocked' => l10n.notifLocked(user, title),
      'newDiscussionInTag' => l10n.notifNewDiscussion(user, title),
      'newDiscussionTag' => l10n.notifMovedToTag(user, title),
      'byobuPrivateDiscussionCreated' => l10n.notifPrivateCreated(user, title),
      'byobuPrivateDiscussionReplied' => l10n.notifPrivateReplied(user, title),
      'byobuPrivateDiscussionAdded' => l10n.notifPrivateAdded(user, title),
      'byobuRecipientRemoved' => l10n.notifPrivateRemoved(user, title),
      'byobuMadePublic' => l10n.notifMadePublic(user, title),
      'awardedBestAnswer' => l10n.notifBestAnswerAwarded(user, title),
      'bestAnswerInDiscussion' => l10n.notifBestAnswerChosen(user, title),
      'selectBestAnswer' => l10n.notifBestAnswerPending(title),
      'messageReceived' => l10n.notifMessage(user),
      'userSuspended' => l10n.notifSuspended,
      'userUnsuspended' => l10n.notifUnsuspended,
      'gdprExportAvailable' => l10n.notifExport,
      _ => l10n.notifOther,
    };
  }
}
