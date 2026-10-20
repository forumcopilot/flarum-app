import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/post_content_callbacks.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../media/image_viewer_page.dart';
import '../navigation/forum_links.dart';
import '../profile/user_page.dart';
import '../render/flarum_content.dart';
import '../render/flarum_html.dart';
import '../render/links.dart';
import '../tags/tags_page.dart';
import '../thread/thread_page.dart';
import '../widgets/flarum_avatar.dart';

/// One conversation in flarum/messages (2.0): its messages, the newest at the bottom, and a field
/// to answer in. Opened on a dialog, or with [to] for someone the reader writes to: the
/// conversation they already have, found in their list, or else an empty one, which the first
/// message starts.
class DialogPage extends StatefulWidget {
  const DialogPage({super.key, required this.site, this.dialogId, this.to});

  final SiteContext site;
  final String? dialogId;
  final FlarumUser? to;

  static Future<void> open(BuildContext context, SiteContext site, {String? dialogId, FlarumUser? to}) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => DialogPage(site: site, dialogId: dialogId, to: to)));

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late String? _dialogId = widget.dialogId;
  FlarumDialog? _dialog;

  /// Looking for the conversation the reader already has with [DialogPage.to].
  late bool _finding = _dialogId == null && widget.to != null;

  /// The newest first, as the list shows them from the bottom up.
  final _messages = <FlarumDialogMessage>[];
  bool _loading = false;
  bool _hasMore = false;
  Object? _error;
  bool _sending = false;
  final _text = TextEditingController();

  String? get _readerId => _forum.info?.actor?.id;

  @override
  void initState() {
    super.initState();
    if (_finding) {
      _find();
    } else if (_dialogId != null) {
      _load(reset: true);
    }
  }

  Future<void> _find() async {
    try {
      final dialog = await _forum.api.dialogWith(widget.to!.id);
      if (!mounted) return;
      setState(() {
        _finding = false;
        _dialog = dialog;
        _dialogId = dialog?.id;
      });
      if (dialog != null) await _load(reset: true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _finding = false;
          _error = e;
        });
      }
    }
  }

  void _retry() {
    if (_dialogId != null) {
      _load(reset: true);
    } else if (widget.to != null) {
      setState(() {
        _finding = true;
        _error = null;
      });
      _find();
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    final id = _dialogId;
    if (id == null || _loading) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final (dialog, page) = await (
        reset ? _forum.api.dialog(id) : Future.value(_dialog),
        _forum.api.dialogMessages(id, offset: reset ? 0 : _messages.length),
      ).wait;
      if (!mounted) return;
      setState(() {
        _dialog = dialog;
        _error = null;
        if (reset) _messages.clear();
        _messages.addAll(page.items);
        _hasMore = page.hasMore;
      });
      if (reset && page.items.isNotEmpty) _markRead();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Links in a message open in the app as they do in a post: this forum's discussions, people
  /// and tags here, everything else outside. Pictures open in the viewer.
  PostContentCallbacks _callbacksFor(FlarumDialogMessage message) => PostContentCallbacks(
        onUrlTap: _openLink,
        onMentionTap: (slug) => UserPage.open(context, widget.site, slug),
        onImageTap: (url, context, _) => ImageViewerPage.open(
          context,
          url,
          FlarumHtml.parse(message.contentHtml ?? '', forumBaseUrl: widget.site.site.url).imageUrls,
        ),
      );

  Future<void> _openLink(String url) async {
    switch (ForumLink.parse(url, widget.site.site.url)) {
      case DiscussionLink(:final id, :final number):
        await ThreadPage.open(context, widget.site, id, near: number);
      case UserLink(:final slug):
        await UserPage.open(context, widget.site, slug);
      case TagLink(:final slug):
        if (!await TagPage.openBySlug(context, widget.site, slug)) await openExternally(url);
      default:
        await openExternally(url);
    }
  }

  void _markRead() {
    final id = _dialogId;
    if (id == null || _messages.isEmpty) return;
    _forum.api.markDialogRead(id, _messages.first.id).ignore();
  }

  Future<void> _send() async {
    final content = _text.text.trim();
    final to = widget.to;
    if (content.isEmpty || _sending || _finding || (_dialogId == null && to == null)) return;
    setState(() => _sending = true);
    try {
      final sent = await _forum.api.sendMessage(content, dialogId: _dialogId, userIds: [if (_dialogId == null) to!.id]);
      if (!mounted) return;
      _text.clear();
      final first = _dialogId == null;
      _dialogId ??= sent.dialogId;
      if (first) {
        // The forum may have found an earlier conversation with them: show all of it.
        setState(() => _sending = false);
        await _load(reset: true);
        return;
      }
      setState(() {
        _sending = false;
        // The forum's answer names the author without including them: it's the reader.
        _messages.insert(
          0,
          FlarumDialogMessage(
            id: sent.id,
            number: sent.number,
            contentHtml: sent.contentHtml,
            createdAt: sent.createdAt,
            author: _forum.info?.actor,
            dialogId: sent.dialogId,
          ),
        );
      });
      _markRead();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final others = _dialog?.others(_readerId) ?? [if (widget.to case final to?) to];
    return Scaffold(
      appBar: AppBar(
        title: Text(others.isEmpty ? l10n.messages : others.map((user) => user.displayName).join(', ')),
      ),
      body: Column(
        children: [
          Expanded(child: _body(l10n)),
          _inputBar(l10n),
        ],
      ),
    );
  }

  Widget _body(FlarumLocalizations l10n) {
    if (_messages.isEmpty) {
      if (_error != null) {
        return EmptyStateView.error(
          message: l10n.messagesLoadFailed,
          hint: describeError(context, _error!),
          onRetry: _retry,
        );
      }
      if (_loading || _finding) return const Center(child: CircularProgressIndicator());
      return const SizedBox.shrink();
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // The list is upside down: older messages are past its end.
        if (n.metrics.extentAfter < 400 && _hasMore && _error == null) _load(reset: false);
        return false;
      },
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
        itemCount: _messages.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _messages.length) {
            // Older messages: loading, or failed, with Retry rather than a spinner that never stops.
            return Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: Center(
                child: _error != null && !_loading
                    ? TextButton.icon(
                        onPressed: () => _load(reset: false),
                        icon: const Icon(Icons.refresh),
                        label: Text(flarumL10n(context).retry),
                      )
                    : const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            );
          }
          final message = _messages[i];
          return _MessageTile(
            site: widget.site,
            message: message,
            mine: message.author?.id != null && message.author?.id == _readerId,
            callbacks: _callbacksFor(message),
          );
        },
      ),
    );
  }

  Widget _inputBar(FlarumLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      elevation: 2,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingS, DesignTokens.spacingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  // Read-only while sending, not disabled: a disabled field loses its focus,
                  // and the keyboard closed after every message.
                  readOnly: _sending,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: l10n.messageHint, border: InputBorder.none),
                ),
              ),
              IconButton(
                onPressed: _sending || _finding ? null : _send,
                tooltip: l10n.send,
                icon: _sending
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.send, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A message: the reader's own on the right, the others' on the left with who wrote it.
class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.site, required this.message, required this.mine, required this.callbacks});

  final SiteContext site;
  final FlarumDialogMessage message;
  final bool mine;
  final PostContentCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final created = message.createdAt;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingM, vertical: DesignTokens.spacingS),
      decoration: BoxDecoration(
        color: mine ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlarumContent(
            siteContext: site,
            content: FlarumHtml.parse(message.contentHtml ?? '', forumBaseUrl: site.site.url).html,
            callbacks: callbacks,
          ),
          if (created != null)
            Text(formatTimeAgo(created.toLocal(), context),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingXS),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            FlarumAvatar(user: message.author, radius: 14),
            const SizedBox(width: DesignTokens.spacingS),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}
