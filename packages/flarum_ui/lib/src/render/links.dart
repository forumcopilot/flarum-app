import 'package:flutter/widgets.dart' show BuildContext, Rect, debugPrint;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/flarum_host.dart';

/// Opens [url] outside the app: in the browser, or the app that owns it.
Future<void> openExternally(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('openExternally: $e');
  }
}

/// Opens a link from a post or message that leads off its forum: in the host's app when it's
/// another forum the host opens ([FlarumHost.openOtherForumLink]), else outside the app.
Future<void> openPostLink(BuildContext context, String url) async {
  try {
    if (await FlarumHost.openOtherForumLink?.call(context, url) ?? false) return;
  } catch (e) {
    debugPrint('openPostLink: $e');
  }
  await openExternally(url);
}

/// Offers [url] to the system share sheet. [origin] is where an iPad points
/// the sheet from.
Future<void> shareLink(String url, {Rect? origin}) async {
  try {
    await SharePlus.instance.share(ShareParams(text: url, sharePositionOrigin: origin));
  } catch (e) {
    debugPrint('shareLink: $e');
  }
}
