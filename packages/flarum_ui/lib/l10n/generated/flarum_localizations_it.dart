// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlarumLocalizationsIt extends FlarumLocalizations {
  FlarumLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get attachmentDefaultName => 'Allegato';

  @override
  String get share => 'Condividi';

  @override
  String get cancel => 'Annulla';

  @override
  String downloading(String filename) {
    return 'Download di $filename...';
  }

  @override
  String get download => 'Scarica';

  @override
  String errorDownloading(String filename, String error) {
    return 'Errore nel download di $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'Visualizza sul Web';

  @override
  String get mediaPause => 'Pausa';

  @override
  String get mediaPlay => 'Riproduci';

  @override
  String get failedToLoadVideo => 'Impossibile caricare il video';

  @override
  String get close => 'Chiudi';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Immagine';

  @override
  String get fileTypeArchive => 'Archivio';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'File';

  @override
  String get fileTypeText => 'Testo';

  @override
  String get retry => 'Riprova';

  @override
  String get edited => 'modificato';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risposte',
      one: '1 risposta',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mi piace',
      one: '1 mi piace',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'Carica altro';

  @override
  String viewProfileOfUser(String username) {
    return 'Vedi il profilo di $username';
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

  @override
  String get latest => 'Recenti';

  @override
  String get unread => 'Non letti';

  @override
  String get search => 'Cerca';

  @override
  String get signIn => 'Accedi';

  @override
  String get profile => 'Profilo';

  @override
  String get following => 'Seguiti';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifiche';

  @override
  String get settings => 'Impostazioni';

  @override
  String get tags => 'Tag';

  @override
  String get filterTop => 'Top';

  @override
  String get viewNewest => 'Newest';

  @override
  String discussionReplied(String user, String time) {
    return '$user replied $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user started $time';
  }

  @override
  String get noDiscussions => 'No discussions here yet.';

  @override
  String get discussionsLoadFailed => 'Couldn\'t load discussions.';
}
