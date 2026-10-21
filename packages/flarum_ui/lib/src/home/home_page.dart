import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/views/widgets/brand_image.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../compose/start_discussion_button.dart';
import '../messages/dialogs_page.dart';
import 'discussion_list_model.dart';
import '../search/search_page.dart';
import '../tags/tag_label.dart';
import '../tags/tags_page.dart';
import 'discussion_list_view.dart';
import 'welcome_hero.dart';

/// The forum's discussions, as the web's index page lists them: a view menu (All Discussions,
/// and the reader's Following, Bookmarks and Private Discussions; Messages and each tag open their
/// own pages) and a sort menu (Latest, Top, Newest, Oldest, and by title on 2.0). A discussion
/// opens at the first post the reader hasn't read.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.site, this.title});

  final SiteContext site;

  /// The forum's name, until its info has loaded.
  final String? title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final Map<(DiscussionView, DiscussionSort), DiscussionListModel> _lists = {};
  DiscussionView _view = DiscussionView.all;
  DiscussionSort _sort = DiscussionSort.latest;

  /// The forum's primary tags, at the end of the view menu as on the web.
  List<FlarumTag> _tags = const [];

  List<DiscussionView> get _views => [
        DiscussionView.all,
        if (_forum.isSignedIn) DiscussionView.following,
        if (_forum.isSignedIn && _forum.extensions.bookmarks) DiscussionView.bookmarks,
        if (_forum.isSignedIn && _forum.extensions.byobu) DiscussionView.private,
      ];

  List<DiscussionSort> get _sorts => DiscussionSort.offeredOn(_forum.info?.version);

  DiscussionListModel get _list => _lists.putIfAbsent((_view, _sort), () {
        final model = DiscussionListModel(_forum, view: _view, sort: _sort)..addListener(_changed);
        model.refresh();
        return model;
      });

  @override
  void initState() {
    super.initState();
    _forum.current().then((_) => _changed(), onError: (_) {});
    _forum.tags().then((tags) {
      int byPosition(FlarumTag a, FlarumTag b) => (a.position ?? 1 << 30).compareTo(b.position ?? 1 << 30);
      if (mounted) setState(() => _tags = tags.where((t) => t.isPrimary && !t.isChild).toList()..sort(byPosition));
    }, onError: (_) {
      // No flarum/tags, or not now: the menu goes without them.
    });
  }

  @override
  void dispose() {
    for (final model in _lists.values) {
      model
        ..removeListener(_changed)
        ..dispose();
    }
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  /// The web's Mark All as Read (the ✓ above its list), asked first as the web asks: Flarum
  /// records the time, and every discussion older than it reads as read.
  Future<void> _markAllRead() async {
    final l10n = flarumL10n(context);
    final reader = _forum.info?.actor;
    if (reader == null) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(l10n.markAllDiscussionsReadQuestion),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(kitL10n(dialog).cancel)),
          TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(l10n.ok)),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      await _forum.api.markAllAsRead(reader.id);
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(context, e));
      return;
    }
    for (final list in _lists.values) {
      list.refresh();
    }
  }

  /// The forum's logo where it has one (its dark-mode logo in dark mode, on 2.0), as the web's
  /// header shows it, named for screen readers; else its title.
  Widget _title(BuildContext context) {
    final title = _forum.info?.title ?? widget.title ?? '';
    final dark = Theme.of(context).brightness == Brightness.dark;
    final logo = (dark ? _forum.info?.logoDarkUrl : null) ?? _forum.info?.logoUrl;
    if (logo == null) return Text(title);
    return Semantics(
      label: title,
      header: true,
      excludeSemantics: true,
      child: BrandImage(
        logo,
        height: 32,
        fallback: (_) => Text(title),
        background: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      ),
    );
  }

  String _viewLabel(DiscussionView view, FlarumLocalizations l10n) => switch (view) {
        DiscussionView.all => l10n.allDiscussions,
        DiscussionView.following => l10n.following,
        DiscussionView.bookmarks => l10n.bookmarks,
        DiscussionView.private => l10n.privateDiscussions,
      };

  /// The web's icons for its sidebar links.
  static IconData _viewIcon(DiscussionView view) => switch (view) {
        DiscussionView.all => Icons.forum_outlined,
        DiscussionView.following => Icons.star_outline,
        DiscussionView.bookmarks => Icons.bookmark_outline,
        DiscussionView.private => Icons.map_outlined,
      };

  String _sortLabel(DiscussionSort sort, FlarumLocalizations l10n) => switch (sort) {
        DiscussionSort.latest => l10n.latest,
        DiscussionSort.top => l10n.filterTop,
        DiscussionSort.newest => l10n.viewNewest,
        DiscussionSort.oldest => l10n.sortOldest,
        DiscussionSort.titleAz => l10n.sortTitleAz,
        DiscussionSort.titleZa => l10n.sortTitleZa,
      };

  /// What the view menu picked: a list of Home's, or a page of its own.
  void _picked(Object choice) {
    switch (choice) {
      case DiscussionView view:
        setState(() => _view = view);
      case FlarumTag tag:
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TagPage(site: widget.site, tag: tag)));
      case _Messages():
        DialogsPage.open(context, widget.site);
    }
  }

  Widget _viewMenu(BuildContext context, FlarumLocalizations l10n, List<DiscussionView> views) {
    final theme = Theme.of(context);
    PopupMenuItem<Object> entry(Object value, IconData icon, String label, {Color? color, bool selected = false}) =>
        PopupMenuItem(
          value: value,
          child: Row(
            children: [
              Icon(icon, size: 20, color: color ?? (selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: DesignTokens.spacingM),
              Flexible(
                child: Text(label, style: selected ? TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600) : null),
              ),
            ],
          ),
        );
    return PopupMenuButton<Object>(
      tooltip: l10n.toggleNavigation,
      onSelected: _picked,
      itemBuilder: (_) => [
        entry(DiscussionView.all, _viewIcon(DiscussionView.all), l10n.allDiscussions, selected: _view == DiscussionView.all),
        if (_forum.isSignedIn && _forum.extensions.messages) entry(const _Messages(), Icons.mail_outline, l10n.messages),
        for (final view in views.skip(1)) entry(view, _viewIcon(view), _viewLabel(view, l10n), selected: _view == view),
        if (_tags.isNotEmpty) const PopupMenuDivider(),
        for (final tag in _tags)
          entry(tag, flarumTagIcon(tag.icon) ?? Icons.label, tag.name,
              color: flarumTagColor(tag) ?? theme.colorScheme.onSurfaceVariant),
      ],
      child: _MenuLabel(icon: _viewIcon(_view), label: _viewLabel(_view, l10n)),
    );
  }

  Widget _sortMenu(FlarumLocalizations l10n) => PopupMenuButton<DiscussionSort>(
        tooltip: l10n.changeSorting,
        initialValue: _sort,
        onSelected: (sort) => setState(() => _sort = sort),
        itemBuilder: (_) => [
          for (final sort in _sorts) CheckedPopupMenuItem(value: sort, checked: sort == _sort, child: Text(_sortLabel(sort, l10n))),
        ],
        child: _MenuLabel(label: _sortLabel(_sort, l10n)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final views = _views;
    // A view the reader can't have now (logged out): back to All Discussions.
    if (!views.contains(_view)) _view = DiscussionView.all;
    if (!_sorts.contains(_sort)) _sort = DiscussionSort.latest;
    final list = _list;
    return Scaffold(
      appBar: AppBar(
        title: _title(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () => SearchPage.open(context, widget.site),
          ),
          if (_forum.isSignedIn && _forum.info?.actor != null)
            IconButton(icon: const Icon(Icons.done_all), tooltip: l10n.markAllRead, onPressed: _markAllRead),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
            child: Row(
              children: [
                Flexible(child: _viewMenu(context, l10n, views)),
                const SizedBox(width: DesignTokens.spacingS),
                _sortMenu(l10n),
              ],
            ),
          ),
        ),
      ),
      body: DiscussionListView(
        site: widget.site,
        list: list,
        emptyMessage: _view == DiscussionView.bookmarks ? l10n.noBookmarks : null,
        header: _view == DiscussionView.all
            ? WelcomeHero(site: widget.site, title: _forum.info?.welcomeTitle, message: _forum.info?.welcomeMessage)
            : null,
      ),
      floatingActionButton: startDiscussionButton(context, widget.site, onStarted: list.refresh),
    );
  }
}

/// The view menu's Messages: the conversations page (flarum/messages, 2.0).
class _Messages {
  const _Messages();
}

/// A menu's face, as the web's dropdown buttons show it: what's chosen, and the arrow.
class _MenuLabel extends StatelessWidget {
  const _MenuLabel({this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingM),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20, color: theme.colorScheme.primary), const SizedBox(width: DesignTokens.spacingS)],
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
          Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
