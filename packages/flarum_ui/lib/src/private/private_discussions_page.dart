import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../compose/composers.dart';
import '../home/discussion_list_model.dart';
import '../home/discussion_list_view.dart';
import '../thread/thread_page.dart';

/// The reader's private discussions (fof/byobu), and a way to start one.
class PrivateDiscussionsPage extends StatefulWidget {
  const PrivateDiscussionsPage({super.key, required this.site});

  final SiteContext site;

  static Future<void> open(BuildContext context, SiteContext site) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PrivateDiscussionsPage(site: site)));

  @override
  State<PrivateDiscussionsPage> createState() => _PrivateDiscussionsPageState();
}

class _PrivateDiscussionsPageState extends State<PrivateDiscussionsPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  late final _list = DiscussionListModel(_forum, private: true)..addListener(_changed);

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

  Future<void> _start() async {
    final discussion = await composePrivateDiscussion(context, widget.site);
    if (discussion == null || !mounted) return;
    _list.refresh();
    ThreadPage.open(context, widget.site, discussion.id, title: discussion.title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privateDiscussions)),
      body: DiscussionListView(site: widget.site, list: _list, emptyMessage: l10n.noPrivateDiscussions),
      floatingActionButton: canStartPrivateDiscussion(_forum)
          ? FloatingActionButton.extended(
              onPressed: _start,
              icon: const Icon(Icons.map_outlined),
              label: Text(l10n.startPrivateDiscussion),
            )
          : null,
    );
  }
}

/// Whether the reader may start a private discussion with other members (fof/byobu).
bool canStartPrivateDiscussion(FlarumForum forum) =>
    forum.isSignedIn && (forum.info?.can('canStartPrivateDiscussionWithUsers') ?? false);
