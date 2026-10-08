import '../attributes.dart';
import '../json_api.dart';
import 'user.dart';

/// The Flarum major version a forum runs.
enum FlarumVersion {
  v1,
  v2;

  /// Detects the version from `GET /api`'s forum attributes. Only 2.0 sends
  /// `colorScheme` (its light/dark setting) and `jsChunksBaseUrl`.
  static FlarumVersion detect(Map<String, dynamic> forumAttributes) =>
      forumAttributes.containsKey('colorScheme') || forumAttributes.containsKey('jsChunksBaseUrl') ? v2 : v1;
}

/// Limits flarum/tags puts on a new discussion's tags.
class FlarumTagRules {
  const FlarumTagRules({
    required this.minPrimary,
    required this.maxPrimary,
    required this.minSecondary,
    required this.maxSecondary,
    this.canBypass = false,
  });

  final int minPrimary;
  final int maxPrimary;
  final int minSecondary;
  final int maxSecondary;

  /// Whether the reader may ignore these limits (moderators, usually).
  final bool canBypass;
}

/// What `GET /api` says about a forum and, when signed in, about the reader.
class FlarumForumInfo {
  const FlarumForumInfo({
    required this.version,
    required this.baseUrl,
    required this.apiUrl,
    required this.title,
    required this.attributes,
    this.description,
    this.primaryColor,
    this.secondaryColor,
    this.colorScheme,
    this.logoUrl,
    this.logoDarkUrl,
    this.faviconUrl,
    this.allowSignUp = false,
    this.tagRules,
    this.actor,
  });

  factory FlarumForumInfo.fromDocument(JsonApiDocument document) {
    final forum = document.single;
    final a = forum.attributes;
    final actor = document.find(forum.toOne('actor'));
    final minPrimary = a.integer('minPrimaryTags');
    return FlarumForumInfo(
      version: FlarumVersion.detect(a),
      baseUrl: a.string('baseUrl') ?? '',
      apiUrl: a.string('apiUrl') ?? '',
      title: a.string('title') ?? '',
      description: a.nonEmptyString('description'),
      primaryColor: a.nonEmptyString('themePrimaryColor'),
      secondaryColor: a.nonEmptyString('themeSecondaryColor'),
      colorScheme: a.nonEmptyString('colorScheme'),
      logoUrl: a.nonEmptyString('logoUrl'),
      logoDarkUrl: a.nonEmptyString('logoDarkModeUrl'),
      faviconUrl: a.nonEmptyString('faviconUrl'),
      allowSignUp: a.boolean('allowSignUp') ?? false,
      tagRules: minPrimary == null
          ? null
          : FlarumTagRules(
              minPrimary: minPrimary,
              maxPrimary: a.integer('maxPrimaryTags') ?? minPrimary,
              minSecondary: a.integer('minSecondaryTags') ?? 0,
              maxSecondary: a.integer('maxSecondaryTags') ?? 0,
              canBypass: a.boolean('canBypassTagCounts') ?? false,
            ),
      actor: actor == null ? null : FlarumUser.fromResource(actor),
      attributes: a,
    );
  }

  final FlarumVersion version;
  final String baseUrl;
  final String apiUrl;
  final String title;
  final String? description;
  final String? primaryColor;
  final String? secondaryColor;

  /// 2.0's appearance setting: `auto`, `light` or `dark`. Null on 1.x.
  final String? colorScheme;
  final String? logoUrl;

  /// 2.0 only.
  final String? logoDarkUrl;
  final String? faviconUrl;
  final bool allowSignUp;

  /// Null when flarum/tags is off.
  final FlarumTagRules? tagRules;

  /// The signed-in reader; null for guests.
  final FlarumUser? actor;

  /// Every forum attribute, including ones extensions add (`fof-upload.canUpload`,
  /// `canStartPrivateDiscussion`…), for detecting what a forum supports.
  final Map<String, dynamic> attributes;

  /// The reader's `can*` permission flags, e.g. `canStartDiscussion`.
  bool can(String permission) => attributes.boolean(permission) ?? false;
}
