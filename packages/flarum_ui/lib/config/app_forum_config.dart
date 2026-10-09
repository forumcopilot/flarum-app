import 'package:flarum_core/flarum_core.dart' show FlarumProxyFactory;
import 'package:forumcopilot_sdk/models/domain/site.dart';

/// The forum this build of the app is for: the file a fork edits, as
/// discourse-app's AppForumConfig is.
///
/// Set at build time; nothing here changes at runtime. For a test forum,
/// pass it instead of editing the file, so a local address never reaches the
/// repository:
///
///     flutter run --dart-define=FLARUM_URL=http://192.168.1.20:8082 --dart-define=FLARUM_NAME="Test forum"
class AppForumConfig {
  const AppForumConfig({required this.name, required this.baseUrl});

  /// The forum's name, shown until its own title has loaded.
  final String name;

  /// The forum's address: scheme, host and any folder, no trailing slash.
  final String baseUrl;

  /// This build's forum: `--dart-define`s, else the template's default (the
  /// Flarum community, read as a guest).
  static const AppForumConfig current = AppForumConfig(
    name: String.fromEnvironment('FLARUM_NAME', defaultValue: 'Flarum Community'),
    baseUrl: String.fromEnvironment('FLARUM_URL', defaultValue: 'https://discuss.flarum.org'),
  );

  /// The SDK's description of the forum.
  Site toSite() {
    var url = baseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      throw StateError('AppForumConfig.baseUrl must be an absolute URL, not "$baseUrl"');
    }
    return Site(
      id: null,
      name: name.trim(),
      url: url,
      description: '',
      logoUrl: null,
      backgroundUrl: null,
      endpoint: null,
      baseUrl: url,
      siteType: FlarumProxyFactory.siteType,
      language: null,
    );
  }
}
