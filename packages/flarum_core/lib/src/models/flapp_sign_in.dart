import '../attributes.dart';

/// What a forum running the Flapp extension (forumcopilot/flarum-flapp) announces on `GET /api` as
/// `flappSignIn`: the page where a member lets the app sign in through the forum, in the phone's
/// browser, so the forum's own log-in, sign-up and OAuth buttons work there (Google's refuses an
/// app's web view). Announced whenever the extension is on, connected to the relay or not.
class FlappSignInInfo {
  const FlappSignInInfo({required this.authorizeUrl, required this.version});

  /// The forum's announcement, or null when it makes none.
  static FlappSignInInfo? fromAttributes(Map<String, dynamic> attributes) {
    final value = attributes['flappSignIn'];
    if (value is! Map) return null;
    final signIn = value.cast<String, dynamic>();
    final url = Uri.tryParse(signIn.nonEmptyString('authorizeUrl') ?? '');
    if (url == null || !(url.isScheme('https') || url.isScheme('http'))) return null;
    return FlappSignInInfo(authorizeUrl: url, version: signIn.integer('version') ?? 1);
  }

  /// The forum's `/flapp/authorize` page.
  final Uri authorizeUrl;

  final int version;
}
