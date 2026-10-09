import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/filter_chip_bar.dart';
import 'package:forum_kit/views/widgets/topic_list_skeleton.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../thread/thread_page.dart';
import 'discussion_list_model.dart';
import 'discussion_tile.dart';

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

  Future<void> _open(FlarumDiscussion discussion) async {
    final list = _list;
    await ThreadPage.open(context, widget.site, discussion.id, near: list.openAt(discussion), title: discussion.title);
    await list.reload(discussion.id);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: FilterChipBar(
            options: [for (final view in views) FilterChipOption(label: _label(view, l10n))],
            selectedIndex: views.indexOf(_view).clamp(0, views.length - 1),
            onSelected: (i) => setState(() => _view = views[i]),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: list.refresh,
        child: _body(list, l10n),
      ),
    );
  }

  Widget _body(DiscussionListModel list, FlarumLocalizations l10n) {
    if (list.items.isEmpty) {
      if (list.error != null) {
        return EmptyStateView.error(
          message: l10n.discussionsLoadFailed,
          hint: describeFlarumError(list.error!),
          onRetry: list.refresh,
        );
      }
      if (list.loading) return const TopicListSkeleton();
      return EmptyStateView.scrollable(icon: Icons.forum_outlined, message: l10n.noDiscussions);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 600) list.loadMore();
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: list.items.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == list.items.length) {
            if (list.error != null) {
              return TextButton.icon(onPressed: list.loadMore, icon: const Icon(Icons.refresh), label: Text(l10n.retry));
            }
            return list.hasMore
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                : const SizedBox(height: 48);
          }
          final d = list.items[i];
          return DiscussionTile(key: ValueKey(d.id), discussion: d, unread: list.unreadIn(d), onTap: () => _open(d));
        },
      ),
    );
  }
}
