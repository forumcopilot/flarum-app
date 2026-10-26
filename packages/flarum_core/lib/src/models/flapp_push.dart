import '../attributes.dart';

/// What a forum running the Flapp extension (forumcopilot/flarum-flapp) announces on `GET /api` as
/// `flappPush`: the relay that hands its pushes to Google and Apple, the forum's id there, and the
/// protocol's version. A forum without the extension, or one not connected yet, announces nothing.
class FlappPushInfo {
  const FlappPushInfo({required this.relay, required this.forumId, required this.version});

  /// The forum's announcement, or null when it makes none.
  static FlappPushInfo? fromAttributes(Map<String, dynamic> attributes) {
    final value = attributes['flappPush'];
    if (value is! Map) return null;
    final push = value.cast<String, dynamic>();
    final relay = push.nonEmptyString('relay');
    final forumId = push.nonEmptyString('forumId');
    if (relay == null || forumId == null) return null;
    return FlappPushInfo(relay: relay, forumId: forumId, version: push.integer('version') ?? 1);
  }

  /// The relay's address, such as `https://push.flarumapp.com`.
  final String relay;

  /// The forum's id on the relay, which a phone asks for a handle under.
  final String forumId;

  final int version;
}
