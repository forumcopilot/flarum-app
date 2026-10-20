import 'dart:math' as math;

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../account/account_page.dart';
import '../account/log_in_first.dart';
import '../home/home_page.dart';
import '../notifications/notifications_page.dart';
import '../safety/suspended_strip.dart';
import '../safety/terms_page.dart';
import '../tags/tags_page.dart';
import '../../config/app_forum_config.dart';
import 'appearance.dart';

/// The app's top level: the forum's discussions, its tags, the reader's
/// notifications and account, one tab each. Signing in or out starts the other tabs afresh.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.site, this.appearance, this.onSwitchForum});

  final SiteContext site;

  /// The app's light or dark choice, on the Account tab; null when a host offers it elsewhere.
  final Appearance? appearance;

  /// Restarts the app on another forum; offered in debug builds only.
  final Future<void> Function(AppForumConfig forum)? onSwitchForum;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  int _tab = 0;

  /// Bumped on sign-in and sign-out, so the lists reload as the new reader.
  int _session = 0;

  /// The tabs opened so far. A tab is built on its first visit: listing the
  /// notifications resets the reader's "new" badge on the website, so that
  /// mustn't happen just because the app started.
  final Set<int> _visited = {0};

  /// Coming back to Notifications loads the list again ([NotificationsPage.visit]).
  int _notificationsVisit = 0;

  void _select(int tab) {
    setState(() {
      if (tab == _notificationsTab && tab != _tab && _visited.contains(tab)) _notificationsVisit++;
      _tab = tab;
      _visited.add(tab);
    });
    // The badge's count comes from the forum's info; read it again after a
    // look at the notifications.
    if (tab == _notificationsTab) _refreshBadge();
  }

  /// Reads the forum's info again for the badge's unread count.
  void _refreshBadge() {
    if (!_forum.isSignedIn) return;
    _forum.refresh().then((_) => mounted ? setState(() {}) : null, onError: (_) {});
  }

  /// The Notifications list's unread rows, once it has loaded, and the forum's count when the two
  /// last agreed: the forum lists two likes of a post as one notification but counts both, so the
  /// badge goes by the list, plus whatever the forum has counted since.
  int? _listUnread;
  int? _forumAtSync;

  void _unreadShown(int? unread, {required bool settled}) {
    setState(() => _listUnread = unread);
    if (!settled || unread == null || !_forum.isSignedIn) return;
    _forum.refresh().then(
      (info) => mounted ? setState(() => _forumAtSync = info.actor?.unreadNotificationCount ?? 0) : null,
      onError: (_) {},
    );
  }

  int _badge(int forumUnread) {
    final list = _listUnread;
    final atSync = _forumAtSync;
    if (list == null || atSync == null) return forumUnread;
    return list + math.max(0, forumUnread - atSync);
  }

  @override
  void initState() {
    super.initState();
    ForumSession.changesOf(widget.site).addListener(_signedInOrOut);
  }

  @override
  void dispose() {
    ForumSession.changesOf(widget.site).removeListener(_signedInOrOut);
    super.dispose();
  }

  /// A Log In or Log Out anywhere in the forum ([ForumSession]): the lists load again as the new
  /// reader.
  void _signedInOrOut() => setState(() {
        _listUnread = null;
        _forumAtSync = null;
        _session++;
        _visited
          ..clear()
          ..addAll({0, _tab});
      });

  static const _notificationsTab = 2;

  /// The forum's updated policies (fof/terms): once they're accepted, the lists reload with the
  /// reader's permissions back.
  Future<void> _reviewTerms() async {
    if (!await TermsPage.open(context, widget.site) || !mounted) return;
    SnackbarHelper.showInfo(context, flarumL10n(context).termsAccepted);
    _signedInOrOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final unread = _forum.isSignedIn ? _badge(_forum.info?.actor?.unreadNotificationCount ?? 0) : 0;
    Widget tab(int index, Widget Function() page) => _visited.contains(index) ? page() : const SizedBox.shrink();
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          tab(0, () => HomePage(key: ValueKey(('home', _session)), site: widget.site, title: widget.site.site.name)),
          tab(1, () => TagsPage(key: ValueKey(('tags', _session)), site: widget.site)),
          tab(2, () => NotificationsPage(
                key: ValueKey(('notifications', _session)),
                site: widget.site,
                onUnreadShown: _unreadShown,
                visit: _notificationsVisit,
              )),
          tab(3, () => AccountPage(
                site: widget.site,
                appearance: widget.appearance,
                onSwitchForum: widget.onSwitchForum,
              )),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_forum.isSignedIn && (_forum.info?.actor?.isSuspended ?? false))
            SuspendedStrip(reader: _forum.info!.actor!),
          if (_forum.isSignedIn && (_forum.info?.policiesToAccept.isNotEmpty ?? false))
            TermsStrip(onReview: _reviewTerms),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: _select,
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.forum_outlined), selectedIcon: const Icon(Icons.forum), label: l10n.home),
              NavigationDestination(
                  icon: const Icon(Icons.sell_outlined), selectedIcon: const Icon(Icons.sell), label: l10n.tags),
              NavigationDestination(
                  icon: Badge(
                      isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications_none)),
                  selectedIcon:
                      Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications)),
                  label: l10n.notifications),
              NavigationDestination(
                  icon: const Icon(Icons.account_circle_outlined),
                  selectedIcon: const Icon(Icons.account_circle),
                  label: l10n.account),
            ],
          ),
        ],
      ),
    );
  }
}
