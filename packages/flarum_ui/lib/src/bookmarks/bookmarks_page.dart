import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../home/discussion_list_model.dart';
import '../home/discussion_list_view.dart';
import '../home/post_list.dart';

/// The reader's bookmarks (fof/bookmarks): the discussions and the posts they bookmarked.
class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BookmarksPage(site: site)));

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final _discussions = DiscussionListModel(_forum, bookmarked: true)..addListener(_changed);
  late final _posts = PostListModel((offset) => _forum.api.bookmarkedPosts(offset: offset))..addListener(_changed);

  @override
  void initState() {
    super.initState();
    _discussions.refresh();
    _posts.refresh();
  }

  @override
  void dispose() {
    for (final model in [_discussions, _posts]) {
      model
        ..removeListener(_changed)
        ..dispose();
    }
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  /// Back from a discussion: either tab can have lost a bookmark there.
  void _returned() {
    if (!mounted) return;
    _discussions.refresh();
    _posts.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookmarks),
          bottom: TabBar(tabs: [Tab(text: l10n.discussionsTab), Tab(text: l10n.posts)]),
        ),
        body: TabBarView(
          children: [
            DiscussionListView(site: widget.site, list: _discussions, emptyMessage: l10n.noBookmarks, onReturn: _returned),
            PostList(
              site: widget.site,
              model: _posts,
              emptyMessage: l10n.noBookmarks,
              failedMessage: l10n.discussionsLoadFailed,
              onReturn: _returned,
            ),
          ],
        ),
      ),
    );
  }
}
