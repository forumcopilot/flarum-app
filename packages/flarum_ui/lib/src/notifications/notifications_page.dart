import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';
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
        title: Text(l10n.notifications),
        actions: [
          if (signedIn && _model.items.any((n) => !n.isRead))
            IconButton(icon: const Icon(Icons.done_all), tooltip: l10n.markAllRead, onPressed: _markAllRead),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) _model.loadMore();
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _model.items.length + (_model.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == _model.items.length) {
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
          final n = _model.items[i];
          return NotificationTile(notification: n, onTap: () => _open(n));
        },
      ),
    );
  }
}

/// One notification: the person, the line, when; unread ones on a tinted row.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});

  final FlarumNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final n = notification;
    final created = n.createdAt;
    return Material(
      color: n.isRead ? Colors.transparent : colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: ListTile(
        onTap: onTap,
        leading: switch (n.fromUser) {
          final user? => FlarumAvatar(user: user),
          // From the forum itself (a suspension, an export): its kind, as the web shows it.
          null => CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(iconFor(n), color: colorScheme.onSecondaryContainer),
            ),
        },
        title: Text(
          message(n, flarumL10n(context)),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600),
        ),
        subtitle: created == null ? null : Text(formatTimeAgo(created.toLocal(), context)),
      ),
    );
  }

  /// The icon for [n] where nobody sent it.
  static IconData iconFor(FlarumNotification n) => switch (n.contentType) {
        'userSuspended' => Icons.block,
        'userUnsuspended' => Icons.check_circle_outline,
        'gdprExportAvailable' => Icons.download_outlined,
        'selectBestAnswer' => Icons.check_circle_outline,
        _ => Icons.notifications_outlined,
      };

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
