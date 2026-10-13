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
  String get loadEarlierPosts => 'Charger les messages précédents';

  @override
  String get postHidden => 'Ce message a été supprimé.';

  @override
  String get threadLoadFailed => 'Impossible de charger cette discussion.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user a changé le titre de « $from » en « $to ».';
  }

  @override
  String eventLocked(String user) {
    return '$user a verrouillé la discussion.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user a déverrouillé la discussion.';
  }

  @override
  String eventStickied(String user) {
    return '$user a épinglé la discussion.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user a désépinglé la discussion.';
  }

  @override
  String eventTagged(String user) {
    return '$user a modifié les étiquettes.';
  }

  @override
  String eventOther(String user) {
    return '$user a modifié la discussion.';
  }

  @override
  String get someone => 'Quelqu’un';

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
  String get viewNewest => 'Nouvelles';

  @override
  String discussionReplied(String user, String time) {
    return '$user a répondu $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user a lancé la discussion $time';
  }

  @override
  String get noDiscussions => 'Aucune discussion pour l’instant.';

  @override
  String get discussionsLoadFailed => 'Impossible de charger les discussions.';

  @override
  String get tagsLoadFailed => 'Impossible de charger les étiquettes.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get account => 'Compte';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String signInFailedReason(String reason) {
    return 'Connexion impossible : $reason';
  }

  @override
  String get signInHint =>
      'Connectez-vous sur la page du forum. L’application vous garde connecté jusqu’à ce que vous vous déconnectiez.';

  @override
  String signedInAs(String name) {
    return 'Connecté en tant que $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Toutes les notifications marquées comme lues';

  @override
  String get failedToMarkNotificationsRead =>
      'Impossible de marquer les notifications comme lues';

  @override
  String get noNotificationsYet => 'Aucune notification pour l\'instant';

  @override
  String notifNewPost(String user, String title) {
    return '$user a répondu dans $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user a aimé votre message dans $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user a réagi à votre message dans $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user a répondu à votre message dans $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user vous a mentionné dans $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user a mentionné un de vos groupes dans $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user a renommé une discussion en $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user a verrouillé $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user a lancé $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user a déplacé $title dans une étiquette que vous suivez';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user a lancé une discussion privée avec vous : $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user a répondu dans la discussion privée $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user vous a ajouté à la discussion privée $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user vous a retiré de la discussion privée $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user a rendu publique $title';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user a choisi votre message comme meilleure réponse dans $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user a choisi une meilleure réponse dans $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Choisissez une meilleure réponse dans $title';
  }

  @override
  String notifMessage(String user) {
    return '$user vous a envoyé un message';
  }

  @override
  String get notifSuspended => 'Votre compte a été suspendu';

  @override
  String get notifUnsuspended => 'Votre suspension a été levée';

  @override
  String get notifExport => 'Votre export de données est prêt';

  @override
  String get notifOther => 'Nouvelle notification';

  @override
  String get aDiscussion => 'une discussion';

  @override
  String get notificationsLoadFailed =>
      'Impossible de charger vos notifications.';

  @override
  String get notificationsSignIn =>
      'Connectez-vous pour voir vos notifications.';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get posts => 'Messages';

  @override
  String profileJoined(String date) {
    return 'Inscrit en $date';
  }

  @override
  String get discussionsTab => 'Discussions';

  @override
  String lastSeen(String time) {
    return 'Vu $time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions discussions',
      one: '1 discussion',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments messages',
      one: '1 message',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Impossible de charger ce profil.';

  @override
  String get noPostsYet => 'Aucun message pour l’instant.';

  @override
  String searchFailedWithError(String error) {
    return 'Recherche échouée : $error';
  }

  @override
  String get searchHint => 'Rechercher des discussions et des messages';

  @override
  String noResultsFor(String query) {
    return 'Aucun résultat pour « $query ».';
  }

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get appearance => 'Apparence';

  @override
  String get appearanceSystem => 'Système';

  @override
  String repliedByOne(String a) {
    return '$a a répondu à ce message.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a et $b ont répondu à ce message.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others autres',
      one: '1 autre',
    );
    return '$a, $b et $_temp0 ont répondu à ce message.';
  }

  @override
  String get repliesTitle => 'Réponses';

  @override
  String postNumber(int number) {
    return 'Message n° $number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others autres',
      one: '1 autre',
    );
    return '$a et $_temp0 ont répondu à ce message.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user a ajouté $tags.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user a retiré $tags.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user a ajouté $added et retiré $removed.';
  }

  @override
  String get privateDiscussion => 'Discussion privée';

  @override
  String get bestAnswer => 'Meilleure réponse';

  @override
  String get goToBestAnswer => 'Aller à la meilleure réponse';

  @override
  String get answered => 'Résolue';

  @override
  String eventRecipientsChanged(String user) {
    return '$user a modifié les participants de cette discussion privée.';
  }

  @override
  String get noTagsOnForum => 'Ce forum n’utilise pas d’étiquettes.';

  @override
  String get permissionRequired => 'Autorisation requise';

  @override
  String get bold => 'Gras';

  @override
  String get underline => 'Souligné';

  @override
  String get strikethrough => 'Barré';

  @override
  String get bulletList => 'Liste à Puces';

  @override
  String get numberedList => 'Liste Numérotée';

  @override
  String get listItem => 'Élément de Liste';

  @override
  String get mentionUser => 'Mentionner un utilisateur';

  @override
  String get title => 'Titre';

  @override
  String get content => 'Contenu';

  @override
  String get send => 'Envoyer';

  @override
  String get save => 'Enregistrer';

  @override
  String get formatting => 'Formatage';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterContent => 'Veuillez entrer du contenu';

  @override
  String get composerTitleHint => 'Écrivez votre titre...';

  @override
  String get composerContentHint => 'Écrivez votre contenu...';

  @override
  String get composerFormattingHint => 'Ouvrir les options de mise en forme';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get startDiscussion => 'Lancer une discussion';

  @override
  String get editPost => 'Modifier le message';

  @override
  String get postingThrottled =>
      'Vous publiez trop vite. Patientez quelques secondes et réessayez.';

  @override
  String get postAwaitingApproval =>
      'Envoyé. Il apparaîtra dès qu’un modérateur l’aura approuvé.';

  @override
  String get chooseTags => 'Choisir des étiquettes';

  @override
  String get primaryTags => 'Étiquettes principales';

  @override
  String get secondaryTags => 'Autres étiquettes';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choisissez $count étiquettes principales.',
      one: 'Choisissez une étiquette principale.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choisissez au plus $count étiquettes principales.',
      one: 'Choisissez une seule étiquette principale.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choisissez $count étiquettes de plus.',
      one: 'Choisissez 1 étiquette de plus.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choisissez au plus $count autres étiquettes.',
      one: 'Choisissez au plus 1 autre étiquette.',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Terminé';

  @override
  String get noMembersFound => 'Aucun membre trouvé.';

  @override
  String get memberSearchNotAllowed =>
      'Ce forum ne permet pas de rechercher des membres.';

  @override
  String get editLoadFailed =>
      'Impossible de charger ce message pour le modifier.';

  @override
  String get like => 'J’aime';

  @override
  String get unlike => 'Je n’aime plus';

  @override
  String get react => 'Réagir';

  @override
  String get reactions => 'Réactions';

  @override
  String get bookmark => 'Ajouter aux favoris';

  @override
  String get removeBookmark => 'Retirer des favoris';

  @override
  String get bookmarks => 'Favoris';

  @override
  String get noBookmarks => 'Aucun favori pour l’instant.';

  @override
  String get chooseBestAnswer => 'Choisir comme meilleure réponse';

  @override
  String get removeBestAnswer => 'Retirer la meilleure réponse';

  @override
  String get notificationSettings => 'Notifications pour cette discussion';

  @override
  String get notFollowing => 'Pas suivie';

  @override
  String get notFollowingHint => 'Être notifié seulement en cas de @mention.';

  @override
  String get followingHint => 'Être notifié de toutes les réponses.';

  @override
  String get ignoring => 'Ignorée';

  @override
  String get ignoringHint => 'Ne jamais être notifié et la masquer des listes.';

  @override
  String get tagFollowingHint => 'Être notifié des nouvelles discussions.';

  @override
  String get lurking => 'À l’affût';

  @override
  String get lurkingHint =>
      'Être notifié des nouvelles discussions et de chaque réponse.';

  @override
  String get tagIgnoringHint => 'Ne jamais être notifié des discussions d’ici.';

  @override
  String get hidden => 'Masquée';

  @override
  String get hiddenHint =>
      'Masquer les discussions de cette étiquette des listes.';
}
