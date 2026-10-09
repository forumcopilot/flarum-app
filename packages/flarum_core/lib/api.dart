/// Flarum's REST API, without Flutter: the client, JSON:API documents and models.
///
/// Plain Dart on purpose: tool/record_fixtures.dart runs it with `dart run`.
/// Code that needs Flutter (the forumcopilot_sdk proxies) stays out of here.
library;

export 'src/attributes.dart';
export 'src/flarum_api.dart';
export 'src/flarum_client.dart';
export 'src/flarum_exception.dart';
export 'src/json_api.dart';
export 'src/models/discussion.dart';
export 'src/models/forum_info.dart';
export 'src/models/notification.dart';
export 'src/models/post.dart';
export 'src/models/tag.dart';
export 'src/models/user.dart';
