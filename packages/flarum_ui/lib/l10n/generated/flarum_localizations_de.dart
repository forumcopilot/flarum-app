// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FlarumLocalizationsDe extends FlarumLocalizations {
  FlarumLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get attachmentDefaultName => 'Anhang';

  @override
  String get share => 'Teilen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String downloading(String filename) {
    return 'Lade $filename herunter...';
  }

  @override
  String get download => 'Herunterladen';

  @override
  String errorDownloading(String filename, String error) {
    return 'Fehler beim Herunterladen von $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'Im Web anzeigen';

  @override
  String get mediaPause => 'Pausieren';

  @override
  String get mediaPlay => 'Abspielen';

  @override
  String get failedToLoadVideo => 'Video konnte nicht geladen werden';

  @override
  String get close => 'Schließen';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Bild';

  @override
  String get fileTypeArchive => 'Archiv';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'Datei';

  @override
  String get fileTypeText => 'Text';

  @override
  String get retry => 'Wiederholen';

  @override
  String get edited => 'bearbeitet';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Antworten',
      one: '1 Antwort',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Likes',
      one: '1 Like',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'Mehr laden';

  @override
  String viewProfileOfUser(String username) {
    return 'Profil von $username ansehen';
  }

  @override
  String get loadEarlierPosts => 'Load earlier posts';

  @override
  String get postHidden => 'This post was deleted.';

  @override
  String get threadLoadFailed => 'Couldn\'t load this discussion.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user changed the title from “$from” to “$to”.';
  }

  @override
  String eventLocked(String user) {
    return '$user locked the discussion.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user unlocked the discussion.';
  }

  @override
  String eventStickied(String user) {
    return '$user stickied the discussion.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user unstickied the discussion.';
  }

  @override
  String eventTagged(String user) {
    return '$user changed the tags.';
  }

  @override
  String eventOther(String user) {
    return '$user changed the discussion.';
  }

  @override
  String get someone => 'Someone';
}
