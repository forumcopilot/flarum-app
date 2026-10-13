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
  String get loadEarlierPosts => 'Frühere Beiträge laden';

  @override
  String get postHidden => 'Dieser Beitrag wurde gelöscht.';

  @override
  String get threadLoadFailed =>
      'Diese Diskussion konnte nicht geladen werden.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user hat den Titel von „$from“ in „$to“ geändert.';
  }

  @override
  String eventLocked(String user) {
    return '$user hat die Diskussion gesperrt.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user hat die Diskussion entsperrt.';
  }

  @override
  String eventStickied(String user) {
    return '$user hat die Diskussion angeheftet.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user hat die Diskussion nicht mehr angeheftet.';
  }

  @override
  String eventTagged(String user) {
    return '$user hat die Schlagwörter geändert.';
  }

  @override
  String eventOther(String user) {
    return '$user hat die Diskussion geändert.';
  }

  @override
  String get someone => 'Jemand';

  @override
  String get latest => 'Neueste';

  @override
  String get unread => 'Ungelesen';

  @override
  String get search => 'Suchen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get profile => 'Profil';

  @override
  String get following => 'Folgt';

  @override
  String get home => 'Startseite';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get tags => 'Schlagwörter';

  @override
  String get filterTop => 'Top';

  @override
  String get viewNewest => 'Neu';

  @override
  String discussionReplied(String user, String time) {
    return '$user hat $time geantwortet';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user hat $time begonnen';
  }

  @override
  String get noDiscussions => 'Hier gibt es noch keine Diskussionen.';

  @override
  String get discussionsLoadFailed =>
      'Diskussionen konnten nicht geladen werden.';

  @override
  String get tagsLoadFailed => 'Die Schlagwörter konnten nicht geladen werden.';

  @override
  String get signOut => 'Abmelden';

  @override
  String get account => 'Konto';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String signInFailedReason(String reason) {
    return 'Anmeldung fehlgeschlagen: $reason';
  }

  @override
  String get signInHint =>
      'Melde dich auf der Seite des Forums an. Die App hält dich angemeldet, bis du dich abmeldest.';

  @override
  String signedInAs(String name) {
    return 'Angemeldet als $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Alle Benachrichtigungen als gelesen markiert';

  @override
  String get failedToMarkNotificationsRead =>
      'Benachrichtigungen konnten nicht als gelesen markiert werden';

  @override
  String get noNotificationsYet => 'Noch keine Benachrichtigungen';

  @override
  String notifNewPost(String user, String title) {
    return '$user hat in $title geantwortet';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user gefällt dein Beitrag in $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user hat auf deinen Beitrag in $title reagiert';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user hat auf deinen Beitrag in $title geantwortet';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user hat dich in $title erwähnt';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user hat in $title eine deiner Gruppen erwähnt';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user hat eine Diskussion in $title umbenannt';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user hat $title gesperrt';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user hat $title begonnen';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user hat $title unter ein Schlagwort verschoben, dem du folgst';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user hat eine private Diskussion mit dir begonnen: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user hat in der privaten Diskussion $title geantwortet';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user hat dich zur privaten Diskussion $title hinzugefügt';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user hat dich aus der privaten Diskussion $title entfernt';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user hat $title öffentlich gemacht';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user hat deinen Beitrag in $title als beste Antwort gewählt';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user hat in $title eine beste Antwort gewählt';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Wähle eine beste Antwort in $title';
  }

  @override
  String notifMessage(String user) {
    return '$user hat dir eine Nachricht gesendet';
  }

  @override
  String get notifSuspended => 'Du wurdest gesperrt';

  @override
  String get notifUnsuspended => 'Deine Sperre wurde aufgehoben';

  @override
  String get notifExport => 'Dein Datenexport ist bereit';

  @override
  String get notifOther => 'Neue Benachrichtigung';

  @override
  String get aDiscussion => 'eine Diskussion';

  @override
  String get notificationsLoadFailed =>
      'Deine Benachrichtigungen konnten nicht geladen werden.';

  @override
  String get notificationsSignIn =>
      'Melde dich an, um deine Benachrichtigungen zu sehen.';

  @override
  String get markAllRead => 'Alle als gelesen markieren';

  @override
  String get posts => 'Beiträge';

  @override
  String profileJoined(String date) {
    return 'Dabei seit $date';
  }

  @override
  String get discussionsTab => 'Diskussionen';

  @override
  String lastSeen(String time) {
    return 'Zuletzt online $time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions Diskussionen',
      one: '1 Diskussion',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments Beiträge',
      one: '1 Beitrag',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Dieses Profil konnte nicht geladen werden.';

  @override
  String get noPostsYet => 'Noch keine Beiträge.';

  @override
  String searchFailedWithError(String error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get searchHint => 'Diskussionen und Beiträge durchsuchen';

  @override
  String noResultsFor(String query) {
    return 'Keine Ergebnisse für „$query“.';
  }

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get appearance => 'Darstellung';

  @override
  String get appearanceSystem => 'Systemstandard';

  @override
  String repliedByOne(String a) {
    return '$a hat darauf geantwortet.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a und $b haben darauf geantwortet.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others weitere',
      one: '1 weitere',
    );
    return '$a, $b und $_temp0 haben darauf geantwortet.';
  }

  @override
  String get repliesTitle => 'Antworten';

  @override
  String postNumber(int number) {
    return 'Beitrag #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others weitere',
      one: '1 weitere',
    );
    return '$a und $_temp0 haben darauf geantwortet.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user hat $tags hinzugefügt.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user hat $tags entfernt.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user hat $added hinzugefügt und $removed entfernt.';
  }

  @override
  String get privateDiscussion => 'Private Diskussion';

  @override
  String get bestAnswer => 'Beste Antwort';

  @override
  String get goToBestAnswer => 'Zur besten Antwort';

  @override
  String get answered => 'Beantwortet';

  @override
  String eventRecipientsChanged(String user) {
    return '$user hat die Teilnehmer dieser privaten Diskussion geändert.';
  }

  @override
  String get noTagsOnForum => 'Dieses Forum verwendet keine Schlagwörter.';

  @override
  String get permissionRequired => 'Berechtigung erforderlich';

  @override
  String get bold => 'Fett';

  @override
  String get underline => 'Unterstrichen';

  @override
  String get strikethrough => 'Durchgestrichen';

  @override
  String get bulletList => 'Aufzählungsliste';

  @override
  String get numberedList => 'Nummerierte Liste';

  @override
  String get listItem => 'Listenelement';

  @override
  String get mentionUser => 'Benutzer erwähnen';

  @override
  String get title => 'Titel';

  @override
  String get content => 'Inhalt';

  @override
  String get send => 'Senden';

  @override
  String get save => 'Speichern';

  @override
  String get formatting => 'Formatierung';

  @override
  String get pleaseEnterTitle => 'Bitte geben Sie einen Titel ein';

  @override
  String get pleaseEnterContent => 'Bitte geben Sie einen Inhalt ein';

  @override
  String get composerTitleHint => 'Schreiben Sie Ihren Titel...';

  @override
  String get composerContentHint => 'Schreiben Sie Ihren Inhalt...';

  @override
  String get composerFormattingHint => 'Formatierungsoptionen öffnen';

  @override
  String get searchUsers => 'Benutzer suchen...';

  @override
  String get startDiscussion => 'Diskussion starten';

  @override
  String get editPost => 'Beitrag bearbeiten';

  @override
  String get postingThrottled =>
      'Du schreibst zu schnell. Warte ein paar Sekunden und versuche es erneut.';

  @override
  String get postAwaitingApproval =>
      'Gesendet. Der Beitrag erscheint, sobald ein Moderator ihn freigibt.';

  @override
  String get chooseTags => 'Schlagwörter wählen';

  @override
  String get primaryTags => 'Hauptschlagwörter';

  @override
  String get secondaryTags => 'Weitere Schlagwörter';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wähle $count Hauptschlagwörter.',
      one: 'Wähle ein Hauptschlagwort.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wähle höchstens $count Hauptschlagwörter.',
      one: 'Wähle nur ein Hauptschlagwort.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wähle noch $count Schlagwörter.',
      one: 'Wähle noch ein Schlagwort.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wähle höchstens $count weitere Schlagwörter.',
      one: 'Wähle höchstens ein weiteres Schlagwort.',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Fertig';

  @override
  String get noMembersFound => 'Keine Mitglieder gefunden.';

  @override
  String get memberSearchNotAllowed =>
      'Dieses Forum erlaubt keine Mitgliedersuche.';

  @override
  String get editLoadFailed =>
      'Dieser Beitrag konnte nicht zum Bearbeiten geladen werden.';

  @override
  String get like => 'Gefällt mir';

  @override
  String get unlike => 'Gefällt mir nicht mehr';

  @override
  String get react => 'Reagieren';

  @override
  String get reactions => 'Reaktionen';

  @override
  String get bookmark => 'Lesezeichen setzen';

  @override
  String get removeBookmark => 'Lesezeichen entfernen';

  @override
  String get bookmarks => 'Lesezeichen';

  @override
  String get noBookmarks => 'Noch keine Lesezeichen.';

  @override
  String get chooseBestAnswer => 'Als beste Antwort wählen';

  @override
  String get removeBestAnswer => 'Beste Antwort entfernen';

  @override
  String get notificationSettings => 'Benachrichtigungen für diese Diskussion';

  @override
  String get notFollowing => 'Nicht folgen';

  @override
  String get notFollowingHint => 'Nur bei @Erwähnungen benachrichtigen.';

  @override
  String get followingHint => 'Bei allen Antworten benachrichtigen.';

  @override
  String get ignoring => 'Ignorieren';

  @override
  String get ignoringHint =>
      'Nie benachrichtigen und aus den Diskussionslisten ausblenden.';

  @override
  String get tagFollowingHint => 'Bei neuen Diskussionen benachrichtigen.';

  @override
  String get lurking => 'Mitlesen';

  @override
  String get lurkingHint =>
      'Bei neuen Diskussionen und jeder Antwort benachrichtigen.';

  @override
  String get tagIgnoringHint => 'Hier nie benachrichtigen.';

  @override
  String get hidden => 'Ausgeblendet';

  @override
  String get hiddenHint =>
      'Die Diskussionen dieses Schlagworts aus den Diskussionslisten ausblenden.';

  @override
  String get attachFile => 'Datei anhängen';

  @override
  String get uploadImage => 'Bild hochladen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String uploadingFilename(String filename) {
    return 'Wird hochgeladen: $filename …';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Datei konnte nicht hochgeladen werden: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Bitte warten, bis alle Anhänge hochgeladen sind';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName wurde auf $size$dimensions verkleinert, um das Limit von $limit einzuhalten.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: zu groß ($size) und konnte nicht verkleinert werden. Das Limit ist $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName ist $fileBytes groß. Dieses Forum erlaubt bis zu $maxBytes.';
  }

  @override
  String get flagAction => 'Melden';

  @override
  String get ignoredUsers => 'Ignorierte Benutzer';

  @override
  String get ignoredUsersEmpty => 'Du ignorierst niemanden.';

  @override
  String get flagPostTitle => 'Beitrag melden';

  @override
  String get flagReasonOffTopic => 'Themenfremd';

  @override
  String get flagReasonOffTopicText =>
      'Dieser Beitrag gehört nicht zur aktuellen Diskussion und sollte verschoben werden.';

  @override
  String get flagReasonInappropriate => 'Unangemessen';

  @override
  String get flagReasonInappropriateText =>
      'Dieser Beitrag ist beleidigend, missbräuchlich oder verstößt gegen die Community-Richtlinien.';

  @override
  String get flagReasonSpam => 'Spam';

  @override
  String get flagReasonSpamText => 'Dieser Beitrag ist Werbung.';

  @override
  String get flagReasonOther => 'Sonstiges (bitte angeben)';

  @override
  String get flagDetails => 'Weitere Angaben (optional)';

  @override
  String get flagDetailsNeeded =>
      'Bitte gib den Moderatoren ein paar Details an.';

  @override
  String get communityGuidelines => 'Community-Richtlinien';

  @override
  String get flagSent =>
      'Danke für deine Meldung. Unsere Moderatoren sehen sich den Beitrag an.';

  @override
  String ignoreUser(String name) {
    return '$name ignorieren';
  }

  @override
  String stopIgnoringUser(String name) {
    return '$name nicht mehr ignorieren';
  }

  @override
  String ignoreUserConfirm(String name) {
    return '$name ignorieren? Die Beiträge werden eingeklappt. Du kannst das in deinem Konto wieder aufheben.';
  }

  @override
  String ignoredUserPost(String name) {
    return 'Ein Beitrag von $name, den du ignorierst.';
  }

  @override
  String get showPost => 'Beitrag anzeigen';

  @override
  String get ignoredOnThisPhone =>
      'Dieses Forum führt keine Liste ignorierter Nutzer, daher speichert die App deine auf diesem Telefon.';

  @override
  String get stopIgnoring => 'Nicht mehr ignorieren';
}
