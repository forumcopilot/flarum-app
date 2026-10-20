import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forum_kit/views/widgets/filter_chip_bar.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../compose/start_discussion_button.dart';
import 'discussion_list_model.dart';
import '../search/search_page.dart';
import 'discussion_list_view.dart';

/// The forum's discussions, in the web's views: Latest, Top, Newest, and
/// Following for a signed-in reader. A discussion opens at the first post
/// the reader hasn't read.
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
  final Map<DiscussionView, DiscussionListModel> _lists = {};
  DiscussionView _view = DiscussionView.latest;

  List<DiscussionView> get _views => [
        DiscussionView.latest,
        DiscussionView.top,
        DiscussionView.newest,
        if (_forum.isSignedIn) DiscussionView.following,
      ];

  DiscussionListModel get _list => _lists.putIfAbsent(_view, () {
        final model = DiscussionListModel(_forum, view: _view)..addListener(_changed);
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

  String _label(DiscussionView view, FlarumLocalizations l10n) => switch (view) {
        DiscussionView.latest => l10n.latest,
        DiscussionView.top => l10n.filterTop,
        DiscussionView.newest => l10n.viewNewest,
        DiscussionView.following => l10n.following,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final views = _views;
    final list = _list;
    return Scaffold(
      appBar: AppBar(
        title: Text(_forum.info?.title ?? widget.title ?? ''),
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
          preferredSize: const Size.fromHeight(56),
          child: FilterChipBar(
            options: [for (final view in views) FilterChipOption(label: _label(view, l10n))],
            selectedIndex: views.indexOf(_view).clamp(0, views.length - 1),
            onSelected: (i) => setState(() => _view = views[i]),
          ),
        ),
      ),
      body: DiscussionListView(site: widget.site, list: list),
      floatingActionButton: startDiscussionButton(context, widget.site, onStarted: list.refresh),
    );
  }
}
