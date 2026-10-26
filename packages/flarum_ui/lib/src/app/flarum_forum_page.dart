import 'dart:async';

import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../messages/dialog_page.dart';
import '../navigation/forum_links.dart';
import '../profile/user_page.dart';
import '../tags/tags_page.dart';
import '../thread/thread_page.dart';
import 'app_shell.dart';
import 'appearance.dart';
import 'forum_theme.dart';

/// One forum, opened by an app that holds many (see [FlarumHost]): its tabs
/// ([AppShell]) once the forum has answered, in the forum's colours.
///
/// Pushed over the host's own screens, so Back and the edge swipe return
/// there, and each tab's top bar has a back arrow to them. The forum's
/// colours are on the app while it is open ([FlarumForumTheme]); this page
/// wears them from its first frame, before that change lands.
class FlarumForumPage extends StatefulWidget {
  const FlarumForumPage({super.key, required this.site, this.link, this.notificationId, this.appearance});

  /// The forum ([FlarumHost.site]).
  final Site site;

  /// Where to take the reader once the forum is open: a discussion, a
  /// profile or a tag, over the forum's home, so Back lands there. Null
  /// opens the home.
  final ForumLink? link;

  /// The forum's notification the reader tapped in the system's tray (a push), marked read once
  /// the forum is open, as tapping it on the website does.
  final String? notificationId;

  /// The app's light or dark choice, offered on the Account tab. Null when
  /// the host offers it on its own screens: it is the app's setting, not
  /// the forum's.
  final Appearance? appearance;

  /// Connects to [site]: picks up the reader's sign-in from an earlier
  /// launch, reads the forum, and records its colours. Offline or with the
  /// forum down, it returns all the same: the screens say so and retry. In an
  /// app with push ([FlarumPush]), it also registers the phone with a forum
  /// that runs the Flapp extension, once a run, without waiting for it.
  static Future<SiteContext> connect(Site site) async {
    final forum = FlarumForum.forUrl(site.pluginUrl);
    try {
      await forum.restoreSession();
      _restored.add(forum.baseUrl);
      await FlarumForumTheme.update(site.pluginUrl, flarumPalette(await forum.current()));
      unawaited(FlarumPush.registerQuietly(forum));
    } catch (_) {
      // Offline or the forum is down.
    }
    return _contextFor(site);
  }

  /// Forums whose sign-in has been picked up this run.
  static final _restored = <String>{};

  /// Whether [site] was connected earlier this run: its sign-in and info are in hand, so it opens
  /// at once.
  static bool _connected(Site site) {
    final forum = FlarumForum.forUrl(site.pluginUrl);
    return _restored.contains(forum.baseUrl) && forum.info != null;
  }

  static SiteContext _contextFor(Site site) {
    final context = SiteContext(siteType: FlarumProxyFactory.siteType, site: site);
    SiteProxyFactory.initialize(context);
    if (FlarumForum.of(context).info case final info? when info.actor != null) {
      context.setLoginData(FlarumUserProxy.loginResult(info));
    }
    return context;
  }

  @override
  State<FlarumForumPage> createState() => _FlarumForumPageState();
}

class _FlarumForumPageState extends State<FlarumForumPage> {
  late final String _url = widget.site.pluginUrl;
  SiteContext? _site;

  @override
  void initState() {
    super.initState();
    FlarumForumTheme.enter(_url);
    if (FlarumForumPage._connected(widget.site)) {
      _opened(_site = FlarumForumPage._contextFor(widget.site));
    } else {
      _connect();
    }
  }

  @override
  void dispose() {
    FlarumForumTheme.leave(_url);
    super.dispose();
  }

  Future<void> _connect() async {
    final site = await FlarumForumPage.connect(widget.site);
    if (!mounted) return;
    setState(() => _site = site);
    _opened(site);
  }

  /// Takes the reader to [FlarumForumPage.link], once the home is built under it.
  void _opened(SiteContext site) {
    final forum = FlarumForum.of(site);
    if (widget.notificationId case final id? when forum.isSignedIn) {
      forum.api.markNotificationRead(id).ignore();
    }
    if (widget.link case final link?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open(link, site);
      });
    }
  }

  void _open(ForumLink link, SiteContext site) {
    switch (link) {
      case DiscussionLink(:final id, :final number):
        ThreadPage.open(context, site, id, near: number);
      case UserLink(:final slug):
        UserPage.open(context, site, slug);
      case TagLink(:final slug):
        TagPage.openBySlug(context, site, slug);
      case DialogLink(:final id):
        DialogPage.open(context, site, dialogId: id);
      case UserIdLink(:final id):
        _openUser(id, site);
    }
  }

  /// A user's profile, found by id: [UserPage] goes by the slug, which the forum knows.
  Future<void> _openUser(String id, SiteContext site) async {
    try {
      final user = await FlarumForum.of(site).api.user(id);
      if (mounted) await UserPage.open(context, site, user.slug ?? user.username);
    } on FlarumApiException {
      // Deleted since, or hidden: the forum's home is where the reader stays.
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FlarumForumTheme.paletteFor(_url);
    final theme = Theme.of(context);
    return Theme(
      data: palette == null ? theme : AppTheme.themeFor(theme.brightness, palette),
      child: switch (_site) {
        final site? => AppShell(site: site, appearance: widget.appearance),
        null => _Connecting(name: widget.site.name),
      },
    );
  }
}

/// The forum's name and a spinner while it answers: a moment for a forum
/// opened before in this run, longer on a first visit.
class _Connecting extends StatelessWidget {
  const _Connecting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(name)),
        body: const Center(child: CircularProgressIndicator()),
      );
}
