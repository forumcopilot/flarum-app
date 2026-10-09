// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class FlarumLocalizationsNl extends FlarumLocalizations {
  FlarumLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get attachmentDefaultName => 'Bijlage';

  @override
  String get share => 'Delen';

  @override
  String get cancel => 'Annuleren';

  @override
  String downloading(String filename) {
    return 'Downloaden $filename...';
  }

  @override
  String get download => 'Downloaden';

  @override
  String errorDownloading(String filename, String error) {
    return 'Fout bij downloaden $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'Bekijken op web';

  @override
  String get mediaPause => 'Pauzeren';

  @override
  String get mediaPlay => 'Afspelen';

  @override
  String get failedToLoadVideo => 'Video laden mislukt';

  @override
  String get close => 'Sluiten';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Afbeelding';

  @override
  String get fileTypeArchive => 'Archief';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'Bestand';

  @override
  String get fileTypeText => 'Tekst';

  @override
  String get retry => 'Opnieuw';

  @override
  String get edited => 'bewerkt';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count antwoorden',
      one: '1 antwoord',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'Meer laden';

  @override
  String viewProfileOfUser(String username) {
    return 'Profiel van $username bekijken';
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
  String get latest => 'Nieuwste';

  @override
  String get unread => 'Ongelezen';

  @override
  String get search => 'Zoeken';

  @override
  String get signIn => 'Inloggen';

  @override
  String get profile => 'Profiel';

  @override
  String get following => 'Volgend';

  @override
  String get home => 'Start';

  @override
  String get notifications => 'Meldingen';

  @override
  String get settings => 'Instellingen';

  @override
  String get tags => 'Tags';

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
