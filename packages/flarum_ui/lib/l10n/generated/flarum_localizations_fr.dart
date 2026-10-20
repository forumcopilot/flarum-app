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
  String get copyLink => 'Copier le lien';

  @override
  String get linkCopied => 'Lien copié.';

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
  String get edited => 'Modifié';

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
  String get loadMore => 'Charger davantage';

  @override
  String viewProfileOfUser(String username) {
    return 'Voir le profil de $username';
  }

  @override
  String get loadEarlierPosts => 'Charger davantage';

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
  String get someone => '[supprimé]';

  @override
  String get latest => 'Récent';

  @override
  String get unread => 'Non lu';

  @override
  String get search => 'Rechercher';

  @override
  String get signIn => 'Se connecter';

  @override
  String get logInToReply => 'Connectez-vous pour répondre';

  @override
  String get cannotReply => 'Impossible de répondre';

  @override
  String get profile => 'Profil';

  @override
  String get following => 'Abonnements';

  @override
  String get follow => 'Suivre';

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
  String get noDiscussions => 'Il semble qu’il n’y ait aucune discussion ici.';

  @override
  String get discussionsLoadFailed => 'Impossible de charger les discussions.';

  @override
  String get tagsLoadFailed => 'Impossible de charger les étiquettes.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String logOutQuestion(String forum) {
    return 'Êtes-vous sûr de vouloir vous déconnecter de $forum ?';
  }

  @override
  String get account => 'Compte';

  @override
  String get createAccount => 'S’inscrire';

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
  String get noNotificationsYet => 'Aucune notification';

  @override
  String notifNewPost(String user, String title) {
    return '$user a publié un message dans $title';
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
    return '$user a mentionné un groupe dont vous êtes membre dans $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user a renommé le titre de la discussion en $title';
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
    return '$user a modifié l’étiquette de $title';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user a démarré une nouvelle discussion privée avec vous : $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user a publié un message dans une discussion privée dont vous faites partie : $title';
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
    return 'Votre message a été défini comme la meilleure réponse par $user dans $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user a défini la meilleure réponse dans $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Veuillez sélectionner la meilleure réponse dans $title si une réponse a été apportée à votre question';
  }

  @override
  String notifMessage(String user) {
    return '$user vous a envoyé un message';
  }

  @override
  String get notifSuspended => 'Votre compte a été suspendu';

  @override
  String get notifUnsuspended => 'Vous n’êtes plus suspendu';

  @override
  String get notifExport =>
      'Votre exportation de données est maintenant prête à être téléchargée.';

  @override
  String get notifOther => 'Nouvelle notification';

  @override
  String notifLineNewPost(String user) {
    return '$user a publié un message';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user a aimé votre message';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user a réagi à votre message';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user a répondu à votre message';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user vous a mentionné';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user a mentionné un groupe auquel vous êtes membre';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user a modifié le titre';
  }

  @override
  String notifLineLocked(String user) {
    return '$user l’a verrouillée';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user l’a démarrée';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user a modifié l\'étiquette';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user a démarré une nouvelle discussion privée avec vous';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user a publié un message dans une discussion privée à laquelle vous faites partie';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user vous a ajouté à une discussion privée';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user vous a retiré d’une discussion privée';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user a supprimé tous les destinataires et rendu la discussion publique';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Votre message a été défini comme la meilleure réponse par $user';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user a défini la meilleure réponse dans cette discussion';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Veuillez sélectionner la meilleure réponse si une réponse a été apportée à votre question';

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
  String get markAllDiscussionsReadQuestion =>
      'Êtes-vous sûr de vouloir marquer toutes les discussions comme lues ?';

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
  String get noPostsYet => 'Il semble qu’il n’y ait aucun message ici.';

  @override
  String searchFailedWithError(String error) {
    return 'Recherche échouée : $error';
  }

  @override
  String get searchHint => 'Rechercher dans le forum';

  @override
  String noResultsFor(String query) {
    return 'Il semble qu’il n’y ait aucun résultat pour « $query ».';
  }

  @override
  String get light => 'Mode clair';

  @override
  String get dark => 'Mode sombre';

  @override
  String get appearance => 'Thème';

  @override
  String get appearanceSystem => 'Préférences système';

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
  String get repliesTitle => 'Réponses à ce message';

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
  String get goToBestAnswer => 'Voir la meilleure réponse';

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
  String get mentionUser =>
      'Mentionner un utilisateur, un groupe ou un message';

  @override
  String get title => 'Titre';

  @override
  String get content => 'Contenu';

  @override
  String get send => 'Envoyer le message';

  @override
  String get postReply => 'Publier la réponse';

  @override
  String get postDiscussion => 'Publier la discussion';

  @override
  String get postPrivateDiscussion => 'Publier une discussion privée';

  @override
  String get save => 'Enregistrer';

  @override
  String get formatting => 'Formatage';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterContent => 'Veuillez entrer du contenu';

  @override
  String get composerTitleHint => 'Titre de la discussion';

  @override
  String get privateDiscussionTitleHint => 'Titre de la discussion privée';

  @override
  String get composerContentHint => 'Rédigez un message…';

  @override
  String get composerReplyHint => 'Répondre…';

  @override
  String get composerFormattingHint => 'Ouvrir les options de mise en forme';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get startDiscussion => 'Nouvelle discussion';

  @override
  String get editPost => 'Modifier le message';

  @override
  String get postingThrottled =>
      'Vous allez un peu trop vite. Veuillez réessayer dans quelques secondes.';

  @override
  String get postAwaitingApproval =>
      'Envoyé. Il apparaîtra dès qu’un modérateur l’aura approuvé.';

  @override
  String get chooseTags => 'Sélectionner les étiquettes';

  @override
  String get ok => 'Valider';

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
  String get noMembersFound =>
      'Aucun utilisateur correspondant à votre recherche n’a été trouvé.';

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
  String likedByOne(String a) {
    return '$a aime ça.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a et $b aiment ça.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others autres personnes',
      one: '1 autre personne',
    );
    return '$a et $_temp0 aiment ça.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others autres personnes',
      one: '1 autre personne',
    );
    return '$a, $b et $_temp0 aiment ça.';
  }

  @override
  String get likedByYou => 'Vous aimez ça.';

  @override
  String likedByYouAndOne(String a) {
    return 'Vous et $a aimez ça.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others autres personnes',
      one: '1 autre personne',
    );
    return 'Vous, $a et $_temp0 aimez ça.';
  }

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
  String get noBookmarks =>
      'Vous n’avez encore ajouté aucun message à vos favoris.';

  @override
  String get chooseBestAnswer => 'Sélectionner la meilleure réponse';

  @override
  String get removeBestAnswer => 'Désélectionner la meilleure réponse';

  @override
  String get notFollowing => 'Pas abonné';

  @override
  String get notFollowingHint => 'Être notifié seulement en cas de @mention.';

  @override
  String get followingHint => 'Être notifié de toutes les réponses.';

  @override
  String get ignoring => 'Ignorée';

  @override
  String get ignoringHint =>
      'Ne jamais être notifié. Masquer de la liste des discussions.';

  @override
  String get tagFollowingHint =>
      'Être notifié de toutes les nouvelles discussions.';

  @override
  String get lurking => 'À l’affût';

  @override
  String get lurkingHint =>
      'Être notifié de toutes les nouvelles discussions et réponses.';

  @override
  String get tagIgnoringHint => 'Ne jamais être notifié.';

  @override
  String get hidden => 'Masquée';

  @override
  String get hiddenHint =>
      'Masquer les discussions de la page listant toutes les discussions.';

  @override
  String get attachFile => 'Joindre un fichier';

  @override
  String get uploadImage => 'Téléverser une image';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String uploadingFilename(String filename) {
    return 'Téléversement : $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Échec de l’envoi du fichier : $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Veuillez attendre la fin de l’envoi des pièces jointes';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName redimensionné à $size$dimensions pour respecter la limite de $limit.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName : trop volumineux ($size) et impossible à redimensionner. La limite est de $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName fait $fileBytes. Les téléversements de plus de $maxBytes ne sont pas acceptés.';
  }

  @override
  String get flagAction => 'Signaler';

  @override
  String get ignoredUsers => 'Utilisateurs ignorés';

  @override
  String get ignoredUsersEmpty => 'Il semble que vous n’ignoriez personne.';

  @override
  String get flagPostTitle => 'Signaler le message';

  @override
  String get flagReasonOffTopic => 'Hors sujet';

  @override
  String get flagReasonOffTopicText =>
      'Ce message n’a pas de rapport avec la discussion et devrait être déplacé.';

  @override
  String get flagReasonInappropriate => 'Inapproprié';

  @override
  String get flagReasonInappropriateText =>
      'Ce message est offensant, vulgaire ou ne respecte pas les règles de la communauté.';

  @override
  String get flagReasonSpam => 'Spam';

  @override
  String get flagReasonSpamText => 'Ce message est une publicité.';

  @override
  String get flagReasonOther => 'Autre (veuillez préciser)';

  @override
  String get flagDetails => 'Précisions (facultatif)';

  @override
  String get flagDetailsNeeded =>
      'Veuillez donner quelques précisions aux modérateurs.';

  @override
  String get communityGuidelines => 'Règles de la communauté';

  @override
  String get flagSent =>
      'Merci d’avoir signalé ce message. Nos modérateurs vont l’examiner.';

  @override
  String ignoreUser(String name) {
    return 'Ignorer $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return 'Ne plus ignorer $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Êtes-vous sûr de vouloir ignorer $name ?';
  }

  @override
  String ignoredUserPost(String name) {
    return 'Un message de $name, que vous ignorez.';
  }

  @override
  String get showPost => 'Afficher le message';

  @override
  String get ignoredOnThisPhone =>
      'Ce forum ne tient pas de liste d’utilisateurs ignorés : l’app garde la vôtre sur ce téléphone.';

  @override
  String get stopIgnoring => 'Ne plus ignorer';

  @override
  String get termsBanner =>
      'Nous avons temporairement restreint l’accès à votre compte le temps que vous preniez connaissance des nouvelles conditions.';

  @override
  String get termsReview => 'Consulter';

  @override
  String get termsTitle => 'Mise à jour des conditions';

  @override
  String get termsIntro =>
      'Les conditions ont été mises à jour depuis votre dernière visite';

  @override
  String get readPolicy => 'Lire';

  @override
  String get acceptTerms => 'Confirmer';

  @override
  String get termsAccepted =>
      'Merci d’avoir accepté, vous pouvez à présent retourner sur le forum';

  @override
  String get privateDiscussions => 'Discussions privées';

  @override
  String get startPrivateDiscussion => 'Discuter en privé';

  @override
  String privateWith(String names) {
    return 'Avec $names';
  }

  @override
  String get addPerson => 'Destinataires';

  @override
  String get choosePerson =>
      'Cette discussion ne sera visible qu’aux utilisateurs que vous sélectionnez ici. Au moins 1 destinataire (autre que vous-même) est requis.';

  @override
  String get noPrivateDiscussions =>
      'Il semble qu’il n’y ait aucune discussion ici.';

  @override
  String get privateOnlyOne =>
      'Ce forum vous permet d’écrire en privé à une seule personne à la fois.';

  @override
  String get messages => 'Messages';

  @override
  String get newMessage => 'Envoyer un message';

  @override
  String get noMessages => 'Aucun nouveau message';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get messageHint => 'Écrire un message…';

  @override
  String get messagesLoadFailed => 'Impossible de charger les messages.';

  @override
  String get moderate => 'Modérer';

  @override
  String get renameDiscussion => 'Renommer';

  @override
  String get renameDiscussionTitle => 'Renommer la discussion';

  @override
  String get lockDiscussion => 'Verrouiller';

  @override
  String get unlockDiscussion => 'Déverrouiller';

  @override
  String get stickDiscussion => 'Épingler';

  @override
  String get unstickDiscussion => 'Désépingler';

  @override
  String get restore => 'Restaurer';

  @override
  String get deleteForever => 'Supprimer définitivement';

  @override
  String get deleteForeverConfirm =>
      'Êtes-vous sûr de vouloir supprimer ceci définitivement ? Cette action est irréversible.';

  @override
  String get approve => 'Approuver';

  @override
  String get unsuspend => 'Lever la suspension';

  @override
  String suspendedUntil(String date) {
    return 'Suspendu jusqu’au $date';
  }

  @override
  String get suspendedIndefinitely => 'Suspendu indéfiniment';

  @override
  String youAreSuspended(String date) {
    return 'Cette suspension sera en vigueur jusqu’au $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Ce compte est suspendu';

  @override
  String get awaitingApproval => 'En attente d’approbation';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$user a fusionné $_temp0 de $titles dans cette discussion.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$user a déplacé $_temp0 vers $title.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$user a séparé $_temp0 de $title.';
  }

  @override
  String get errorNoConnection =>
      'Il semble y avoir un problème avec votre connexion. Veuillez vérifier votre réseau et réessayer.';

  @override
  String get errorTimedOut =>
      'Le forum a mis trop de temps à répondre. Veuillez réessayer.';

  @override
  String get errorBlocked =>
      'Le pare-feu du forum a bloqué l\'application. Réessayez plus tard ou ouvrez le forum dans un navigateur.';

  @override
  String get errorNotFound => 'La ressource demandée est introuvable.';

  @override
  String get errorRateLimited =>
      'Vous allez un peu trop vite. Veuillez réessayer dans quelques secondes.';

  @override
  String get errorForumDown =>
      'Le forum ne répond pas pour le moment. Veuillez réessayer plus tard.';

  @override
  String get errorNotAllowed =>
      'Vous n\'avez pas l\'autorisation de faire cela.';

  @override
  String get errorUnknown =>
      'Oups ! Une erreur est survenue. Veuillez réessayer.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes ont été attribués',
      one: '$count vote a été attribué',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count options',
      one: '$count option',
    );
    return 'Le sondage permet de voter pour $_temp0.';
  }

  @override
  String get pollEnded => 'Ce sondage est terminé.';

  @override
  String pollEndsOn(String date) {
    return 'Le sondage se termine le $date.';
  }

  @override
  String get pollResultsAfterVoting =>
      'Les résultats s’affichent une fois que vous avez voté.';

  @override
  String get pollResultsWhenClosed =>
      'Les résultats s’affichent à la clôture du vote.';

  @override
  String get pollVote => 'Voter';

  @override
  String get pollRemoveVote => 'Retirer mon vote';

  @override
  String get pollSeeVoters => 'Voir les votants';

  @override
  String get pollNoVotes => 'Aucun vote';

  @override
  String get poll => 'Sondage';

  @override
  String get pollNeedsQuestion => 'Vous devez ajouter une question';

  @override
  String get pollNeedsAnswers => 'Vous devez ajouter au moins 2 réponses';

  @override
  String get pollEndInPast => 'Choisissez une clôture dans le futur.';

  @override
  String get pollQuestion => 'Question';

  @override
  String pollAnswer(int number) {
    return 'Réponse $number';
  }

  @override
  String get pollRemoveAnswer => 'Supprimer la réponse';

  @override
  String get pollAddAnswer => 'Ajouter une réponse';

  @override
  String get pollMultipleChoice => 'Autoriser à voter pour plusieurs options';

  @override
  String get pollChoicesAllowed => 'Nombre maximum de votes par utilisateur';

  @override
  String get pollAnyNumber => 'Sans limite';

  @override
  String get pollPublic => 'Autoriser les utilisateurs à voir qui a voté';

  @override
  String get pollAllowChangeVote =>
      'Autoriser les utilisateurs à modifier leur vote';

  @override
  String get pollCloses => 'Date de fin du sondage (facultatif)';

  @override
  String get pollNeverCloses => 'Jamais';

  @override
  String get pollHideVotes => 'Masquer les votes jusqu’à la fin du sondage';

  @override
  String get pollHideVotesNeedsEnd => 'Choisissez d’abord la date de clôture.';

  @override
  String get addPoll => 'Ajouter un sondage';

  @override
  String get submit => 'Envoyer';

  @override
  String get editPoll => 'Modifier le sondage';

  @override
  String get removePoll => 'Supprimer le sondage';

  @override
  String get draftSaved => 'Enregistré !';

  @override
  String get draftSavedWithoutPoll =>
      'Brouillon enregistré, sans le sondage : les brouillons ne gardent pas les sondages.';

  @override
  String get draftNeedsText =>
      'Écrivez quelque chose pour l’enregistrer comme brouillon.';

  @override
  String get drafts => 'Brouillons';

  @override
  String get draftsLoadFailed => 'Impossible de charger vos brouillons';

  @override
  String get noDrafts =>
      'Vous n’avez pas enregistré de brouillons. Fermez un message en cours d’écriture et choisissez « Enregistrer le brouillon » pour le garder ici.';

  @override
  String draftReplyTo(String title) {
    return 'Réponse à $title';
  }

  @override
  String get draftUntitled => 'Discussion sans titre';

  @override
  String get deleteDraftQuestion =>
      'Êtes-vous sûr de vouloir supprimer votre brouillon ?';

  @override
  String get deleteDraft => 'Supprimer le brouillon';
}
