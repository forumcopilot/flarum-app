import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/filter_chip_bar.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../app/forum_drawer.dart';
import '../compose/start_discussion_button.dart';
import 'discussion_list_model.dart';
import '../search/search_page.dart';
import '../tags/tags_page.dart';
import 'discussion_list_view.dart';
import 'forum_masthead.dart';
import 'welcome_hero.dart';

/// The forum's discussions, as the Discourse app's Home: the forum's header with a search field,
/// then chips for the web's sorts (Latest, Top, Newest, Oldest, and by title on 2.0) and the
/// forum's Tags, pinned under the header's bar as it collapses. The reader's own lists (Following,
/// Bookmarks) and each tag are in the forum's drawer. A discussion opens at the first post the
/// reader hasn't read.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.site, this.title});

  final SiteContext site;

  /// The forum's name, until its info has loaded.
  final String? title;

  @override
  State<HomePage> createState() => _HomePageState();
}

/// What a Home chip shows: the discussions in a sort, or the forum's tags.
sealed class _HomeView {
  const _HomeView();
}

class _Sorted extends _HomeView {
  const _Sorted(this.sort);

  final DiscussionSort sort;

  @override
  bool operator ==(Object other) => other is _Sorted && other.sort == sort;

  @override
  int get hashCode => sort.hashCode;
}

class _Tags extends _HomeView {
  const _Tags();

  @override
  bool operator ==(Object other) => other is _Tags;

  @override
  int get hashCode => 0;
}

class _HomePageState extends State<HomePage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final Map<DiscussionSort, DiscussionListModel> _lists = {};
  _HomeView _view = const _Sorted(DiscussionSort.latest);

  /// Folded to its icon while the reader scrolls on through the list.
  bool _fabExtended = true;

  /// The chips, in order: the two the reader wants most (what's new, where things are), then the
  /// other orders.
  List<_HomeView> get _views {
    final sorts = DiscussionSort.offeredOn(_forum.info?.version);
    return [
      const _Sorted(DiscussionSort.latest),
      if (_forum.extensions.tags) const _Tags(),
      for (final sort in sorts.skip(1)) _Sorted(sort),
    ];
  }

  DiscussionListModel _list(DiscussionSort sort) => _lists.putIfAbsent(sort, () {
        final model = DiscussionListModel(_forum, sort: sort)..addListener(_changed);
        model.refresh();
        return model;
      });

  @override
  void initState() {
    super.initState();
    _forum.current().then((_) => _changed(), onError: (_) {});
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

  String _viewLabel(_HomeView view, FlarumLocalizations l10n) => switch (view) {
        _Sorted(:final sort) => discussionSortLabel(sort, l10n),
        _Tags() => l10n.tags,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final info = _forum.info;
    final views = _views;
    // A view the forum can't have (by title on 1.x): back to Latest.
    if (!views.contains(_view)) _view = const _Sorted(DiscussionSort.latest);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final header = [
      ForumMasthead(
        name: info?.title ?? widget.title ?? '',
        description: info?.description,
        logoUrl: (dark ? info?.logoDarkUrl : null) ?? info?.logoUrl,
        iconUrl: info?.faviconUrl,
        leading: forumDrawerButton(context),
        onSearch: () => SearchPage.open(context, widget.site),
        actions: [
          if (_forum.isSignedIn && info?.actor != null)
            IconButton(icon: const Icon(Icons.done_all), tooltip: l10n.markAllRead, onPressed: _markAllRead),
        ],
      ),
      PinnedHeaderSliver(
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: FilterChipBar(
            options: [for (final view in views) FilterChipOption(label: _viewLabel(view, l10n))],
            selectedIndex: views.indexOf(_view),
            onSelected: (i) => setState(() => _view = views[i]),
          ),
        ),
      ),
    ];
    final edge = ForumMasthead.collapsedHeight(context);
    final view = _view;
    final DiscussionListModel? list = view is _Sorted ? _list(view.sort) : null;
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (n) {
          if (n.depth != 0) return false;
          final extended = switch (n.direction) {
            ScrollDirection.reverse => false,
            ScrollDirection.forward => true,
            ScrollDirection.idle => _fabExtended,
          };
          if (extended != _fabExtended) setState(() => _fabExtended = extended);
          return false;
        },
        child: list == null
            ? TagsView(key: const ValueKey('tags'), site: widget.site, headerSlivers: header, refreshEdgeOffset: edge)
            : DiscussionListView(
                key: ValueKey(view),
                site: widget.site,
                list: list,
                excerpts: true,
                headerSlivers: header,
                refreshEdgeOffset: edge,
                header: WelcomeHero(site: widget.site, title: info?.welcomeTitle, message: info?.welcomeMessage),
              ),
      ),
      floatingActionButton:
          startDiscussionButton(context, widget.site, onStarted: list?.refresh, extended: _fabExtended),
    );
  }
}
