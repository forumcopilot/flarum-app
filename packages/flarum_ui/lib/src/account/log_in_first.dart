import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import 'sign_in_page.dart';

/// Who reads each forum changes here. A Log In or Log Out anywhere in a forum (the Account tab, a
/// guest's Reply, Start a Discussion) bumps the forum's counter, and its shell loads its lists
/// again as the new reader.
abstract final class ForumSession {
  static final Map<String, ValueNotifier<int>> _changes = {};

  static ValueListenable<int> changesOf(SiteContext site) => _notifier(site);

  static void changed(SiteContext site) => _notifier(site).value++;

  static ValueNotifier<int> _notifier(SiteContext site) =>
      _changes.putIfAbsent(site.site.pluginUrl, () => ValueNotifier(0));
}

/// Asks a guest to Log In on the forum's own page before something only a member may do, as the
/// web opens its Log In modal there. True once the reader is logged in, with the forum's info
/// (what they may do now) read again.
Future<bool> logInFirst(BuildContext context, SiteContext site) async {
  final forum = FlarumForum.of(site);
  if (forum.isSignedIn) return true;
  if (!await SignInPage.open(context, site)) return false;
  ForumSession.changed(site);
  try {
    await forum.refresh();
  } catch (_) {
    // What they may do is read again where it's needed.
  }
  return forum.isSignedIn;
}
