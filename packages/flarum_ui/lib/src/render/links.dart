import 'package:flutter/widgets.dart' show Rect, debugPrint;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app: in the browser, or the app that owns it.
Future<void> openExternally(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('openExternally: $e');
  }
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
