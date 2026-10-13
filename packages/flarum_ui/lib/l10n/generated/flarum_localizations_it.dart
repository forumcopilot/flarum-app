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
  String get loadEarlierPosts => 'Carica i post precedenti';

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
  String get someone => 'Qualcuno';

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
  String get viewNewest => 'Nuove';

  @override
  String discussionReplied(String user, String time) {
    return '$user ha risposto $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user l’ha avviata $time';
  }

  @override
  String get noDiscussions => 'Non ci sono ancora discussioni.';

  @override
  String get discussionsLoadFailed => 'Impossibile caricare le discussioni.';

  @override
  String get tagsLoadFailed => 'Impossibile caricare i tag.';

  @override
  String get signOut => 'Esci';

  @override
  String get account => 'Account';

  @override
  String get createAccount => 'Crea account';

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
  String get noNotificationsYet => 'Ancora nessuna notifica';

  @override
  String notifNewPost(String user, String title) {
    return '$user ha risposto in $title';
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
    return '$user ha menzionato un tuo gruppo in $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user ha rinominato una discussione in $title';
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
    return '$user ha spostato $title in un tag che segui';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user ha avviato una discussione privata con te: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user ha risposto nella discussione privata $title';
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
    return '$user ha scelto il tuo post come migliore risposta in $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user ha scelto una migliore risposta in $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Scegli una migliore risposta in $title';
  }

  @override
  String notifMessage(String user) {
    return '$user ti ha inviato un messaggio';
  }

  @override
  String get notifSuspended => 'Il tuo account è stato sospeso';

  @override
  String get notifUnsuspended =>
      'La sospensione del tuo account è stata revocata';

  @override
  String get notifExport => 'L’esportazione dei tuoi dati è pronta';

  @override
  String get notifOther => 'Nuova notifica';

  @override
  String get aDiscussion => 'una discussione';

  @override
  String get notificationsLoadFailed => 'Impossibile caricare le notifiche.';

  @override
  String get notificationsSignIn => 'Accedi per vedere le tue notifiche.';

  @override
  String get markAllRead => 'Segna tutto come letto';

  @override
  String get posts => 'Post';

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
  String get noPostsYet => 'Ancora nessun post.';

  @override
  String searchFailedWithError(String error) {
    return 'Ricerca fallita: $error';
  }

  @override
  String get searchHint => 'Cerca discussioni e post';

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
  String get repliesTitle => 'Risposte';

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
  String get bestAnswer => 'Migliore risposta';

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
  String get mentionUser => 'Menziona utente';

  @override
  String get title => 'Titolo';

  @override
  String get content => 'Contenuto';

  @override
  String get send => 'Invia';

  @override
  String get save => 'Salva';

  @override
  String get formatting => 'Formattazione';

  @override
  String get pleaseEnterTitle => 'Inserisci un titolo';

  @override
  String get pleaseEnterContent => 'Inserisci del contenuto';

  @override
  String get composerTitleHint => 'Scrivi il tuo titolo...';

  @override
  String get composerContentHint => 'Scrivi il tuo contenuto...';

  @override
  String get composerFormattingHint => 'Apri le opzioni di formattazione';

  @override
  String get searchUsers => 'Cerca utenti...';

  @override
  String get startDiscussion => 'Avvia una discussione';

  @override
  String get editPost => 'Modifica post';

  @override
  String get postingThrottled =>
      'Stai pubblicando troppo in fretta. Attendi qualche secondo e riprova.';

  @override
  String get postAwaitingApproval =>
      'Inviato. Apparirà quando un moderatore lo approverà.';

  @override
  String get chooseTags => 'Scegli i tag';

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
  String get done => 'Fatto';

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
  String get chooseBestAnswer => 'Scegli come migliore risposta';

  @override
  String get removeBestAnswer => 'Rimuovi migliore risposta';

  @override
  String get notificationSettings => 'Notifiche per questa discussione';

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
      'Non ricevere mai notifiche e nascondila dagli elenchi.';

  @override
  String get tagFollowingHint => 'Ricevi notifiche per le nuove discussioni.';

  @override
  String get lurking => 'In osservazione';

  @override
  String get lurkingHint =>
      'Ricevi notifiche per le nuove discussioni e per ogni risposta.';

  @override
  String get tagIgnoringHint =>
      'Non ricevere mai notifiche per le discussioni qui.';

  @override
  String get hidden => 'Nascosto';

  @override
  String get hiddenHint =>
      'Nascondi le discussioni di questo tag dagli elenchi.';

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
    return '$fileName è di $fileBytes. Questo forum consente fino a $maxBytes.';
  }

  @override
  String get flagAction => 'Segnala';

  @override
  String get ignoredUsers => 'Utenti ignorati';

  @override
  String get ignoredUsersEmpty => 'Non stai ignorando nessuno.';

  @override
  String get flagPostTitle => 'Segnala post';

  @override
  String get flagReasonOffTopic => 'Fuori tema';

  @override
  String get flagReasonOffTopicText =>
      'Questo post non riguarda la discussione e andrebbe spostato altrove.';

  @override
  String get flagReasonInappropriate => 'Inappropriato';

  @override
  String get flagReasonInappropriateText =>
      'Questo post è offensivo, abusivo o viola le linee guida della community.';

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
    return 'Smetti di ignorare $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Ignorare $name? I suoi post verranno compressi. Puoi annullare dal tuo account.';
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
  String get stopIgnoring => 'Smetti di ignorare';

  @override
  String get termsBanner =>
      'Accetta i termini aggiornati di questo forum per tornare a pubblicare.';

  @override
  String get termsReview => 'Rivedi';

  @override
  String get termsTitle => 'Termini aggiornati';

  @override
  String get termsIntro =>
      'Prima di pubblicare di nuovo, accetta le norme aggiornate del forum.';

  @override
  String get readPolicy => 'Leggi';

  @override
  String get acceptTerms => 'Accetta';

  @override
  String get termsAccepted => 'Grazie. Ora puoi pubblicare di nuovo.';

  @override
  String get privateDiscussions => 'Discussioni private';

  @override
  String get startPrivateDiscussion => 'Avvia una discussione privata';

  @override
  String privateWith(String names) {
    return 'Con $names';
  }

  @override
  String get addPerson => 'Aggiungi qualcuno';

  @override
  String get choosePerson => 'Scegli a chi scrivere.';

  @override
  String get noPrivateDiscussions => 'Ancora nessuna discussione privata.';

  @override
  String get privateOnlyOne =>
      'Questo forum ti consente di scrivere in privato a una sola persona alla volta.';
}
