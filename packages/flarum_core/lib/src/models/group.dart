import '../attributes.dart';
import '../json_api.dart';

/// A user group, as the web badges a member of it on their profile: its name, colour and icon
/// (Admin's red wrench, Mod's blue shield, and the forum's own).
class FlarumGroup {
  const FlarumGroup({
    required this.id,
    required this.nameSingular,
    this.namePlural,
    this.color,
    this.icon,
    this.isHidden = false,
  });

  factory FlarumGroup.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    return FlarumGroup(
      id: resource.id,
      nameSingular: a.nonEmptyString('nameSingular') ?? '',
      namePlural: a.nonEmptyString('namePlural'),
      color: a.nonEmptyString('color'),
      icon: a.nonEmptyString('icon'),
      isHidden: a.boolean('isHidden') ?? false,
    );
  }

  final String id;
  final String nameSingular;
  final String? namePlural;

  /// A CSS colour (`#B72A2A`), or null.
  final String? color;

  /// A Font Awesome icon (`fas fa-wrench`), or null.
  final String? icon;

  /// Hidden groups get no badge, on the web either.
  final bool isHidden;
}
