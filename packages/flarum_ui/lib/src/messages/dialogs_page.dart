import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/unread_badge.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../app/forum_drawer.dart';
import '../compose/mention_picker_page.dart';
import '../widgets/flarum_avatar.dart';
import 'dialog_page.dart';

/// The reader's direct messages (flarum/messages, 2.0): a conversation each, the latest first,
/// and New message.
class DialogsPage extends StatefulWidget {
  const DialogsPage({super.key, required this.site, this.switcher});

  final SiteContext site;

  /// Under the title on the Messages tab: chips for this list and the private discussions.
  final PreferredSizeWidget? switcher;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DialogsPage(site: site)));

  @override
  State<DialogsPage> createState() => _DialogsPageState();
}

class _DialogsPageState extends State<DialogsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _dialogs = <FlarumDialog>[];
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await _load(reset: true);
    // Failed over the list it had: it stays, and the reader learns why it didn't change.
    final error = _error;
    if (error != null && _dialogs.isNotEmpty && mounted) SnackbarHelper.showError(context, describeError(context, error));
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final page = await _forum.api.dialogs(offset: reset ? 0 : _dialogs.length);
      if (!mounted) return;
      setState(() {
        if (reset) _dialogs.clear();
        _dialogs.addAll(page.items);
        _hasMore = page.hasMore;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open({FlarumDialog? dialog, FlarumUser? to}) async {
    await DialogPage.open(context, widget.site, dialogId: dialog?.id, to: to);
    // Read now, and maybe a new one.
    _refresh();
    _forum.refresh().ignore();
  }

  /// The messages page's Mark all as read: every conversation, at once.
  Future<void> _markAllRead() async {
    try {
      await _forum.api.markAllDialogsRead();
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
      return;
    }
    await _refresh();
    // The Account tab's count.
    _forum.refresh().ignore();
  }

  Future<void> _newMessage() async {
    final user = await MentionPickerPage.open(context, widget.site);
    if (user != null && mounted && user.id != _forum.info?.actor?.id) await _open(to: user);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      appBar: AppBar(
        leading: forumDrawerButton(context),
        title: Text(l10n.messages),
        bottom: widget.switcher,
        actions: [
          if (_dialogs.any((d) => d.unreadCount > 0))
            IconButton(icon: const Icon(Icons.done_all), tooltip: l10n.markAllMessagesRead, onPressed: _markAllRead),
        ],
      ),
      body: RefreshIndicator(onRefresh: _refresh, child: _body(l10n)),
      floatingActionButton: canSendMessages(_forum)
          ? FloatingActionButton.extended(
              onPressed: _newMessage,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.newMessage),
            )
          : null,
    );
  }

  Widget _body(FlarumLocalizations l10n) {
    if (_dialogs.isEmpty) {
      if (_error != null) {
        return EmptyStateView.error(message: l10n.messagesLoadFailed, hint: describeError(context, _error!), onRetry: _refresh);
      }
      if (_loading) return const Center(child: CircularProgressIndicator());
      return EmptyStateView.scrollable(icon: Icons.chat_bubble_outline, message: l10n.noMessages);
    }
    final readerId = _forum.info?.actor?.id;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400 && _hasMore && _error == null) _load(reset: false);
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _dialogs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) => _DialogTile(
          dialog: _dialogs[i],
          readerId: readerId,
          onTap: () => _open(dialog: _dialogs[i]),
        ),
      ),
    );
  }
}

class _DialogTile extends StatelessWidget {
  const _DialogTile({required this.dialog, required this.readerId, required this.onTap});

  final FlarumDialog dialog;
  final String? readerId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final others = dialog.others(readerId);
    final name = others.isEmpty ? dialog.title ?? '' : others.map((user) => user.displayName).join(', ');
    final unread = dialog.unreadCount > 0;
    final when = dialog.lastMessageAt;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingXS),
      leading: FlarumAvatar(user: others.firstOrNull),
      title: Text(name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: unread ? const TextStyle(fontWeight: FontWeight.w600) : null),
      subtitle: Text(plainText(dialog.lastMessage?.contentHtml ?? ''), maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (when != null)
            Text(formatTimeAgo(when.toLocal(), context),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          if (unread) ...[
            const SizedBox(height: DesignTokens.spacingXS),
            UnreadBadge(count: dialog.unreadCount),
          ],
        ],
      ),
    );
  }
}

/// Whether the reader may write direct messages (flarum/messages' `dialog.sendMessage`).
bool canSendMessages(FlarumForum forum) =>
    forum.isSignedIn && forum.extensions.messages && (forum.info?.actorAttributes.boolean('canSendAnyMessage') ?? false);
