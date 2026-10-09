/// flarum-app's screens on forum_kit and flarum_core, for Flarum 1.8 and 2.0.
library;

export 'l10n/flarum_l10n.dart';
export 'src/render/attachment_file_card.dart' show AttachmentFileCard;
export 'src/render/embed_cards.dart' show EmbedPreviewCard, PostVideoCard, PostAudioPlayer;
export 'src/render/flarum_content.dart'
    show FlarumContent, PostBodyFallback, installPostBodyErrorFallback, resolveForumUrl;
export 'src/render/flarum_html.dart';
export 'src/render/forum_media.dart' show ForumMediaAuth;
export 'src/render/post_body_extensions.dart' show SpoilerBox;
