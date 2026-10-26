import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/views/widgets/forum_icon_tile.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/forum_masthead.dart' show mastheadOpenness;
import 'tag_label.dart';

/// The top of a tag's page, as the Discourse app heads a category's: where it sits (the forum, and
/// the parent of a child tag), its mark and name, how the reader follows it, two lines of its
/// description and how many discussions it has, on a tint of its colour with the colour itself as
/// a line along the bottom.
///
/// A tint rather than a bar of the colour, as the web's hero has it: tag colours are picked for
/// small labels and are often bright, and a bar of one either fails as a background for its text
/// (Flarum's orange took white at 2.8:1) or has to be darkened into another colour. The exact
/// colour stays where it's recognised, in the mark and the line.
///
/// It collapses into the page's bar with the mark and name; the line stays.
class TagMasthead extends StatelessWidget {
  const TagMasthead({
    super.key,
    required this.tag,
    required this.forumName,
    this.forumIconUrl,
    this.parent,
    this.onOpenParent,
    this.followLevel,
    this.onFollowChanged,
  });

  final FlarumTag tag;
  final String forumName;
  final String? forumIconUrl;

  /// A child tag's parent, in the breadcrumb.
  final FlarumTag? parent;
  final VoidCallback? onOpenParent;

  /// The reader's level for the tag (fof/follow-tags): follow, lurk, ignore, hide, or none.
  final String? followLevel;

  /// Changes it; null hides the follow button (a guest, or a forum without fof/follow-tags).
  final ValueChanged<String?>? onFollowChanged;

  static const toolbarHeight = 64.0;
  static const lineHeight = 4.0;

  /// The bar's height once the header has collapsed, for a refresh spinner to show under it.
  static double collapsedHeight(BuildContext context) =>
      MediaQuery.paddingOf(context).top + toolbarHeight + lineHeight;

  double _introHeight(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle? s) => (scaler.scale(s?.fontSize ?? 14) * (s?.height ?? 1.4) - 1e-6).ceilToDouble();
    var h = line(text.bodySmall) + 8; // breadcrumb
    final name = line(text.titleLarge);
    h += (name > 40 ? name : 40) + 8;
    if (tag.description != null) h += 2 * line(text.bodyMedium);
    h += 6 + line(text.bodySmall); // discussions
    return h + 14;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = tagMarkColor(flarumTagColor(tag) ?? colorScheme.outline, colorScheme.surface);
    final tint = Color.lerp(colorScheme.surface, color, dark ? 0.16 : 0.12)!;
    final onChanged = onFollowChanged;
    return SliverAppBar(
      pinned: true,
      expandedHeight: toolbarHeight + _introHeight(context) + lineHeight,
      toolbarHeight: toolbarHeight,
      backgroundColor: tint,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      title: _Collapsed(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TagTileMark(tag: tag, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Text(tag.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
      actions: [
        if (onChanged != null) _Collapsed(child: TagFollowMenu(level: followLevel, onChanged: onChanged)),
      ],
      flexibleSpace: _TagIntro(masthead: this),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(lineHeight),
        child: ColoredBox(color: color, child: const SizedBox(height: lineHeight, width: double.infinity)),
      ),
    );
  }
}

/// Shown only once the header has become the bar.
class _Collapsed extends StatelessWidget {
  const _Collapsed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shown = mastheadOpenness(context) < 0.35;
    return AnimatedOpacity(
      opacity: shown ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: ExcludeSemantics(excluding: !shown, child: IgnorePointer(ignoring: !shown, child: child)),
    );
  }
}

/// The open header: breadcrumb, mark and name with the follow button, description and count,
/// clipped between the bar and the line so it slides under the bar as the page scrolls.
class _TagIntro extends StatelessWidget {
  const _TagIntro({required this.masthead});

  final TagMasthead masthead;

  void _showDescription(BuildContext context, String description) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(masthead.tag.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = mastheadOpenness(context);
    final opacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    final hidden = opacity < 0.5;
    final colorScheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = flarumL10n(context);
    final tag = masthead.tag;
    final parent = masthead.parent;
    final muted = text.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);
    final description = tag.description;
    final onChanged = masthead.onFollowChanged;
    final crumb = Row(children: [
      ForumIconTile(name: masthead.forumName, url: masthead.forumIconUrl, size: 16),
      const SizedBox(width: 6),
      Flexible(child: Text(masthead.forumName, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis)),
      if (parent != null) ...[
        Icon(Icons.chevron_right, size: 16, color: colorScheme.onSurfaceVariant),
        Flexible(
          child: InkWell(
            onTap: masthead.onOpenParent,
            child: Text(parent.name,
                style: muted?.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    ]);

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          crumb,
          const SizedBox(height: 8),
          Row(children: [
            TagTileMark(tag: tag, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(tag.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
              ),
            ),
            if (onChanged != null) ...[
              const SizedBox(width: 8),
              TagFollowMenu(level: masthead.followLevel, onChanged: onChanged, button: true),
            ],
          ]),
          const SizedBox(height: 8),
          if (description != null)
            GestureDetector(
              onTap: () => _showDescription(context, description),
              child: Text(description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
          const SizedBox(height: 6),
          Text(l10n.tagDiscussionCount(tag.discussionCount), style: muted, maxLines: 1),
        ],
      ),
    );

    return Stack(children: [
      Positioned(
        top: MediaQuery.paddingOf(context).top + TagMasthead.toolbarHeight,
        left: 0,
        right: 0,
        bottom: TagMasthead.lineHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Opacity(
              opacity: opacity,
              child: IgnorePointer(ignoring: hidden, child: ExcludeSemantics(excluding: hidden, child: content)),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// How the reader follows a tag (fof/follow-tags), as the web's menu offers it: an icon in the
/// bar, or an outlined button that names the level in the header.
class TagFollowMenu extends StatelessWidget {
  const TagFollowMenu({super.key, required this.level, required this.onChanged, this.button = false});

  final String? level;
  final ValueChanged<String?> onChanged;
  final bool button;

  // A menu item's value can't be null (that reads as dismissing the menu).
  static const _none = '';

  /// Each level's icon, in the menu and on the button.
  /// fof/follow-tags' own: an empty star, a star, comments, a crossed-out bell, a crossed-out eye.
  static const _icons = {
    _none: Icons.star_border,
    'follow': Icons.star,
    'lurk': Icons.forum,
    'ignore': Icons.notifications_off,
    'hide': Icons.visibility_off,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final name = switch (level) {
      'follow' => l10n.following,
      'lurk' => l10n.lurking,
      'ignore' => l10n.ignoring,
      'hide' => l10n.hidden,
      _ => l10n.follow,
    };
    PopupMenuItem<String> item(String value, IconData icon, String title, String hint) => PopupMenuItem(
          value: value,
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(hint),
            trailing: (level ?? _none) == value ? const Icon(Icons.check) : null,
            contentPadding: EdgeInsets.zero,
          ),
        );
    final icon = Icon(_icons[level] ?? _icons[_none], size: button ? 18 : null);
    return PopupMenuButton<String>(
      icon: button ? null : icon,
      // The level, as the web's button names it: Follow while not following.
      tooltip: name,
      onSelected: (value) => onChanged(value == _none ? null : value),
      itemBuilder: (_) => [
        item(_none, _icons[_none]!, l10n.notFollowing, l10n.notFollowingHint),
        item('follow', _icons['follow']!, l10n.following, l10n.tagFollowingHint),
        item('lurk', _icons['lurk']!, l10n.lurking, l10n.lurkingHint),
        item('ignore', _icons['ignore']!, l10n.ignoring, l10n.tagIgnoringHint),
        item('hide', _icons['hide']!, l10n.hidden, l10n.hiddenHint),
      ],
      child: button
          ? IgnorePointer(
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  visualDensity: VisualDensity.compact,
                ),
                icon: icon,
                label: Text(name),
              ),
            )
          : null,
    );
  }
}
