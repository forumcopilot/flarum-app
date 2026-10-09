import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/post_content_callbacks.dart';
import 'package:forum_kit/views/widgets/user_avatar.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/flarum_content.dart';
import '../render/flarum_html.dart';

/// One post in a thread: a comment with its author, time and body, or an
/// event (a rename, lock, sticky, retag…) as a one-line notice.
class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.site, required this.post, this.callbacks, this.onAuthorTap});

  final SiteContext site;
  final FlarumPost post;
  final PostContentCallbacks? callbacks;

  /// The author's avatar or name was tapped.
  final void Function(FlarumUser author)? onAuthorTap;

  @override
  Widget build(BuildContext context) =>
      post.isComment ? _comment(context) : EventPostNotice(post: post);

  Widget _comment(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = flarumL10n(context);
    final author = post.author;
    final name = author?.displayName ?? l10n.someone;
    final created = post.createdAt;
    final meta = [
      if (created != null) formatTimeAgo(created.toLocal(), context),
      if (post.editedAt != null) l10n.edited,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                button: author != null && onAuthorTap != null,
                label: l10n.viewProfileOfUser(name),
                excludeSemantics: true,
                child: UserAvatar(
                  username: author?.username ?? '',
                  iconUrl: author?.avatarUrl,
                  radius: 20,
                  onTap: author == null || onAuthorTap == null ? null : () => onAuthorTap!(author),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    if (meta.isNotEmpty)
                      Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingM),
          if (post.isHidden)
            Text(l10n.postHidden,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant))
          else
            FlarumContent(
              siteContext: site,
              content: FlarumHtml.parse(post.contentHtml ?? '', forumBaseUrl: site.site.url).html,
              callbacks: callbacks,
            ),
          if (post.likesCount > 0 || post.mentionedByCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingS),
              child: Wrap(
                spacing: DesignTokens.spacingL,
                children: [
                  if (post.likesCount > 0)
                    _Count(icon: Icons.favorite_border, label: l10n.summaryLikeCount(post.likesCount)),
                  if (post.mentionedByCount > 0)
                    _Count(icon: Icons.reply, label: l10n.nReplies(post.mentionedByCount)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: DesignTokens.spacingXS),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}

/// An event post as the web's one-line notice: who did what, and when.
class EventPostNotice extends StatelessWidget {
  const EventPostNotice({super.key, required this.post});

  final FlarumPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final (icon, text) = describe(post, flarumL10n(context));
    final created = post.createdAt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: DesignTokens.spacingM),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: text),
                if (created != null) TextSpan(text: '  ${formatTimeAgo(created.toLocal(), context)}'),
              ]),
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  /// The notice for [post]'s event: Flarum's own types, and a neutral line
  /// for an extension's.
  static (IconData, String) describe(FlarumPost post, FlarumLocalizations l10n) {
    final user = post.author?.displayName ?? l10n.someone;
    final content = post.content;
    switch (post.contentType) {
      case 'discussionRenamed':
        if (content is List && content.length == 2) {
          return (Icons.edit_outlined, l10n.eventRenamed(user, '${content[0]}', '${content[1]}'));
        }
      case 'discussionLocked':
        final locked = content is Map && content['locked'] == true;
        return (locked ? Icons.lock_outline : Icons.lock_open, locked ? l10n.eventLocked(user) : l10n.eventUnlocked(user));
      case 'discussionStickied':
        final sticky = content is Map && content['sticky'] == true;
        return (Icons.push_pin_outlined, sticky ? l10n.eventStickied(user) : l10n.eventUnstickied(user));
      case 'discussionTagged':
        return (Icons.sell_outlined, l10n.eventTagged(user));
    }
    return (Icons.info_outline, l10n.eventOther(user));
  }
}
