import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../render/links.dart';

/// The web addresses of a forum's pages, as Flarum links them: to share or copy, so they open on
/// the forum's website, or in an app that reads Flarum links.
abstract final class WebLinks {
  /// A discussion, at post [near] when it's past the first. Flarum's [slug] is already the whole
  /// path segment, its id included (`3-welcome-to-the-forum`); one without the id gets it.
  static String discussion(SiteContext site, String id, {String? slug, int? near}) {
    final segment = slug == null || slug.isEmpty
        ? id
        : slug == id || slug.startsWith('$id-')
            ? slug
            : '$id-$slug';
    return '${_base(site)}/d/$segment${near == null || near <= 1 ? '' : '/$near'}';
  }

  static String user(SiteContext site, FlarumUser user) => '${_base(site)}/u/${user.slug ?? user.username}';

  static String _base(SiteContext site) => site.site.url.replaceAll(RegExp(r'/+$'), '');
}

/// Puts [url] on the clipboard, and says so.
Future<void> copyLink(BuildContext context, String url) async {
  await Clipboard.setData(ClipboardData(text: url));
  if (context.mounted) SnackbarHelper.showInfo(context, flarumL10n(context).linkCopied);
}

/// Offers [url] to the share sheet, pointed (on an iPad) from the widget at [context].
Future<void> shareFrom(BuildContext context, String url) {
  final box = context.findRenderObject();
  return shareLink(url, origin: box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null);
}
