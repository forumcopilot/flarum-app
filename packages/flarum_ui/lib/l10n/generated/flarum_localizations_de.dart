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
  String get copyLink => 'Link kopieren';

  @override
  String get linkCopied => 'Link kopiert.';

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
  String get saveImage => 'Bild speichern';

  @override
  String get imageSaved => 'Bild gespeichert.';

  @override
  String get imageSaveFailed => 'Das Bild konnte nicht gespeichert werden.';

  @override
  String get imageSaveNotAllowed =>
      'Die App darf nicht in deinen Fotos speichern. Du kannst es in den Einstellungen des Telefons erlauben.';

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
  String get edited => 'Bearbeitet';

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
  String get loadEarlierPosts => 'Mehr laden';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$index von $count Beiträgen',
      one: '$index von $count Beitrag',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => 'Erster Beitrag';

  @override
  String get scrubberNow => 'Neuester Beitrag';

  @override
  String timeGapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage später',
      one: 'einen Tag später',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate später',
      one: 'einen Monat später',
    );
    return '$_temp0';
  }

  @override
  String timeGapYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jahre später',
      one: 'ein Jahr später',
    );
    return '$_temp0';
  }

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
  String get someone => '[gelöscht]';

  @override
  String get latest => 'Neueste';

  @override
  String get unread => 'Ungelesen';

  @override
  String get search => 'Suchen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get logInToReply => 'Anmelden zum Antworten';

  @override
  String get cannotReply => 'Antworten nicht möglich';

  @override
  String get profile => 'Profil';

  @override
  String get following => 'Folgt';

  @override
  String get follow => 'Folgen';

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
  String get allDiscussions => 'Alle Diskussionen';

  @override
  String get sortOldest => 'Älteste';

  @override
  String get sortTitleAz => 'Titel (A–Z)';

  @override
  String get sortTitleZa => 'Titel (Z–A)';

  @override
  String get changeSorting => 'Sortierung der Diskussionsliste ändern';

  @override
  String get toggleNavigation => 'Dropdown-Menü für die Navigation umschalten';

  @override
  String discussionReplied(String user, String time) {
    return '$user hat $time geantwortet';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user hat $time begonnen';
  }

  @override
  String get noDiscussions => 'Es gibt noch keine Diskussionen hier.';

  @override
  String get discussionsLoadFailed =>
      'Diskussionen konnten nicht geladen werden.';

  @override
  String get tagsLoadFailed => 'Die Schlagwörter konnten nicht geladen werden.';

  @override
  String get signOut => 'Abmelden';

  @override
  String logOutQuestion(String forum) {
    return 'Bist du sicher, dass du dich von $forum abmelden willst?';
  }

  @override
  String get account => 'Konto';

  @override
  String get createAccount => 'Registrieren';

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
  String get noNotificationsYet => 'Keine neuen Benachrichtigungen';

  @override
  String notifNewPost(String user, String title) {
    return '$user hat in $title geschrieben';
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
    return '$user hat in $title eine Gruppe erwähnt, in der du Mitglied bist';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user hat den Titel in $title geändert';
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
    return '$user hat das Schlagwort von $title geändert';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user hat eine neue private Diskussion mit dir begonnen: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user hat in einer privaten Diskussion gepostet, an der du beteiligt bist: $title';
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
    return 'Dein Beitrag wurde von $user in $title als beste Antwort ausgewählt';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user hat in $title eine beste Antwort gewählt';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Bitte wähle in $title eine Beste Antwort, wenn deine Frage bereits beantwortet wurde';
  }

  @override
  String notifMessage(String user) {
    return '$user hat dir eine Nachricht gesendet';
  }

  @override
  String get notifSuspended => 'Du wurdest gesperrt';

  @override
  String get notifUnsuspended => 'Du wurdest entsperrt';

  @override
  String get notifExport => 'Dein Datenexport ist bereit zum Download.';

  @override
  String get notifOther => 'Neue Benachrichtigung';

  @override
  String notifLineNewPost(String user) {
    return '$user hat geschrieben';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user gefällt dein Beitrag';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user hat auf deinen Beitrag reagiert';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user hat auf deinen Beitrag geantwortet';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user hat dich erwähnt';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user hat eine Gruppe erwähnt, in der du Mitglied bist';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user hat den Titel geändert';
  }

  @override
  String notifLineLocked(String user) {
    return '$user hat sie geschlossen';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user hat sie begonnen';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user hat das Schlagwort geändert';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user hat eine neue private Diskussion mit dir begonnen';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user hat in einer privaten Diskussion gepostet, an der du beteiligt bist';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user hat dich zu einer privaten Diskussion hinzugefügt';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user hat dich aus einer privaten Diskussion entfernt';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user hat alle Empfänger entfernt und die Diskussion öffentlich gemacht';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Dein Beitrag wurde von $user als beste Antwort ausgewählt';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user hat in dieser Diskussion eine beste Antwort gewählt';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Bitte wähle eine Beste Antwort, wenn deine Frage bereits beantwortet wurde';

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
  String get markAllDiscussionsReadQuestion =>
      'Bist du dir sicher, dass du alle Diskussionen als gelesen markieren willst?';

  @override
  String get hideWelcomeMessage => 'Willkommensnachricht ausblenden';

  @override
  String get posts => 'Beiträge';

  @override
  String get usersTab => 'Benutzer';

  @override
  String get likesTab => 'Gefällt mir';

  @override
  String get mentionsTab => 'Erwähnungen';

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
  String get online => 'Online';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beste Antworten',
      one: '$count beste Antwort',
    );
    return '$_temp0';
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
  String get noPostsYet => 'Es scheint, dass es hier keine Beiträge gibt.';

  @override
  String searchFailedWithError(String error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get searchHint => 'Suche';

  @override
  String get recentSearches => 'Letzte Suchen';

  @override
  String get clearRecentSearches => 'Löschen';

  @override
  String noResultsFor(String query) {
    return 'Es sieht so aus, als gäbe es keine Ergebnisse für „$query“.';
  }

  @override
  String get light => 'Heller Modus';

  @override
  String get dark => 'Dunkler Modus';

  @override
  String get appearance => 'Farbschema';

  @override
  String get appearanceSystem => 'Systemeinstellung';

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
  String get repliesTitle => 'Antworten auf diesen Beitrag';

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
  String get goToBestAnswer => 'Beste Antwort anzeigen';

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
  String get mentionUser => 'Benutzer, Gruppe oder Beitrag erwähnen';

  @override
  String get title => 'Titel';

  @override
  String get content => 'Inhalt';

  @override
  String get send => 'Nachricht senden';

  @override
  String get postReply => 'Antwort senden';

  @override
  String get postDiscussion => 'Beitrag senden';

  @override
  String get postPrivateDiscussion => 'Private Diskussion erstellen';

  @override
  String get save => 'Änderungen speichern';

  @override
  String get formatting => 'Formatierung';

  @override
  String get addBold => 'Fett gedruckter Text';

  @override
  String get addItalic => 'Kursiver Text';

  @override
  String get insertQuote => 'Zitat einfügen';

  @override
  String get addLink => 'Link einfügen';

  @override
  String get addBulletedList => 'Liste einfügen';

  @override
  String get insertCode => 'Code einfügen';

  @override
  String get pleaseEnterTitle => 'Bitte gib einen Titel ein';

  @override
  String get pleaseEnterContent => 'Bitte gib einen Inhalt ein';

  @override
  String get composerTitleHint => 'Titel der Diskussion';

  @override
  String get privateDiscussionTitleHint => 'Titel der privaten Diskussion';

  @override
  String get composerContentHint => 'Beitrag verfassen…';

  @override
  String get composerReplyHint => 'Eine Antwort schreiben…';

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
      'Nicht so schnell. Bitte versuche es in Kürze erneut.';

  @override
  String get postAwaitingApproval =>
      'Gesendet. Der Beitrag erscheint, sobald ein Moderator ihn freigibt.';

  @override
  String get chooseTags => 'Schlagwörter auswählen';

  @override
  String get ok => 'Okay';

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
  String get noMembersFound =>
      'Es wurden keine Benutzer gefunden, die deiner Suche entsprechen.';

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
  String likedByOne(String a) {
    return '$a gefällt das.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a und $b gefällt das.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others weiteren Personen',
      one: '1 weiteren Person',
    );
    return '$a und $_temp0 gefällt das.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others weiteren Personen',
      one: '1 weiteren Person',
    );
    return '$a, $b und $_temp0 gefällt das.';
  }

  @override
  String get likedByYou => 'Dir gefällt das.';

  @override
  String likedByYouAndOne(String a) {
    return 'Dir und $a gefällt das.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others weiteren Personen',
      one: '1 weiteren Person',
    );
    return 'Dir, $a und $_temp0 gefällt das.';
  }

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
  String get noBookmarks =>
      'Du hast noch keine Beiträge als Lesezeichen gespeichert.';

  @override
  String get chooseBestAnswer => 'Beste Antwort auswählen';

  @override
  String get removeBestAnswer => 'Beste Antwort abwählen';

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
      'Niemals benachrichtigen und in der Liste verstecken.';

  @override
  String get tagFollowingHint =>
      'Über alle neuen Diskussionen benachrichtigt werden.';

  @override
  String get lurking => 'Mitlesen';

  @override
  String get lurkingHint =>
      'Über alle neuen Diskussionen und Antworten benachrichtigen lassen.';

  @override
  String get tagIgnoringHint => 'Niemals benachrichtigt werden.';

  @override
  String get hidden => 'Ausgeblendet';

  @override
  String get hiddenHint =>
      'Ausblenden von Diskussionen auf der Seite Alle Diskussionen.';

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
    return '$fileName ist $fileBytes groß. Uploads über $maxBytes werden nicht akzeptiert.';
  }

  @override
  String get flagAction => 'Melden';

  @override
  String get ignoredUsers => 'Ignorierte Benutzer';

  @override
  String get ignoredUsersEmpty =>
      'Es sieht so aus, als würdest du niemanden ignorieren.';

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
      'Dieser Beitrag ist anstößig, beleidigend oder verstößt gegen unsere Community-Richtlinien.';

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
    return 'Ignorierung von $name aufheben';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Möchtest du $name wirklich ignorieren?';
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
  String get stopIgnoring => 'Ignorierung aufheben';

  @override
  String get termsBanner =>
      'Während du dir die neuen Bedingungen ansiehst, haben wir den Zugang zum Forum vorübergehend eingeschränkt.';

  @override
  String get termsReview => 'Ansehen';

  @override
  String get termsTitle => 'Aktualisierung der Bedingungen';

  @override
  String get termsIntro =>
      'Die Bedingungen wurden seit deinem letzten Besuch aktualisiert';

  @override
  String get readPolicy => 'Lesen';

  @override
  String get acceptTerms => 'Bestätigen';

  @override
  String get termsAccepted =>
      'Vielen Dank für deine Zustimmung, du kannst nun zum Forum zurückkehren';

  @override
  String get privateDiscussions => 'Private Diskussionen';

  @override
  String get startPrivateDiscussion => 'Privat diskutieren';

  @override
  String privateWith(String names) {
    return 'Mit $names';
  }

  @override
  String get addPerson => 'Empfänger';

  @override
  String get choosePerson =>
      'Diese Diskussion wird nur für die Nutzer sichtbar sein, die du hier auswählst. Mindestens 1 Empfänger (außer dir selbst) ist erforderlich.';

  @override
  String get noPrivateDiscussions => 'Es gibt noch keine Diskussionen hier.';

  @override
  String get privateOnlyOne =>
      'In diesem Forum kannst du jeweils nur einer Person privat schreiben.';

  @override
  String get messages => 'Nachrichten';

  @override
  String get markAllMessagesRead => 'Alle als gelesen markieren';

  @override
  String get startOfConversation => 'Beginn der Unterhaltung';

  @override
  String get messageCopied => 'Nachricht kopiert.';

  @override
  String get newMessage => 'Nachricht senden';

  @override
  String get noMessages => 'Keine neuen Nachrichten';

  @override
  String get sendMessage => 'Nachricht senden';

  @override
  String get messageHint => 'Nachricht schreiben …';

  @override
  String get messagesLoadFailed =>
      'Die Nachrichten konnten nicht geladen werden.';

  @override
  String get moderate => 'Moderieren';

  @override
  String get renameDiscussion => 'Umbenennen';

  @override
  String get renameDiscussionTitle => 'Diskussion umbenennen';

  @override
  String get lockDiscussion => 'Sperren';

  @override
  String get unlockDiscussion => 'Entsperren';

  @override
  String get stickDiscussion => 'Anheften';

  @override
  String get unstickDiscussion => 'Lösen';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get deleteForever => 'Endgültig löschen';

  @override
  String get deleteForeverConfirm =>
      'Bist du dir sicher, dass du das für immer löschen willst? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get approve => 'Freigeben';

  @override
  String get unsuspend => 'Sperre aufheben';

  @override
  String suspendedUntil(String date) {
    return 'Gesperrt bis $date';
  }

  @override
  String get suspendedIndefinitely => 'Unbefristet gesperrt';

  @override
  String youAreSuspended(String date) {
    return 'Diese Sperre gilt bis zum $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Dieses Konto ist gesperrt';

  @override
  String get awaitingApproval => 'Wartet auf Freigabe';

  @override
  String get badgeSticky => 'Angeheftet';

  @override
  String get badgeLocked => 'Geschlossen';

  @override
  String get badgeHidden => 'Versteckt';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beiträge',
      one: '1 Beitrag',
    );
    return '$user hat $_temp0 aus $titles hierher zusammengeführt.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beiträge',
      one: '1 Beitrag',
    );
    return '$user hat $_temp0 nach $title abgetrennt.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beiträge',
      one: '1 Beitrag',
    );
    return '$user hat $_temp0 aus $title abgetrennt.';
  }

  @override
  String get errorNoConnection =>
      'Mit deiner Verbindung scheint etwas nicht zu stimmen. Bitte überprüfe deine Netzwerkverbindung und versuche es erneut.';

  @override
  String get errorTimedOut =>
      'Das Forum hat zu lange nicht geantwortet. Bitte versuche es erneut.';

  @override
  String get errorBlocked =>
      'Die Firewall des Forums hat die App blockiert. Versuche es später erneut oder öffne das Forum im Browser.';

  @override
  String get errorNotFound => 'Leider wurde nichts gefunden.';

  @override
  String get errorRateLimited =>
      'Nicht so schnell. Bitte versuche es in Kürze erneut.';

  @override
  String get errorForumDown =>
      'Das Forum antwortet gerade nicht. Bitte versuche es später erneut.';

  @override
  String get errorNotAllowed => 'Du hast keine Berechtigung dies zu tun.';

  @override
  String get errorUnknown =>
      'Ups! Da ist was schiefgelaufen. Bitte versuche es erneut.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stimmen wurden abgegeben',
      one: '$count Stimme wurde abgegeben',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Optionen',
      one: '$count Option',
    );
    return 'In der Umfrage kann für $_temp0 abgestimmt werden.';
  }

  @override
  String get pollEnded => 'Diese Umfrage ist bereits beendet.';

  @override
  String pollEndsOn(String date) {
    return 'Umfrage endet am $date.';
  }

  @override
  String get pollResultsAfterVoting =>
      'Die Ergebnisse siehst du, sobald du abgestimmt hast.';

  @override
  String get pollResultsWhenClosed =>
      'Die Ergebnisse siehst du, wenn die Abstimmung endet.';

  @override
  String get pollVote => 'Abstimmen';

  @override
  String get pollRemoveVote => 'Stimme zurückziehen';

  @override
  String get pollSeeVoters => 'Wer hat abgestimmt?';

  @override
  String get pollNoVotes => 'Keine Stimmen';

  @override
  String get poll => 'Umfrage';

  @override
  String get pollNeedsQuestion => 'Du musst eine Frage stellen';

  @override
  String get pollNeedsAnswers => 'Du musst mindestens zwei Antworten erstellen';

  @override
  String get pollEndInPast => 'Wähle ein Ende in der Zukunft.';

  @override
  String get pollQuestion => 'Frage';

  @override
  String pollAnswer(int number) {
    return 'Antwort $number';
  }

  @override
  String get pollRemoveAnswer => 'Antwort entfernen';

  @override
  String get pollAddAnswer => 'Antwort hinzufügen';

  @override
  String get pollMultipleChoice =>
      'Benutzern erlauben, für mehrere Optionen abzustimmen';

  @override
  String get pollChoicesAllowed => 'Maximale Stimmen pro Benutzer';

  @override
  String get pollAnyNumber => 'Beliebig viele';

  @override
  String get pollPublic => 'Alle dürfen sehen, wer abgestimmt hat';

  @override
  String get pollAllowChangeVote => 'Benutzern erlauben, ihre Stimme zu ändern';

  @override
  String get pollCloses => 'Enddatum der Umfrage (optional)';

  @override
  String get pollNeverCloses => 'Nie';

  @override
  String get pollHideVotes => 'Stimmen ausblenden, bis die Umfrage endet';

  @override
  String get pollHideVotesNeedsEnd =>
      'Wähle zuerst, wann die Abstimmung endet.';

  @override
  String get addPoll => 'Umfrage hinzufügen';

  @override
  String get submit => 'Speichern';

  @override
  String get editPoll => 'Umfrage bearbeiten';

  @override
  String get removePoll => 'Umfrage entfernen';

  @override
  String get draftSaved => 'Gespeichert!';

  @override
  String get draftSavedWithoutPoll =>
      'Entwurf gespeichert, ohne die Umfrage: Entwürfe speichern keine Umfragen.';

  @override
  String get draftNeedsText => 'Schreib etwas, um es als Entwurf zu speichern.';

  @override
  String get drafts => 'Entwürfe';

  @override
  String get draftsLoadFailed => 'Deine Entwürfe konnten nicht geladen werden';

  @override
  String get noDrafts =>
      'Du hast keine Entwürfe gespeichert. Schließe einen Beitrag, den du schreibst, und wähle „Entwurf speichern“, um ihn hier aufzubewahren.';

  @override
  String draftReplyTo(String title) {
    return 'Antwort auf $title';
  }

  @override
  String get draftUntitled => 'Diskussion ohne Titel';

  @override
  String get deleteDraftQuestion =>
      'Bist du sicher, dass du den Entwurf löschen möchtest?';

  @override
  String get deleteDraft => 'Entwurf löschen';
}
