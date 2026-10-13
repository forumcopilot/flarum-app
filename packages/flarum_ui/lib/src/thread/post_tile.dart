import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/theme/forum_colors.dart';
import 'package:forum_kit/utils/emoji_shortcodes.dart';
import 'package:forum_kit/utils/time_utils.dart';
import 'package:forum_kit/views/widgets/post_content_callbacks.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/flarum_content.dart';
import '../render/flarum_html.dart';
import '../widgets/flarum_avatar.dart';

/// One post in a thread: a comment with its author, time and body, or an
/// event (a rename, lock, sticky, retag…) as a one-line notice.
class PostTile extends StatelessWidget {
  const PostTile(
      {super.key,
      required this.site,
      required this.post,
      this.callbacks,
      this.onAuthorTap,
      this.onOpenReply,
      this.tags,
      this.isBestAnswer = false,
      this.onGoToBestAnswer,
      this.onReply,
      this.onQuote,
      this.onEdit,
      this.readerId,
      this.reactions = const [],
      this.onLike,
      this.onReact,
      this.onBookmark,
      this.onChooseBestAnswer,
      this.onFlag,
      this.authorIgnored = false,
      this.onIgnore,
      this.onHide,
      this.onDeleteForever,
      this.onApprove});

  final SiteContext site;
  final FlarumPost post;
  final PostContentCallbacks? callbacks;

  /// The author's avatar or name was tapped.
  final void Function(FlarumUser author)? onAuthorTap;

  /// One of the replies to the post was chosen (from "… replied to this").
  final void Function(FlarumPostReply reply)? onOpenReply;

  /// The forum's tags by id, to name the tags in a retag event.
  final Map<String, FlarumTag>? tags;

  /// fof/best-answer chose this post as the discussion's answer.
  final bool isBestAnswer;

  /// Set on the question when another post is its best answer: offers a way there.
  final VoidCallback? onGoToBestAnswer;

  /// The post's menu: reply to it, quote it, edit it. Each shows only when given.
  final VoidCallback? onReply;
  final VoidCallback? onQuote;
  final VoidCallback? onEdit;

  /// The signed-in reader's id: whether they liked the post.
  final String? readerId;

  /// The reactions the forum offers (fof/reactions), for the picker and the post's chips.
  final List<FlarumReaction> reactions;

  /// Like or unlike; react (or take a reaction back); bookmark; choose or remove as the best
  /// answer. Each shows only when given.
  final VoidCallback? onLike;
  final void Function(FlarumReaction reaction)? onReact;
  final VoidCallback? onBookmark;
  final VoidCallback? onChooseBestAnswer;

  /// Report the post to the moderators (flarum/flags).
  final VoidCallback? onFlag;

  /// The reader ignores the post's author: it's folded away, a tap from showing.
  final bool authorIgnored;

  /// Ignore the author, or stop ([authorIgnored]).
  final VoidCallback? onIgnore;

  /// A moderator's (or the author's) Delete, which hides the post, and Restore; Delete forever, for
  /// a hidden post; Approve, for one held for approval (flarum/approval).
  final VoidCallback? onHide;
  final VoidCallback? onDeleteForever;
  final VoidCallback? onApprove;

  bool get _hasMenu =>
      onReply != null ||
      onQuote != null ||
      onEdit != null ||
      onBookmark != null ||
      onChooseBestAnswer != null ||
      onFlag != null ||
      onIgnore != null ||
      onHide != null ||
      onDeleteForever != null ||
      onApprove != null;

  @override
  Widget build(BuildContext context) {
    if (!post.isComment) return EventPostNotice(post: post, tags: tags);
    if (!authorIgnored) return _comment(context);
    return _Folded(
      label: flarumL10n(context).ignoredUserPost(post.author?.displayName ?? flarumL10n(context).someone),
      menu: _hasMenu ? _menu(context) : null,
      child: Builder(builder: _comment),
    );
  }

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
                child: FlarumAvatar(
                  user: author,
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
              if (_hasMenu) _menu(context),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingM),
          if (isBestAnswer)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
              child: _BestAnswerLabel(text: l10n.bestAnswer),
            ),
          if (!post.isApproved)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
              child: _Count(icon: Icons.hourglass_empty, label: l10n.awaitingApproval),
            ),
          if (post.isHidden)
            Text(l10n.postHidden,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant))
          else
            _PostBody(site: site, html: post.contentHtml ?? '', callbacks: callbacks),
          if (onGoToBestAnswer != null)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingS),
              child: OutlinedButton.icon(
                onPressed: onGoToBestAnswer,
                icon: Icon(Icons.check_circle_outline, color: ForumColors.of(context).success),
                label: Text(l10n.goToBestAnswer),
              ),
            ),
          _footer(context),
          if (post.mentionedByCount > 0)
            InkWell(
              onTap: post.mentionedBy.isEmpty ? null : () => _showReplies(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
                child: _Count(icon: Icons.reply, label: repliedBy(post, l10n)),
              ),
            ),
        ],
      ),
    );
  }
}

extension on PostTile {
  /// Reply, Quote and Edit, as the web offers them on a post, and the ways to object to it.
  Widget _menu(BuildContext context) {
    final kit = kitL10n(context);
    final l10n = flarumL10n(context);
    return PopupMenuButton<VoidCallback>(
      icon: const Icon(Icons.more_vert),
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        if (onReply case final reply?) PopupMenuItem(value: reply, child: _MenuRow(Icons.reply, kit.reply)),
        if (onQuote case final quote?) PopupMenuItem(value: quote, child: _MenuRow(Icons.format_quote, kit.quote)),
        if (onEdit case final edit?) PopupMenuItem(value: edit, child: _MenuRow(Icons.edit_outlined, kit.edit)),
        if (onBookmark case final bookmark?)
          PopupMenuItem(
            value: bookmark,
            child: post.bookmarked
                ? _MenuRow(Icons.bookmark_remove_outlined, l10n.removeBookmark)
                : _MenuRow(Icons.bookmark_add_outlined, l10n.bookmark),
          ),
        if (onChooseBestAnswer case final choose?)
          PopupMenuItem(
            value: choose,
            child: isBestAnswer
                ? _MenuRow(Icons.highlight_off, l10n.removeBestAnswer)
                : _MenuRow(Icons.check_circle_outline, l10n.chooseBestAnswer),
          ),
        if (onApprove case final approve?)
          PopupMenuItem(value: approve, child: _MenuRow(Icons.check, l10n.approve)),
        if (onHide case final hide?)
          PopupMenuItem(
            value: hide,
            child: post.isHidden
                ? _MenuRow(Icons.restore, l10n.restore)
                : _MenuRow(Icons.delete_outline, kit.delete),
          ),
        if (onDeleteForever case final delete?)
          PopupMenuItem(value: delete, child: _MenuRow(Icons.delete_forever_outlined, l10n.deleteForever)),
        if (onFlag != null || onIgnore != null) const PopupMenuDivider(),
        if (onFlag case final flag?) PopupMenuItem(value: flag, child: _MenuRow(Icons.flag_outlined, l10n.flagAction)),
        if (onIgnore case final ignore?)
          PopupMenuItem(
            value: ignore,
            child: authorIgnored
                ? _MenuRow(Icons.person_outline, l10n.stopIgnoringUser(post.author?.displayName ?? l10n.someone))
                : _MenuRow(Icons.person_off_outlined, l10n.ignoreUser(post.author?.displayName ?? l10n.someone)),
          ),
      ],
    );
  }

  /// Like, the post's reactions and React, as the web shows them under a post.
  Widget _footer(BuildContext context) {
    final l10n = flarumL10n(context);
    final liked = post.isLikedBy(readerId);
    final shown = [for (final r in reactions) if ((post.reactionCounts[r.id] ?? 0) > 0) r];
    final like = onLike != null || post.likesCount > 0;
    final react = onReact != null && reactions.isNotEmpty;
    if (!like && shown.isEmpty && !react) return const SizedBox.shrink();
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingS),
      child: Wrap(
        spacing: DesignTokens.spacingS,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (like)
            TextButton.icon(
              onPressed: onLike,
              icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? ForumColors.of(context).love : muted, size: 20),
              label: Text(post.likesCount > 0 ? '${post.likesCount}' : l10n.like),
              style: TextButton.styleFrom(foregroundColor: muted, visualDensity: VisualDensity.compact),
            ),
          for (final reaction in shown)
            ChoiceChip(
              label: Text('${reactionGlyph(reaction)} ${post.reactionCounts[reaction.id]}'),
              selected: post.userReactionId == reaction.id,
              onSelected: onReact == null ? null : (_) => onReact!(reaction),
              visualDensity: VisualDensity.compact,
              showCheckmark: false,
            ),
          if (react)
            IconButton(
              icon: Icon(Icons.add_reaction_outlined, color: muted, size: 20),
              tooltip: l10n.react,
              visualDensity: VisualDensity.compact,
              onPressed: () => _pickReaction(context),
            ),
        ],
      ),
    );
  }

  /// The forum's reactions in a sheet; the chosen one goes to [onReact].
  void _pickReaction(BuildContext context) {
    final l10n = flarumL10n(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.reactions, style: Theme.of(sheet).textTheme.titleMedium),
              const SizedBox(height: DesignTokens.spacingM),
              Wrap(
                spacing: DesignTokens.spacingS,
                runSpacing: DesignTokens.spacingS,
                children: [
                  for (final reaction in reactions)
                    Tooltip(
                      message: reaction.display ?? reaction.identifier,
                      child: ChoiceChip(
                        label: Text(reactionGlyph(reaction), style: const TextStyle(fontSize: 24)),
                        selected: post.userReactionId == reaction.id,
                        showCheckmark: false,
                        onSelected: (_) {
                          Navigator.of(sheet).pop();
                          onReact!(reaction);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reaction's glyph: its emoji, from the shortcode it's named by; else its name.
String reactionGlyph(FlarumReaction reaction) =>
    (reaction.type == 'emoji' ? discourseEmojiChar(reaction.identifier) : null) ?? reaction.display ?? reaction.identifier;

/// A post by someone the reader ignores, folded to a line until the reader shows it, as the web
/// folds it (fof/ignore-users).
class _Folded extends StatefulWidget {
  const _Folded({required this.label, required this.child, this.menu});

  final String label;
  final Widget child;
  final Widget? menu;

  @override
  State<_Folded> createState() => _FoldedState();
}

class _FoldedState extends State<_Folded> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    if (_shown) return widget.child;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(DesignTokens.spacingL, DesignTokens.spacingS, 0, DesignTokens.spacingS),
      child: Row(
        children: [
          Icon(Icons.visibility_off_outlined, size: DesignTokens.iconSizeM, color: muted),
          const SizedBox(width: DesignTokens.spacingM),
          Expanded(
            child: Text(widget.label, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: muted)),
          ),
          TextButton(onPressed: () => setState(() => _shown = true), child: Text(flarumL10n(context).showPost)),
          if (widget.menu case final menu?) menu,
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingS),
          // A long label (in a long language) wraps rather than run past the menu.
          Flexible(child: Text(label)),
        ],
      );
}

/// "bob and alice replied to this.", as the web words it: up to two names,
/// then how many more replies.
String repliedBy(FlarumPost post, FlarumLocalizations l10n) {
  final replies = <String, int>{};
  for (final reply in post.mentionedBy) {
    final name = reply.author?.displayName;
    if (name != null) replies[name] = (replies[name] ?? 0) + 1;
  }
  final names = replies.keys.take(2).toList();
  if (names.isEmpty) return l10n.nReplies(post.mentionedByCount);
  final shown = names.fold(0, (n, name) => n + replies[name]!);
  final others = post.mentionedByCount > shown ? post.mentionedByCount - shown : 0;
  return switch ((names.length, others)) {
    (1, 0) => l10n.repliedByOne(names[0]),
    (1, _) => l10n.repliedByOneMore(names[0], others),
    (_, 0) => l10n.repliedByTwo(names[0], names[1]),
    _ => l10n.repliedByMore(names[0], names[1], others),
  };
}

extension on PostTile {
  /// The replies, each opening at its post: here, or in its own discussion.
  void _showReplies(BuildContext context) {
    final l10n = flarumL10n(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
              child: Text(l10n.repliesTitle, style: Theme.of(sheet).textTheme.titleMedium),
            ),
            for (final reply in post.mentionedBy)
              ListTile(
                leading: FlarumAvatar(user: reply.author, radius: 18),
                title: Text(reply.author?.displayName ?? l10n.someone),
                subtitle: Text(reply.discussionId == post.discussionId || reply.discussionTitle == null
                    ? (reply.number == null ? '' : l10n.postNumber(reply.number!))
                    : reply.discussionTitle!),
                onTap: onOpenReply == null
                    ? null
                    : () {
                        Navigator.of(sheet).pop();
                        onOpenReply!(reply);
                      },
              ),
          ],
        ),
      ),
    );
  }
}

/// "✓ Best answer", in the forum's success colour, above the answer.
class _BestAnswerLabel extends StatelessWidget {
  const _BestAnswerLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = ForumColors.of(context).success;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 18, color: color),
        const SizedBox(width: DesignTokens.spacingXS),
        Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
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
  const EventPostNotice({super.key, required this.post, this.tags});

  final FlarumPost post;

  /// The forum's tags by id, to name the tags in a retag event.
  final Map<String, FlarumTag>? tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final (icon, text) = describe(post, flarumL10n(context), tags: tags);
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
  static (IconData, String) describe(FlarumPost post, FlarumLocalizations l10n, {Map<String, FlarumTag>? tags}) {
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
        // [[old tag ids], [new tag ids]]
        if (tags != null && content is List && content.length == 2 && content[0] is List && content[1] is List) {
          final before = {for (final id in content[0] as List) '$id'};
          final after = {for (final id in content[1] as List) '$id'};
          String names(Iterable<String> ids) =>
              [for (final id in ids) tags[id]?.name].nonNulls.join(', ');
          final added = names(after.difference(before));
          final removed = names(before.difference(after));
          if (added.isNotEmpty && removed.isNotEmpty) {
            return (Icons.sell_outlined, l10n.eventTagsMoved(user, added, removed));
          }
          if (added.isNotEmpty) return (Icons.sell_outlined, l10n.eventTagsAdded(user, added));
          if (removed.isNotEmpty) return (Icons.sell_outlined, l10n.eventTagsRemoved(user, removed));
        }
        return (Icons.sell_outlined, l10n.eventTagged(user));
      case 'discussionMerged':
        // fof/merge-discussions: {count, titles}.
        if (content is Map && content['count'] is int) {
          final titles = [for (final title in (content['titles'] as List? ?? const [])) '“$title”'].join(', ');
          return (Icons.call_merge, l10n.eventMerged(user, content['count'] as int, titles));
        }
      case 'discussionSplit':
        // fof/split: {title, count, url, toNew}: in the old discussion toNew, in the new one not.
        if (content is Map && content['count'] is int) {
          final title = '“${content['title'] ?? ''}”';
          final count = content['count'] as int;
          return (
            Icons.call_split,
            content['toNew'] == true ? l10n.eventSplitTo(user, count, title) : l10n.eventSplitFrom(user, count, title),
          );
        }
      case 'recipientsModified':
        // fof/byobu: {new: {users, groups}, old: {users, groups}}, ids only.
        return (Icons.group_outlined, l10n.eventRecipientsChanged(user));
    }
    return (Icons.info_outline, l10n.eventOther(user));
  }
}

/// A post's text, built once for its HTML. flutter_html styles and builds the whole post again on
/// every rebuild, and a thread rebuilds each post on screen whenever a page of posts loads: the same
/// widget handed back lets Flutter skip that (it still rebuilds for a theme or text-size change).
/// Taps go to the tile's current [callbacks].
class _PostBody extends StatefulWidget {
  const _PostBody({required this.site, required this.html, this.callbacks});

  final SiteContext site;
  final String html;
  final PostContentCallbacks? callbacks;

  @override
  State<_PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<_PostBody> {
  Widget? _content;
  String? _builtFor;
  bool _builtWithCallbacks = false;

  late final _callbacks = PostContentCallbacks(
    onUrlTap: (url) => widget.callbacks?.onUrlTap?.call(url),
    onImageTap: (url, context, heroTag) => widget.callbacks?.onImageTap?.call(url, context, heroTag),
    onMentionTap: (username) => widget.callbacks?.onMentionTap?.call(username),
  );

  @override
  Widget build(BuildContext context) {
    if (_content == null || _builtFor != widget.html || _builtWithCallbacks != (widget.callbacks != null)) {
      _builtFor = widget.html;
      _builtWithCallbacks = widget.callbacks != null;
      _content = FlarumContent(
        siteContext: widget.site,
        content: FlarumHtml.parse(widget.html, forumBaseUrl: widget.site.site.url).html,
        callbacks: widget.callbacks == null ? null : _callbacks,
      );
    }
    return _content!;
  }
}
