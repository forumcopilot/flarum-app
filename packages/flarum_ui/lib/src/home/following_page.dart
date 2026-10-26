import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import 'discussion_list_model.dart';
import 'discussion_list_view.dart';

/// The discussions the reader follows (flarum/subscriptions), latest first: the web's Following
/// view, opened from the forum's drawer.
class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => FollowingPage(site: site)));

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final _list = DiscussionListModel(_forum, view: DiscussionView.following)..addListener(_changed);

  @override
  void initState() {
    super.initState();
    _list.refresh();
  }

  @override
  void dispose() {
    _list
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.following)),
      body: DiscussionListView(site: widget.site, list: _list, emptyMessage: l10n.noFollowedDiscussions, excerpts: true),
    );
  }
}
