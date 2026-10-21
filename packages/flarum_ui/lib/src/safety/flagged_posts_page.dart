import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';
import '../widgets/flarum_avatar.dart';

/// Whether the reader moderates flags here (flarum/flags' canViewFlags).
bool canViewFlags(FlarumForum forum) => forum.info?.can('canViewFlags') ?? false;

/// The forum's Flagged Posts, as its moderators' flag list has them: each post once, whose and in
/// which discussion, who flagged it and why, its opening words; a tap opens it, Dismiss Flag clears
/// its flags. Opening the list clears the moderator's new-flag count, as on the web.
class FlaggedPostsPage extends StatefulWidget {
  const FlaggedPostsPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => FlaggedPostsPage(site: site)));

  @override
  State<FlaggedPostsPage> createState() => _FlaggedPostsPageState();
}

/// A flagged post and every flag on it, newest first.
typedef _Flagged = ({FlarumPost post, List<FlarumFlag> flags});

class _FlaggedPostsPageState extends State<FlaggedPostsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _flags = <FlarumFlag>[];
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final page = await _forum.api.flags(offset: reset ? 0 : _flags.length);
      if (!mounted) return;
      setState(() {
        if (reset) _flags.clear();
        _flags.addAll(page.items);
        _hasMore = page.hasMore;
      });
      // The count of new flags went with the listing.
      if (reset) _forum.refresh().ignore();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_Flagged> get _posts {
    final byPost = <String, _Flagged>{};
    for (final flag in _flags) {
      final post = flag.post;
      if (post == null) continue;
      (byPost[post.id] ??= (post: post, flags: [])).flags.add(flag);
    }
    return byPost.values.toList();
  }

  Future<void> _dismiss(FlarumPost post) async {
    try {
      await _forum.api.dismissFlags(post.id);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
      return;
    }
    if (mounted) setState(() => _flags.removeWhere((f) => f.post?.id == post.id));
  }

  Future<void> _open(FlarumPost post) async {
    final discussion = post.discussionId;
    if (discussion == null) return;
    await ThreadPage.open(context, widget.site, discussion, near: post.number, title: post.discussionTitle);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.flaggedPosts)),
      body: RefreshIndicator(onRefresh: () => _load(reset: true), child: _body(l10n)),
    );
  }

  Widget _body(FlarumLocalizations l10n) {
    final posts = _posts;
    if (posts.isEmpty) {
      if (_error != null) {
        return EmptyStateView.error(message: describeError(context, _error!), onRetry: () => _load(reset: true));
      }
      if (_loading) return const Center(child: CircularProgressIndicator());
      return EmptyStateView.scrollable(icon: Icons.flag_outlined, message: l10n.noFlags);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400 && _hasMore && _error == null) _load(reset: false);
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == posts.length) {
            return Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: Center(
                child: _error != null && !_loading
                    ? TextButton.icon(
                        onPressed: () => _load(reset: false), icon: const Icon(Icons.refresh), label: Text(l10n.retry))
                    : const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            );
          }
          final (:post, :flags) = posts[i];
          return _FlaggedPostTile(post: post, flags: flags, onTap: () => _open(post), onDismiss: () => _dismiss(post));
        },
      ),
    );
  }
}

class _FlaggedPostTile extends StatelessWidget {
  const _FlaggedPostTile({required this.post, required this.flags, required this.onTap, required this.onDismiss});

  final FlarumPost post;
  final List<FlarumFlag> flags;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  /// A flag's line, as the web frames a flagged post: who flagged it, and as what.
  static String line(FlarumFlag flag, FlarumLocalizations l10n) {
    final who = flag.user?.displayName ?? l10n.someone;
    final reason = switch (flag.reason) {
      'off_topic' => l10n.flagReasonOffTopic,
      'inappropriate' => l10n.flagReasonInappropriate,
      'spam' => l10n.flagReasonSpam,
      _ => null,
    };
    return reason == null ? l10n.flaggedBy(who) : l10n.flaggedByWithReason(who, reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final created = flags.first.createdAt;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingM, DesignTokens.spacingS, DesignTokens.spacingXS),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlarumAvatar(user: post.author),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.flaggedPostItem(post.author?.displayName ?? l10n.someone, post.discussionTitle ?? l10n.aDiscussion),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: DesignTokens.spacingXS),
                  Text(truncateText(plainText(post.contentHtml ?? ''), 175), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: DesignTokens.spacingXS),
                  for (final flag in flags) ...[
                    Row(
                      children: [
                        Icon(Icons.flag, size: 14, color: theme.colorScheme.error),
                        const SizedBox(width: DesignTokens.spacingXS),
                        Flexible(child: Text(line(flag, l10n), style: muted)),
                      ],
                    ),
                    if (flag.reasonDetail case final detail?)
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Text(detail, style: muted?.copyWith(fontStyle: FontStyle.italic)),
                      ),
                  ],
                  Row(
                    children: [
                      if (created != null) Text(formatTimeAgo(created.toLocal(), context), style: muted),
                      const Spacer(),
                      TextButton(onPressed: onDismiss, child: Text(l10n.dismissFlag)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
