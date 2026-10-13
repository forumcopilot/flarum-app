import '../attributes.dart';
import '../json_api.dart';

/// A file uploaded through fof/upload, and the BBCode that puts it in a post: an image preview,
/// or a download card for any other file.
class FlarumUpload {
  const FlarumUpload({
    required this.uuid,
    required this.url,
    required this.baseName,
    required this.bbcode,
    this.type,
    this.size,
    this.canDelete = false,
  });

  factory FlarumUpload.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    final baseName = a.string('baseName') ?? '';
    return FlarumUpload(
      uuid: a.string('uuid') ?? resource.id,
      url: a.string('url') ?? '',
      baseName: baseName,
      // 1.x's image template leaves the alt text as its {TEXT?} placeholder (2.0 fills in the name).
      bbcode: (a.string('bbcode') ?? '').replaceAll('alt={TEXT?}', 'alt="${baseName.replaceAll('"', '')}"'),
      type: a.nonEmptyString('type'),
      size: a.integer('size'),
      canDelete: a.boolean('canDelete') ?? false,
    );
  }

  final String uuid;
  final String url;

  /// The name it was uploaded with.
  final String baseName;

  /// What to put in the post where the file goes.
  final String bbcode;

  /// Its media type, e.g. `image/png`.
  final String? type;

  /// Its size in bytes.
  final int? size;

  /// Whether the reader may delete it (fof/upload lets only moderators by default).
  final bool canDelete;
}
