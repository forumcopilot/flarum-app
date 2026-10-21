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
  String get copyLink => 'Copia link';

  @override
  String get linkCopied => 'Link copiato.';

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
  String get saveImage => 'Salva immagine';

  @override
  String get imageSaved => 'Immagine salvata.';

  @override
  String get imageSaveFailed => 'Impossibile salvare l\'immagine.';

  @override
  String get imageSaveNotAllowed =>
      'L\'app non può salvare nelle tue foto. Puoi consentirlo nelle impostazioni del telefono.';

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
  String get edited => 'Modificato';

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
  String get loadMore => 'Carica di più';

  @override
  String viewProfileOfUser(String username) {
    return 'Vedi il profilo di $username';
  }

  @override
  String get loadEarlierPosts => 'Carica di più';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$index di $count post',
      one: '$index di $count post',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => 'Messaggio originale';

  @override
  String get scrubberNow => 'Ora';

  @override
  String timeGapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni dopo',
      one: 'un giorno dopo',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesi dopo',
      one: 'un mese dopo',
    );
    return '$_temp0';
  }

  @override
  String timeGapYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anni dopo',
      one: 'un anno dopo',
    );
    return '$_temp0';
  }

  @override
  String get postHidden => 'Questo post è stato eliminato.';

  @override
  String get threadLoadFailed => 'Impossibile caricare questa discussione.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user ha cambiato il titolo da «$from» a «$to».';
  }

  @override
  String eventLocked(String user) {
    return '$user ha bloccato la discussione.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user ha sbloccato la discussione.';
  }

  @override
  String eventStickied(String user) {
    return '$user ha messo in evidenza la discussione.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user ha tolto la discussione dall’evidenza.';
  }

  @override
  String eventTagged(String user) {
    return '$user ha cambiato i tag.';
  }

  @override
  String eventOther(String user) {
    return '$user ha modificato la discussione.';
  }

  @override
  String get someone => '[cancellato]';

  @override
  String get latest => 'Recenti';

  @override
  String get unread => 'Non letti';

  @override
  String get search => 'Cerca';

  @override
  String get signIn => 'Accedi';

  @override
  String get logInToReply => 'Accedi per rispondere';

  @override
  String get cannotReply => 'Non puoi rispondere';

  @override
  String get profile => 'Profilo';

  @override
  String get following => 'Seguiti';

  @override
  String get follow => 'Segui';

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
  String get viewNewest => 'Nuove';

  @override
  String get allDiscussions => 'Tutte le discussioni';

  @override
  String get sortOldest => 'Meno recenti';

  @override
  String get sortTitleAz => 'Titolo (A–Z)';

  @override
  String get sortTitleZa => 'Titolo (Z–A)';

  @override
  String get changeSorting => 'Cambia indice lista discussioni';

  @override
  String get toggleNavigation =>
      'Attiva/disattiva il menu a discesa di navigazione';

  @override
  String discussionReplied(String user, String time) {
    return '$user ha risposto $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user l’ha avviata $time';
  }

  @override
  String get noDiscussions => 'Sembra che non ci siano discussioni qui.';

  @override
  String get discussionsLoadFailed => 'Impossibile caricare le discussioni.';

  @override
  String get tagsLoadFailed => 'Impossibile caricare i tag.';

  @override
  String get signOut => 'Esci';

  @override
  String logOutQuestion(String forum) {
    return 'Sei sicuro di volerti disconnettere da $forum?';
  }

  @override
  String get account => 'Account';

  @override
  String get createAccount => 'Registrati';

  @override
  String signInFailedReason(String reason) {
    return 'Accesso non riuscito: $reason';
  }

  @override
  String get signInHint =>
      'Accedi dalla pagina del forum. L’app ti mantiene connesso finché non esci.';

  @override
  String signedInAs(String name) {
    return 'Accesso eseguito come $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Tutte le notifiche segnate come lette';

  @override
  String get failedToMarkNotificationsRead =>
      'Impossibile segnare le notifiche come lette';

  @override
  String get noNotificationsYet => 'Non ci sono notifiche';

  @override
  String notifNewPost(String user, String title) {
    return '$user ha scritto un messaggio in $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return 'A $user piace il tuo post in $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user ha reagito al tuo post in $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user ha risposto al tuo post in $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user ti ha menzionato in $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user ha menzionato un gruppo di cui fai parte in $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user ha cambiato il titolo in $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user ha bloccato $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user ha avviato $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user ha cambiato il tag di $title';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user ha iniziato una discussione privata con te: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user ha pubblicato in una discussione privata di cui fai parte: $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user ti ha aggiunto alla discussione privata $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user ti ha rimosso dalla discussione privata $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user ha reso pubblica $title';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return 'Il tuo post è stato scelto come migliore risposta da $user in $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user ha impostato la risposta migliore in $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Seleziona la risposta migliore in $title se la tua domanda ha ricevuto una risposta';
  }

  @override
  String notifMessage(String user) {
    return '$user ti ha inviato un messaggio';
  }

  @override
  String get notifSuspended => 'Il tuo account è stato sospeso';

  @override
  String get notifUnsuspended => 'Non sei più sospeso';

  @override
  String get notifExport =>
      'L’esportazione dei tuoi dati è pronta per il download.';

  @override
  String get notifOther => 'Nuova notifica';

  @override
  String notifLineNewPost(String user) {
    return '$user ha scritto un messaggio';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user ha messo mi piace al tuo post';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user ha reagito al tuo post';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user ha risposto al tuo post';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user ti ha menzionato';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user ha menzionato un gruppo di cui fai parte';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user ha cambiato il titolo';
  }

  @override
  String notifLineLocked(String user) {
    return '$user ha chiuso la discussione';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user ha iniziato';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user ha cambiato il tag';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user ha iniziato una discussione privata con te';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user ha pubblicato in una discussione privata di cui fai parte';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user ti ha aggiunto ad una discussione privata';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user ti ha rimosso da una discussione privata';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user ha rimosso tutti i destinatari e ha reso pubblica la discussione';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Il tuo post è stato scelto come migliore risposta da $user';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user ha impostato la risposta migliore nella discussione';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Seleziona una risposta migliore se la tua domanda ha ricevuto una risposta';

  @override
  String get aDiscussion => 'una discussione';

  @override
  String get notificationsLoadFailed => 'Impossibile caricare le notifiche.';

  @override
  String get notificationsSignIn => 'Accedi per vedere le tue notifiche.';

  @override
  String get markAllRead => 'Segna tutto come letto';

  @override
  String get markAsRead => 'Segna come letto';

  @override
  String get markAllDiscussionsReadQuestion =>
      'Sei sicuro di voler contrassegnare tutte le discussioni come lette?';

  @override
  String get hideWelcomeMessage => 'Nascondi messaggio di benvenuto';

  @override
  String get posts => 'Post';

  @override
  String get usersTab => 'Utenti';

  @override
  String get likesTab => 'Mi Piace';

  @override
  String get mentionsTab => 'Menzioni';

  @override
  String profileJoined(String date) {
    return 'Iscritto da $date';
  }

  @override
  String get discussionsTab => 'Discussioni';

  @override
  String lastSeen(String time) {
    return 'Ultimo accesso $time';
  }

  @override
  String get online => 'Online';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risposte migliori',
      one: '$count risposta migliore',
    );
    return '$_temp0';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions discussioni',
      one: '1 discussione',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments post',
      one: '1 post',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Impossibile caricare questo profilo.';

  @override
  String get noPostsYet => 'Non ci sono messaggi.';

  @override
  String searchFailedWithError(String error) {
    return 'Ricerca fallita: $error';
  }

  @override
  String get searchHint => 'Cerca';

  @override
  String get recentSearches => 'Ricerche recenti';

  @override
  String get clearRecentSearches => 'Cancella';

  @override
  String noResultsFor(String query) {
    return 'Nessun risultato per «$query».';
  }

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get appearance => 'Aspetto';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String repliedByOne(String a) {
    return '$a ha risposto a questo post.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a e $b hanno risposto a questo post.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'altri $others',
      one: '1 altro',
    );
    return '$a, $b e $_temp0 hanno risposto a questo post.';
  }

  @override
  String get repliesTitle => 'Risposte a questo post';

  @override
  String postNumber(int number) {
    return 'Post #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'altri $others',
      one: '1 altro',
    );
    return '$a e $_temp0 hanno risposto a questo post.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user ha aggiunto $tags.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user ha rimosso $tags.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user ha aggiunto $added e rimosso $removed.';
  }

  @override
  String get privateDiscussion => 'Discussione privata';

  @override
  String get bestAnswer => 'Risposta migliore';

  @override
  String get goToBestAnswer => 'Vai alla migliore risposta';

  @override
  String get answered => 'Risolta';

  @override
  String eventRecipientsChanged(String user) {
    return '$user ha cambiato i partecipanti di questa discussione privata.';
  }

  @override
  String get noTagsOnForum => 'Questo forum non usa i tag.';

  @override
  String get permissionRequired => 'Autorizzazione richiesta';

  @override
  String get bold => 'Grassetto';

  @override
  String get underline => 'Sottolineato';

  @override
  String get strikethrough => 'Barrato';

  @override
  String get bulletList => 'Elenco Puntato';

  @override
  String get numberedList => 'Elenco Numerato';

  @override
  String get listItem => 'Elemento Elenco';

  @override
  String get mentionUser => 'Menziona un utente, un gruppo o un messaggio';

  @override
  String get title => 'Titolo';

  @override
  String get content => 'Contenuto';

  @override
  String get send => 'Invia messaggio';

  @override
  String get postReply => 'Rispondi';

  @override
  String get postDiscussion => 'Crea discussione';

  @override
  String get postPrivateDiscussion => 'Pubblica discussione privata';

  @override
  String get save => 'Salva cambiamenti';

  @override
  String get discardReplyQuestion =>
      'Non hai pubblicato la tua risposta. Vuoi scartarla?';

  @override
  String get discardDiscussionQuestion =>
      'Non hai creato la discussione. Desideri disfartene?';

  @override
  String get discardEditQuestion =>
      'Non hai salvato le tue modifiche. Desideri disfartene?';

  @override
  String get discard => 'Scarta';

  @override
  String get saveDraft => 'Salva Bozza';

  @override
  String get formatting => 'Formattazione';

  @override
  String get addBold => 'Aggiungi testo grassetto';

  @override
  String get addItalic => 'Aggiungi testo corsivo';

  @override
  String get insertQuote => 'Inserisci citazione';

  @override
  String get addLink => 'Aggiungi link';

  @override
  String get addBulletedList => 'Inserisci elenco puntato';

  @override
  String get insertCode => 'Inserisci codice';

  @override
  String get pleaseEnterTitle => 'Inserisci un titolo';

  @override
  String get pleaseEnterContent => 'Inserisci del contenuto';

  @override
  String get composerTitleHint => 'Titolo della discussione';

  @override
  String get privateDiscussionTitleHint => 'Titolo discussione privata';

  @override
  String get composerContentHint => 'Messaggio...';

  @override
  String get composerReplyHint => 'Rispondi alla discussione...';

  @override
  String get composerFormattingHint => 'Apri le opzioni di formattazione';

  @override
  String get searchUsers => 'Cerca utenti...';

  @override
  String get startDiscussion => 'Inizia una discussione';

  @override
  String get editPost => 'Modifica post';

  @override
  String get postingThrottled =>
      'Stai scrivendo un po’ troppo in fretta. Riprova tra qualche secondo.';

  @override
  String get postAwaitingApproval =>
      'Inviato. Apparirà quando un moderatore lo approverà.';

  @override
  String get chooseTags => 'Scegli i tag';

  @override
  String get ok => 'OK';

  @override
  String get primaryTags => 'Tag principali';

  @override
  String get secondaryTags => 'Altri tag';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scegli $count tag principali.',
      one: 'Scegli un tag principale.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scegli al massimo $count tag principali.',
      one: 'Scegli un solo tag principale.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scegli altri $count tag.',
      one: 'Scegli un altro tag.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scegli al massimo altri $count tag.',
      one: 'Scegli al massimo un altro tag.',
    );
    return '$_temp0';
  }

  @override
  String get noMembersFound => 'Nessun membro trovato.';

  @override
  String get memberSearchNotAllowed =>
      'Questo forum non permette di cercare i membri.';

  @override
  String get editLoadFailed =>
      'Impossibile caricare questo post per modificarlo.';

  @override
  String get like => 'Mi piace';

  @override
  String get unlike => 'Non mi piace più';

  @override
  String likedByOne(String a) {
    return '$a ha messo mi piace.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a e $b hanno messo mi piace.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'altri $others',
      one: '1 altro',
    );
    return '$a e $_temp0 hanno messo mi piace.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'altri $others',
      one: '1 altro',
    );
    return '$a, $b e $_temp0 hanno messo mi piace.';
  }

  @override
  String get likedByYou => 'Hai messo mi piace.';

  @override
  String likedByYouAndOne(String a) {
    return 'Tu e $a avete messo mi piace.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'altri $others',
      one: '1 altro',
    );
    return 'Tu, $a e $_temp0 avete messo mi piace.';
  }

  @override
  String get react => 'Reagisci';

  @override
  String get reactions => 'Reazioni';

  @override
  String get bookmark => 'Aggiungi ai segnalibri';

  @override
  String get removeBookmark => 'Rimuovi dai segnalibri';

  @override
  String get bookmarks => 'Segnalibri';

  @override
  String get noBookmarks => 'Ancora nessun segnalibro.';

  @override
  String get chooseBestAnswer => 'Scegli risposta migliore';

  @override
  String get removeBestAnswer => 'Rimuovi risposta migliore';

  @override
  String get notFollowing => 'Non seguita';

  @override
  String get notFollowingHint => 'Ricevi notifiche solo se menzionato.';

  @override
  String get followingHint => 'Ricevi notifiche per tutte le risposte.';

  @override
  String get ignoring => 'Ignorata';

  @override
  String get ignoringHint =>
      'Nessuna notifica. Nascondi dalla lista delle discussioni.';

  @override
  String get tagFollowingHint =>
      'Mandami una notifica per ogni nuova discussione.';

  @override
  String get lurking => 'In osservazione';

  @override
  String get lurkingHint =>
      'Mandami una notifica per ogni nuova discussione e ogni risposta.';

  @override
  String get tagIgnoringHint => 'Nessuna notifica.';

  @override
  String get hidden => 'Nascosto';

  @override
  String get hiddenHint =>
      'Nascondi tutte le discussioni dalla pagina principale.';

  @override
  String get attachFile => 'Allega file';

  @override
  String get uploadImage => 'Carica immagine';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String uploadingFilename(String filename) {
    return 'Caricamento: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Caricamento del file non riuscito: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Attendi il completamento del caricamento degli allegati';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName ridimensionato a $size$dimensions per rientrare nel limite di $limit.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: troppo grande ($size) e non è stato possibile ridimensionarlo. Il limite è $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName è di $fileBytes. I caricamenti superiori a $maxBytes non sono accettati.';
  }

  @override
  String get flagAction => 'Segnala';

  @override
  String get ignoredUsers => 'Utenti ignorati';

  @override
  String get ignoredUsersEmpty => 'Sembra che tu non stia ignorando nessuno.';

  @override
  String get flagPostTitle => 'Segnala messaggio';

  @override
  String get flagReasonOffTopic => 'Fuori tema';

  @override
  String get flagReasonOffTopicText =>
      'Questo post non riguarda la discussione e andrebbe spostato altrove.';

  @override
  String get flagReasonInappropriate => 'Inappropriato';

  @override
  String get flagReasonInappropriateText =>
      'Questo messaggio è offensivo, abusivo o viola la nostra linea di condotta.';

  @override
  String get flagReasonSpam => 'Spam';

  @override
  String get flagReasonSpamText => 'Questo post è pubblicità.';

  @override
  String get flagReasonOther => 'Altro (specifica)';

  @override
  String get flagDetails => 'Dettagli aggiuntivi (facoltativi)';

  @override
  String get flagDetailsNeeded => 'Fornisci qualche dettaglio ai moderatori.';

  @override
  String get communityGuidelines => 'Linee guida della community';

  @override
  String get flagSent =>
      'Grazie per la segnalazione. I moderatori la esamineranno.';

  @override
  String ignoreUser(String name) {
    return 'Ignora $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return 'Non ignorare $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Sei sicuro di voler ignorare $name?';
  }

  @override
  String ignoredUserPost(String name) {
    return 'Un post di $name, che ignori.';
  }

  @override
  String get showPost => 'Mostra post';

  @override
  String get ignoredOnThisPhone =>
      'Questo forum non tiene un elenco degli utenti ignorati, quindi l’app conserva il tuo su questo telefono.';

  @override
  String get stopIgnoring => 'Non ignorare';

  @override
  String get termsBanner =>
      'Abbiamo temporaneamente limitato l’accesso al tuo account durante la verifica dei nuovi termini.';

  @override
  String get termsReview => 'Rivedi';

  @override
  String get termsTitle => 'Aggiornamento dei termini';

  @override
  String get termsIntro =>
      'I termini sono stati aggiornati dalla tua ultima visita';

  @override
  String get readPolicy => 'Leggi';

  @override
  String get acceptTerms => 'Conferma';

  @override
  String get termsAccepted =>
      'Grazie per aver accettato, ora puoi tornare al forum';

  @override
  String get privateDiscussions => 'Discussioni private';

  @override
  String get startPrivateDiscussion => 'Discuti in privato';

  @override
  String privateWith(String names) {
    return 'Con $names';
  }

  @override
  String get addPerson => 'Destinatari';

  @override
  String get choosePerson =>
      'Questa discussione sarà visibile solo agli utenti che scegli qui. È richiesto almeno 1 destinatario (diverso da te).';

  @override
  String get noPrivateDiscussions => 'Sembra che non ci siano discussioni qui.';

  @override
  String get privateOnlyOne =>
      'Questo forum ti consente di scrivere in privato a una sola persona alla volta.';

  @override
  String get messages => 'Messaggi';

  @override
  String get markAllMessagesRead => 'Segna tutto come letto';

  @override
  String get startOfConversation => 'Inizio della conversazione';

  @override
  String get messageCopied => 'Messaggio copiato.';

  @override
  String get newMessage => 'Nuovo messaggio';

  @override
  String get noMessages => 'Ancora nessun messaggio.';

  @override
  String get sendMessage => 'Invia un messaggio';

  @override
  String get messageHint => 'Scrivi un messaggio…';

  @override
  String get messagesLoadFailed => 'Impossibile caricare i messaggi.';

  @override
  String get moderate => 'Modera';

  @override
  String get renameDiscussion => 'Rinomina';

  @override
  String get renameDiscussionTitle => 'Rinomina discussione';

  @override
  String get lockDiscussion => 'Blocca';

  @override
  String get unlockDiscussion => 'Sblocca';

  @override
  String get stickDiscussion => 'Fissa in alto';

  @override
  String get unstickDiscussion => 'Rimuovi dall’alto';

  @override
  String get restore => 'Ripristina';

  @override
  String get deleteForever => 'Cancella per sempre';

  @override
  String get deleteForeverConfirm =>
      'Sei sicuro di volerlo eliminare per sempre? Questa azione è irreversibile.';

  @override
  String get approve => 'Approva';

  @override
  String get unsuspend => 'Revoca sospensione';

  @override
  String get suspend => 'Sospendi';

  @override
  String suspendUserTitle(String username) {
    return 'Sospendi $username';
  }

  @override
  String get suspensionStatus => 'Stato di sospensione';

  @override
  String get notSuspended => 'Non sospeso';

  @override
  String get suspendIndefinitely => 'Sospeso a tempo indeterminato';

  @override
  String get suspendLimitedTime => 'Sospeso per un tempo limitato...';

  @override
  String get suspendDays => 'giorni';

  @override
  String get suspendReasonLabel => 'Motivo della sospensione';

  @override
  String get suspendMessageLabel => 'Mostra messaggio per l\'utente';

  @override
  String get optional => 'Opzionale';

  @override
  String suspendedUntil(String date) {
    return 'Sospeso fino al $date';
  }

  @override
  String get suspendedIndefinitely => 'Sospeso a tempo indeterminato';

  @override
  String youAreSuspended(String date) {
    return 'Questa sospensione sarà attiva fino al $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Questo account è sospeso';

  @override
  String get awaitingApproval => 'In attesa di approvazione';

  @override
  String get badgeSticky => 'In evidenza';

  @override
  String get badgeLocked => 'Chiusa';

  @override
  String get badgeHidden => 'Nascosto';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count post',
      one: '1 post',
    );
    return '$user ha unito $_temp0 da $titles in questa discussione.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count post',
      one: '1 post',
    );
    return '$user ha separato $_temp0 in $title.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count post',
      one: '1 post',
    );
    return '$user ha separato $_temp0 da $title.';
  }

  @override
  String get errorNoConnection =>
      'Sembra esserci un problema con la tua connessione. Controlla la rete e riprova.';

  @override
  String get errorTimedOut =>
      'Il forum ha impiegato troppo tempo a rispondere. Riprova.';

  @override
  String get errorBlocked =>
      'Il firewall del forum ha bloccato l\'app. Riprova più tardi o apri il forum in un browser.';

  @override
  String get errorNotFound => 'La risorsa richiesta non è stata trovata.';

  @override
  String get errorRateLimited =>
      'Stai scrivendo un po’ troppo in fretta. Riprova tra qualche secondo.';

  @override
  String get errorForumDown =>
      'Il forum non risponde al momento. Riprova più tardi.';

  @override
  String get errorNotAllowed => 'Non hai il permesso di farlo.';

  @override
  String get errorUnknown => 'Oops! Qualcosa è andato storto. Riprova.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voti assegnati',
      one: '$count voto assegnato',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opzioni',
      one: '$count opzione',
    );
    return 'Il sondaggio consente di votare per $_temp0.';
  }

  @override
  String get pollEnded => 'Questo sondaggio è terminato.';

  @override
  String pollEndsOn(String date) {
    return 'Fine sondaggio: $date.';
  }

  @override
  String get pollResultsAfterVoting => 'Vedrai i risultati dopo aver votato.';

  @override
  String get pollResultsWhenClosed =>
      'Vedrai i risultati alla chiusura della votazione.';

  @override
  String get pollVote => 'Vota';

  @override
  String get pollRemoveVote => 'Ritira il mio voto';

  @override
  String get pollSeeVoters => 'Visualizza votanti';

  @override
  String get pollNoVotes => 'Nessun voto';

  @override
  String get poll => 'Sondaggio';

  @override
  String get pollNeedsQuestion => 'Devi includere una domanda';

  @override
  String get pollNeedsAnswers => 'Devi includere un minimo di 2 risposte';

  @override
  String get pollEndInPast => 'Scegli una chiusura nel futuro.';

  @override
  String get pollQuestion => 'Domanda';

  @override
  String pollAnswer(int number) {
    return 'Risposta $number';
  }

  @override
  String get pollRemoveAnswer => 'Rimuovi questa risposta';

  @override
  String get pollAddAnswer => 'Aggiungi risposta';

  @override
  String get pollMultipleChoice =>
      'Consenti alle persone di votare per più opzioni';

  @override
  String get pollChoicesAllowed => 'Numero massimo di voti per utente';

  @override
  String get pollAnyNumber => 'Senza limite';

  @override
  String get pollPublic => 'Consenti alle persone di vedere chi ha votato';

  @override
  String get pollAllowChangeVote =>
      'Consenti agli utenti di modificare il loro voto';

  @override
  String get pollCloses => 'Data fine sondaggio (opzionale)';

  @override
  String get pollNeverCloses => 'Mai';

  @override
  String get pollHideVotes => 'Nascondi i voti fino alla fine del sondaggio';

  @override
  String get pollHideVotesNeedsEnd =>
      'Prima scegli quando chiude la votazione.';

  @override
  String get addPoll => 'Aggiungi sondaggio';

  @override
  String get submit => 'Invia';

  @override
  String get editPoll => 'Modifica sondaggio';

  @override
  String get removePoll => 'Rimuovi sondaggio';

  @override
  String get draftSaved => 'Salvato!';

  @override
  String get draftSavedWithoutPoll =>
      'Bozza salvata, senza il sondaggio: le bozze non conservano i sondaggi.';

  @override
  String get draftNeedsText => 'Scrivi qualcosa per salvarlo come bozza.';

  @override
  String get drafts => 'Bozze';

  @override
  String get draftsLoadFailed => 'Impossibile caricare le tue bozze';

  @override
  String get noDrafts =>
      'Non hai salvato alcuna bozza. Chiudi un messaggio che stai scrivendo e scegli «Salva bozza» per conservarlo qui.';

  @override
  String draftReplyTo(String title) {
    return 'Risposta a $title';
  }

  @override
  String get draftUntitled => 'Discussione senza titolo';

  @override
  String get deleteDraftQuestion => 'Sei sicuro di voler cancellare la bozza?';

  @override
  String get deleteDraft => 'Elimina bozza';
}
