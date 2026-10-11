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
}
