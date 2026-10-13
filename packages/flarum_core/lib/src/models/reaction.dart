import '../attributes.dart';
import '../json_api.dart';

/// A reaction a forum offers (fof/reactions): an emoji by its shortcode name, or a Font Awesome
/// icon. The forum sends its set with `GET /api`.
class FlarumReaction {
  const FlarumReaction({required this.id, required this.identifier, this.type = 'emoji', this.display, this.enabled = true});

  factory FlarumReaction.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    return FlarumReaction(
      id: resource.id,
      identifier: a.string('identifier') ?? '',
      type: a.string('type') ?? 'emoji',
      display: a.nonEmptyString('display'),
      enabled: a.boolean('enabled') ?? true,
    );
  }

  final String id;

  /// The emoji's shortcode name (`thumbsup`, `heart`), or the icon's Font Awesome classes.
  final String identifier;

  /// `emoji` or `icon`.
  final String type;

  /// The forum's own label for it, if it set one.
  final String? display;
  final bool enabled;
}
