import '../attributes.dart';
import '../json_api.dart';

/// A flarum/tags tag. Primary tags form the forum's two-level tree (shown as
/// categories); secondary tags have no position and act as labels.
class FlarumTag {
  const FlarumTag({
    required this.id,
    required this.name,
    required this.slug,
    required this.isPrimary,
    this.color,
    this.icon,
    this.position,
    this.isChild = false,
    this.parentId,
    this.description,
    this.discussionCount = 0,
    this.lastPostedAt,
    this.canStartDiscussion = false,
    this.isHidden = false,
    this.subscription,
  });

  factory FlarumTag.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    final position = a.integer('position');
    return FlarumTag(
      id: resource.id,
      name: a.string('name') ?? '',
      slug: a.string('slug') ?? '',
      // 2.0 sends isPrimary; on 1.x a tag is primary exactly when it has a position.
      isPrimary: a.boolean('isPrimary') ?? position != null,
      color: a.nonEmptyString('color'),
      icon: a.nonEmptyString('icon'),
      position: position,
      isChild: a.boolean('isChild') ?? false,
      parentId: resource.toOne('parent')?.id,
      description: a.nonEmptyString('description'),
      discussionCount: a.integer('discussionCount') ?? 0,
      lastPostedAt: a.date('lastPostedAt'),
      canStartDiscussion: a.boolean('canStartDiscussion') ?? false,
      isHidden: a.boolean('isHidden') ?? false,
      subscription: a.nonEmptyString('subscription'),
    );
  }

  final String id;
  final String name;
  final String slug;
  final bool isPrimary;

  /// Hex colour such as `#e67e22`, if the tag has one.
  final String? color;

  /// Font Awesome classes such as `fas fa-life-ring`, if the tag has an icon.
  final String? icon;
  final int? position;
  final bool isChild;

  /// The parent tag's id; known only when the request included `parent`.
  final String? parentId;

  final String? description;
  final int discussionCount;
  final DateTime? lastPostedAt;

  /// Whether the reader may start a discussion here.
  final bool canStartDiscussion;

  /// Hidden tags keep their discussions out of All Discussions.
  final bool isHidden;

  /// fof/follow-tags state for the reader: `follow`, `lurk`, `ignore`, `hide`, or null.
  final String? subscription;
}
