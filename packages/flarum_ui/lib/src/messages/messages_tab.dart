import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/views/widgets/empty_state_view.dart';
import 'package:forum_kit/views/widgets/filter_chip_bar.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../account/log_in_first.dart';
import '../app/forum_drawer.dart';
import '../private/private_discussions_page.dart';
import 'dialogs_page.dart';

/// The Messages tab, as the Discourse app has one: the reader's direct messages (flarum/messages,
/// 2.0) and private discussions (fof/byobu), with chips to choose when the forum has both. They
/// used to be in Home's menu and the Account list.
class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key, required this.site});

  final SiteContext site;

  /// Whether the forum has a Messages tab: it runs either kind.
  static bool offeredOn(FlarumForum forum) => forum.extensions.messages || forum.extensions.byobu;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

enum _Kind { messages, private }

class _MessagesTabState extends State<MessagesTab> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  _Kind _kind = _Kind.messages;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    if (!_forum.isSignedIn) {
      return Scaffold(
        appBar: AppBar(leading: forumDrawerButton(context), title: Text(l10n.messages)),
        body: EmptyStateView(
          icon: Icons.chat_bubble_outline,
          message: l10n.logInToSeeMessages,
          actions: [FilledButton(onPressed: () => logInFirst(context, widget.site), child: Text(l10n.signIn))],
        ),
      );
    }
    final kinds = [
      if (_forum.extensions.messages) _Kind.messages,
      if (_forum.extensions.byobu) _Kind.private,
    ];
    if (!kinds.contains(_kind)) _kind = kinds.first;
    final switcher = kinds.length < 2
        ? null
        : PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: FilterChipBar(
              options: [
                for (final kind in kinds)
                  FilterChipOption(label: kind == _Kind.messages ? l10n.directMessages : l10n.privateDiscussions),
              ],
              selectedIndex: kinds.indexOf(_kind),
              onSelected: (i) => setState(() => _kind = kinds[i]),
            ),
          );
    return switch (_kind) {
      _Kind.messages => DialogsPage(key: const ValueKey('dialogs'), site: widget.site, switcher: switcher),
      _Kind.private => PrivateDiscussionsPage(key: const ValueKey('private'), site: widget.site, switcher: switcher),
    };
  }
}
