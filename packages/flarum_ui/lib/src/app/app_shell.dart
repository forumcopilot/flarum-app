import 'dart:math' as math;

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import 'package:forum_kit/views/widgets/drawer_introduction.dart';

import '../account/account_page.dart';
import '../account/log_in_first.dart';
import '../home/home_page.dart';
import '../messages/messages_tab.dart';
import '../notifications/notifications_page.dart';
import '../safety/suspended_strip.dart';
import '../safety/terms_page.dart';
import 'forum_drawer.dart';
import '../../config/app_forum_config.dart';
import 'appearance.dart';

/// The forum's tabs, as the Discourse app has them: Home (its discussions and tags), Messages
/// (where the forum has them), the reader's notifications, and their profile; and the forum's
/// drawer, its map. Signing in or out starts the other tabs afresh.
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

/// A tab of the forum's.
enum ShellTab { home, messages, notifications, profile }

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  final _scaffold = GlobalKey<ScaffoldState>();
  ShellTab _tab = ShellTab.home;

  /// Whether the drawer opened by itself, to introduce itself ([DrawerIntroduction]).
  bool _introducingDrawer = false;

  /// Whether the drawer is open: Back closes it first.
  bool _drawerOpen = false;

  /// The tabs this forum has: Messages only where it runs flarum/messages or fof/byobu.
  List<ShellTab> get _tabs => [
        ShellTab.home,
        if (MessagesTab.offeredOn(_forum)) ShellTab.messages,
        ShellTab.notifications,
        ShellTab.profile,
      ];

  /// Bumped on sign-in and sign-out, so the lists reload as the new reader.
  int _session = 0;

  /// The tabs opened so far. A tab is built on its first visit: listing the
  /// notifications resets the reader's "new" badge on the website, so that
  /// mustn't happen just because the app started.
  final Set<ShellTab> _visited = {ShellTab.home};

  /// Coming back to Notifications loads the list again ([NotificationsPage.visit]).
  int _notificationsVisit = 0;

  void _select(ShellTab tab) {
    setState(() {
      if (tab == ShellTab.notifications && tab != _tab && _visited.contains(tab)) _notificationsVisit++;
      _tab = tab;
      _visited.add(tab);
    });
    // The badges' counts come from the forum's info: read it again at each tab, as the web reads
    // its counts again on each page.
    _refreshBadge();
  }

  /// Reads the forum's info again for the badges' unread counts ([_infoChanged] redraws them).
  void _refreshBadge() {
    if (!_forum.isSignedIn) return;
    _forum.refresh().ignore();
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
    WidgetsBinding.instance.addObserver(this);
    ForumSession.changesOf(widget.site).addListener(_signedInOrOut);
    // Read again anywhere (a conversation read, a page's refresh): the badges follow.
    _forum.infoChanges.addListener(_infoChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ForumSession.changesOf(widget.site).removeListener(_signedInOrOut);
    _forum.infoChanges.removeListener(_infoChanged);
    super.dispose();
  }

  void _infoChanged() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _infoChanged());
      return;
    }
    setState(() {});
  }

  /// Back in front: what came while the app was away (a message, a notification) shows.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshBadge();
  }

  /// A Log In or Log Out anywhere in the forum ([ForumSession]): the lists load again as the new
  /// reader.
  void _signedInOrOut() => setState(() {
        _listUnread = null;
        _forumAtSync = null;
        _session++;
        _visited
          ..clear()
          ..addAll({ShellTab.home, _tab});
      });

  /// The forum's updated policies (fof/terms): once they're accepted, the lists reload with the
  /// reader's permissions back.
  Future<void> _reviewTerms() async {
    if (!await TermsPage.open(context, widget.site) || !mounted) return;
    SnackbarHelper.showInfo(context, flarumL10n(context).termsAccepted);
    _signedInOrOut();
  }

  /// Where the drawer's edge starts: past the strip Android's gesture navigation keeps for its own
  /// Back, which from a root forum would close the app.
  double _drawerEdgeDragWidth(BuildContext context) => MediaQuery.systemGestureInsetsOf(context).left + 20;

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final unread = _forum.isSignedIn ? _badge(_forum.info?.actor?.unreadNotificationCount ?? 0) : 0;
    final messages = _forum.isSignedIn ? (_forum.info?.unreadDialogCount ?? 0) : 0;
    final tabs = _tabs;
    // A tab the forum no longer has (Messages, after logging out of a forum with only
    // flarum/messages): back to Home.
    if (!tabs.contains(_tab)) _tab = ShellTab.home;
    // Pushed over a host's forum list (Flapp), rather than the app's root.
    final hosted = ModalRoute.canPopOf(context) ?? false;
    Widget page(ShellTab tab) {
      if (!_visited.contains(tab)) return const SizedBox.shrink();
      return switch (tab) {
        ShellTab.home => HomePage(key: ValueKey(('home', _session)), site: widget.site, title: widget.site.site.name),
        ShellTab.messages => MessagesTab(key: ValueKey(('messages', _session)), site: widget.site),
        ShellTab.notifications => NotificationsPage(
            key: ValueKey(('notifications', _session)),
            site: widget.site,
            onUnreadShown: _unreadShown,
            visit: _notificationsVisit,
          ),
        ShellTab.profile => AccountPage(
            site: widget.site,
            appearance: widget.appearance,
            onSwitchForum: widget.onSwitchForum,
          ),
      };
    }

    NavigationDestination destination(ShellTab tab) => switch (tab) {
          ShellTab.home =>
            NavigationDestination(icon: const Icon(Icons.forum_outlined), selectedIcon: const Icon(Icons.forum), label: l10n.home),
          ShellTab.messages => NavigationDestination(
              icon: Badge(
                  isLabelVisible: messages > 0, label: Text('$messages'), child: const Icon(Icons.chat_bubble_outline)),
              selectedIcon:
                  Badge(isLabelVisible: messages > 0, label: Text('$messages'), child: const Icon(Icons.chat_bubble)),
              label: l10n.messages),
          ShellTab.notifications => NavigationDestination(
              icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications_none)),
              selectedIcon:
                  Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.notifications)),
              label: l10n.notifications),
          ShellTab.profile => NavigationDestination(
              icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l10n.profile),
        };

    // Back closes the drawer, then goes to Home, then out of the forum. The drawer is said
    // explicitly: on the app's first route, Android leaves the app on Back unless the app says it
    // takes it, and an open drawer alone didn't say so.
    return PopScope(
      canPop: _tab == ShellTab.home && !_drawerOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_drawerOpen) {
          _scaffold.currentState?.closeDrawer();
        } else {
          _select(ShellTab.home);
        }
      },
      child: Scaffold(
        key: _scaffold,
        onDrawerChanged: (open) {
          setState(() {
            _drawerOpen = open;
            if (!open) _introducingDrawer = false;
          });
          // Opened by the reader: found, so it never opens by itself.
          if (open) DrawerIntroduction.markSeen();
        },
        drawer: ForumDrawer(
          site: widget.site,
          homeIsCurrent: _tab == ShellTab.home,
          onHome: () => _select(ShellTab.home),
          onProfile: () => _select(ShellTab.profile),
          introduction: _introducingDrawer,
        ),
        // Pushed over a host's forum list, the left edge means Back (iOS's swipe, Android's gesture),
        // so there the drawer opens from ☰ only, and shows itself once so the button is known. A root
        // forum has nothing behind it: its edge opens the drawer.
        drawerEnableOpenDragGesture: !hosted,
        drawerEdgeDragWidth: _drawerEdgeDragWidth(context),
        body: ForumDrawerScope(
          open: () => _scaffold.currentState?.openDrawer(),
          child: DrawerIntroduction(
            enabled: hosted,
            onIntroduce: () => setState(() => _introducingDrawer = true),
            child: IndexedStack(index: tabs.indexOf(_tab), children: [for (final tab in tabs) page(tab)]),
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_forum.isSignedIn && (_forum.info?.actor?.isSuspended ?? false))
              SuspendedStrip(reader: _forum.info!.actor!),
            if (_forum.isSignedIn && (_forum.info?.policiesToAccept.isNotEmpty ?? false))
              TermsStrip(onReview: _reviewTerms),
            // One line per label, cut short: a long word ("Benachrichtigungen") at a large text size
            // broke mid-word onto a second line.
            DefaultTextStyle.merge(
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              child: NavigationBar(
                selectedIndex: tabs.indexOf(_tab),
                onDestinationSelected: (i) => _select(tabs[i]),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [for (final tab in tabs) destination(tab)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
