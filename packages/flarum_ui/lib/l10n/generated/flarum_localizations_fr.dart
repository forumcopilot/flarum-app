// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlarumLocalizationsFr extends FlarumLocalizations {
  FlarumLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get attachmentDefaultName => 'Pièce jointe';

  @override
  String get share => 'Partager';

  @override
  String get cancel => 'Annuler';

  @override
  String downloading(String filename) {
    return 'Téléchargement de $filename...';
  }

  @override
  String get download => 'Télécharger';

  @override
  String errorDownloading(String filename, String error) {
    return 'Erreur lors du téléchargement de $filename : $error';
  }

  @override
  String get video => 'Vidéo';

  @override
  String get viewOnWeb => 'Voir sur le Web';

  @override
  String get mediaPause => 'Mettre en pause';

  @override
  String get mediaPlay => 'Lire';

  @override
  String get failedToLoadVideo => 'Impossible de charger la vidéo';

  @override
  String get close => 'Fermer';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Image';

  @override
  String get fileTypeArchive => 'Archive';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'Fichier';

  @override
  String get fileTypeText => 'Texte';

  @override
  String get retry => 'Réessayer';

  @override
  String get edited => 'modifié';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '1 réponse',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count j’aime',
      one: '1 j’aime',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'Charger plus';

  @override
  String viewProfileOfUser(String username) {
    return 'Voir le profil de $username';
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
  String get latest => 'Récent';

  @override
  String get unread => 'Non lu';

  @override
  String get search => 'Rechercher';

  @override
  String get signIn => 'Se connecter';

  @override
  String get profile => 'Profil';

  @override
  String get following => 'Abonnements';

  @override
  String get home => 'Accueil';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Paramètres';

  @override
  String get tags => 'Étiquettes';

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
