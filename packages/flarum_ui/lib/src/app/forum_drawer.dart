import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/views/widgets/forum_icon_tile.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/flarum_l10n.dart';
import '../account/log_in_first.dart';
import '../bookmarks/bookmarks_page.dart';
import '../home/following_page.dart';
import '../profile/user_page.dart';
import '../render/links.dart';
import '../tags/tag_label.dart';
import '../tags/tags_page.dart';
import '../widgets/flarum_avatar.dart';

/// Opens the forum's drawer from a tab's top bar. The tabs each have a Scaffold of their own, so
/// their bars can't find the shell's drawer by themselves; a page pushed over the forum isn't under
/// the scope, and keeps its back arrow.
class ForumDrawerScope extends InheritedWidget {
  const ForumDrawerScope({super.key, required this.open, required super.child});

  final VoidCallback open;

  static ForumDrawerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ForumDrawerScope>();

  @override
  bool updateShouldNotify(ForumDrawerScope oldWidget) => oldWidget.open != open;
}

/// ☰ for a tab's top bar, or null outside the forum's tabs (for the bar's own back arrow).
Widget? forumDrawerButton(BuildContext context) {
  final scope = ForumDrawerScope.maybeOf(context);
  if (scope == null) return null;
  return IconButton(
    icon: const Icon(Icons.menu),
    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    onPressed: scope.open,
  );
}

/// The forum's map, as the Discourse app's drawer is and as Flarum's own phone layout keeps its
/// sidebar in a drawer: the forum and who the reader is, then the lists (All Discussions,
/// Following, Bookmarks, the reader's posts), then the forum's tags, each child under its parent,
/// and All Tags. Each section folds and stays folded.
class ForumDrawer extends StatelessWidget {
  const ForumDrawer({
    super.key,
    required this.site,
    required this.homeIsCurrent,
    required this.onHome,
    required this.onProfile,
    this.introduction = false,
  });

  final SiteContext site;

  /// Whether Home's discussions are showing, so All Discussions is marked as where the reader is.
  final bool homeIsCurrent;

  /// Back to Home's discussions (the drawer has closed).
  final VoidCallback onHome;

  /// The reader's own tab, from the account card.
  final VoidCallback onProfile;

  /// Whether the drawer opened by itself, to introduce itself: a line says what it holds and how
  /// to open it again.
  final bool introduction;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final forum = FlarumForum.of(site);
    final reader = forum.isSignedIn ? forum.info?.actor : null;

    void go(void Function(NavigatorState navigator) to) {
      final navigator = Navigator.of(context);
      navigator.pop();
      to(navigator);
    }

    return Drawer(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Header(site: site, onProfile: onProfile),
            if (introduction) const _Introduction(),
            _Section(
              id: 'community',
              label: l10n.community,
              children: [
                _Item(
                  icon: Icons.forum_outlined,
                  label: l10n.allDiscussions,
                  selected: homeIsCurrent,
                  onTap: () {
                    Navigator.of(context).pop();
                    onHome();
                  },
                ),
                if (reader != null)
                  _Item(
                    icon: Icons.star_outline,
                    label: l10n.following,
                    onTap: () => go((_) => FollowingPage.open(context, site)),
                  ),
                if (reader != null && forum.extensions.bookmarks)
                  _Item(
                    icon: Icons.bookmark_outline,
                    label: l10n.bookmarks,
                    onTap: () => go((_) => BookmarksPage.open(context, site)),
                  ),
                if (reader != null)
                  _Item(
                    icon: Icons.person_outline,
                    label: l10n.myPosts,
                    onTap: () => go((_) => UserPage.open(context, site, reader.slug ?? reader.username)),
                  ),
              ],
            ),
            if (forum.extensions.tags) _TagsSection(site: site, forum: forum),
          ],
        ),
      ),
    );
  }
}

/// The forum's primary tags in the admin's order, a parent's children folded under it, then All
/// Tags. Loaded with the drawer; the forum keeps them once read.
class _TagsSection extends StatelessWidget {
  const _TagsSection({required this.site, required this.forum});

  final SiteContext site;
  final FlarumForum forum;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return FutureBuilder<List<FlarumTag>>(
      future: forum.tags(),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? const <FlarumTag>[];
        int byPosition(FlarumTag a, FlarumTag b) => (a.position ?? 1 << 30).compareTo(b.position ?? 1 << 30);
        final primary = tags.where((t) => t.isPrimary && !t.isChild).toList()..sort(byPosition);
        void open(FlarumTag tag) {
          Navigator.of(context).pop();
          TagPage.open(context, site, tag);
        }

        return _Section(
          id: 'tags',
          label: l10n.tags,
          children: [
            for (final tag in primary)
              _TagItem(
                tag: tag,
                children: tags.where((t) => t.parentId == tag.id).toList()..sort(byPosition),
                onOpen: open,
              ),
            _Item(
              icon: Icons.list,
              label: l10n.allTags,
              onTap: () {
                Navigator.of(context).pop();
                TagsPage.open(context, site);
              },
            ),
          ],
        );
      },
    );
  }
}

/// A primary tag in the drawer, and its children, which fold under it (shown or not is kept for
/// the run).
class _TagItem extends StatefulWidget {
  const _TagItem({required this.tag, required this.children, required this.onOpen});

  final FlarumTag tag;
  final List<FlarumTag> children;
  final ValueChanged<FlarumTag> onOpen;

  @override
  State<_TagItem> createState() => _TagItemState();
}

class _TagItemState extends State<_TagItem> {
  static final _unfolded = <String>{};

  bool get _open => _unfolded.contains(widget.tag.id);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = flarumL10n(context);
    final hasChildren = widget.children.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Item(
          leading: TagTileMark(tag: widget.tag, size: 20),
          label: widget.tag.name,
          onTap: () => widget.onOpen(widget.tag),
          trailing: hasChildren
              ? IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: _open ? l10n.hideChildTags(widget.tag.name) : l10n.showChildTags(widget.tag.name),
                  icon: Icon(_open ? Icons.expand_less : Icons.expand_more, color: colorScheme.onSurfaceVariant),
                  onPressed: () => setState(() => _open ? _unfolded.remove(widget.tag.id) : _unfolded.add(widget.tag.id)),
                )
              : null,
        ),
        if (hasChildren && _open)
          for (final child in widget.children)
            _Item(
              indent: 24,
              leading: TagMark(tag: child, parent: widget.tag, size: 14),
              label: child.name,
              onTap: () => widget.onOpen(child),
            ),
      ],
    );
  }
}

/// What the drawer is and how to open it again, shown the one time it opens by itself.
class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          child: Row(children: [
            Icon(Icons.menu, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                flarumL10n(context).drawerIntroduction,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSecondaryContainer),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The forum, small (its identity is on the screen behind), then the reader: a card that opens
/// their profile, or Log In and Sign Up.
class _Header extends StatelessWidget {
  const _Header({required this.site, required this.onProfile});

  final SiteContext site;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final forum = FlarumForum.of(site);
    final info = forum.info;
    final name = info?.title ?? site.site.name;
    final host = Uri.tryParse(site.site.url)?.host ?? site.site.url;
    final reader = forum.isSignedIn ? info?.actor : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            ForumIconTile(name: name, url: info?.faviconUrl, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(host,
                      style: text.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Material(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: reader == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      onProfile();
                    },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      reader == null
                          ? CircleAvatar(
                              radius: 18,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.person_outline, size: 20, color: colorScheme.onSurfaceVariant),
                            )
                          : FlarumAvatar(user: reader, radius: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reader?.displayName ?? l10n.notLoggedIn,
                                style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(
                              reader == null
                                  ? l10n.logInToTakePart
                                  : '@${reader.username} · ${l10n.goToYourProfile}',
                              style: text.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (reader != null) Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                    ]),
                    if (reader == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 4),
                        child: Row(children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                logInFirst(context, site);
                              },
                              child: Text(l10n.signIn, maxLines: 1),
                            ),
                          ),
                          // Sign-up happens on the forum's page, when it takes new members.
                          if (info?.allowSignUp ?? false) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => openExternally(site.site.url),
                                child: Text(l10n.createAccount, maxLines: 1),
                              ),
                            ),
                          ],
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A drawer section with a label that folds it. Whether it's open is remembered across launches.
class _Section extends StatefulWidget {
  const _Section({required this.id, required this.label, required this.children});

  final String id;
  final String label;
  final List<Widget> children;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool _open = true;

  String get _key => 'flarum_drawer_section_open_${widget.id}';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getBool(_key);
      if (saved != null && mounted && saved != _open) setState(() => _open = saved);
    }, onError: (_) {});
  }

  void _toggle() {
    setState(() => _open = !_open);
    SharedPreferences.getInstance().then((p) => p.setBool(_key, _open), onError: (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: 4), child: Divider(height: 1)),
        Semantics(
          header: true,
          expanded: _open,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 20, 8),
              child: Row(children: [
                Expanded(child: Text(widget.label, style: text.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant))),
                Icon(_open ? Icons.expand_less : Icons.expand_more, size: 20, color: colorScheme.onSurfaceVariant),
              ]),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: _open
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// One destination, Material 3's navigation-drawer item: at least 48dp, a pill behind the current
/// one.
class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.onTap,
    this.icon,
    this.leading,
    this.trailing,
    this.selected = false,
    this.indent = 0,
  });

  final IconData? icon;
  final Widget? leading;
  final String label;
  final Widget? trailing;
  final bool selected;
  final double indent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fg = selected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 12 + indent, end: 12),
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 16, end: trailing == null ? 16 : 4, top: 4, bottom: 4),
              child: Row(children: [
                SizedBox(width: 24, child: Center(child: leading ?? Icon(icon, color: fg))),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelLarge?.copyWith(
                        color: selected ? colorScheme.onSecondaryContainer : colorScheme.onSurface),
                  ),
                ),
                if (trailing != null) trailing!,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
