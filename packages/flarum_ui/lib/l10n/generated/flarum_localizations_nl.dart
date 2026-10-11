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
  String get loadEarlierPosts => 'Eerdere berichten laden';

  @override
  String get postHidden => 'Dit bericht is verwijderd.';

  @override
  String get threadLoadFailed => 'Deze discussie kon niet worden geladen.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user heeft de titel gewijzigd van ‘$from’ in ‘$to’.';
  }

  @override
  String eventLocked(String user) {
    return '$user heeft de discussie gesloten.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user heeft de discussie heropend.';
  }

  @override
  String eventStickied(String user) {
    return '$user heeft de discussie vastgezet.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user heeft de discussie losgemaakt.';
  }

  @override
  String eventTagged(String user) {
    return '$user heeft de tags gewijzigd.';
  }

  @override
  String eventOther(String user) {
    return '$user heeft de discussie gewijzigd.';
  }

  @override
  String get someone => 'Iemand';

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
  String get viewNewest => 'Nieuw';

  @override
  String discussionReplied(String user, String time) {
    return '$user reageerde $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user begon $time';
  }

  @override
  String get noDiscussions => 'Hier zijn nog geen discussies.';

  @override
  String get discussionsLoadFailed => 'Discussies konden niet worden geladen.';

  @override
  String get tagsLoadFailed => 'De tags konden niet worden geladen.';

  @override
  String get signOut => 'Afmelden';

  @override
  String get account => 'Account';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String signInFailedReason(String reason) {
    return 'Inloggen mislukt: $reason';
  }

  @override
  String get signInHint =>
      'Log in op de pagina van het forum zelf. De app houdt je ingelogd tot je uitlogt.';

  @override
  String signedInAs(String name) {
    return 'Ingelogd als $name';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Alle meldingen gemarkeerd als gelezen';

  @override
  String get failedToMarkNotificationsRead =>
      'Meldingen markeren als gelezen mislukt';

  @override
  String get noNotificationsYet => 'Nog geen meldingen';

  @override
  String notifNewPost(String user, String title) {
    return '$user reageerde in $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user vindt je bericht in $title leuk';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user gaf een reactie op je bericht in $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user reageerde op je bericht in $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user noemde je in $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user noemde een groep waar je in zit, in $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user heeft een discussie hernoemd naar $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user heeft $title gesloten';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user is $title begonnen';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user heeft $title verplaatst naar een tag die je volgt';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user is een privédiscussie met je begonnen: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user reageerde in de privédiscussie $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user heeft je toegevoegd aan de privédiscussie $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user heeft je verwijderd uit de privédiscussie $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user heeft $title openbaar gemaakt';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user koos je bericht als beste antwoord in $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user koos een beste antwoord in $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Kies een beste antwoord in $title';
  }

  @override
  String notifMessage(String user) {
    return '$user heeft je een bericht gestuurd';
  }

  @override
  String get notifSuspended => 'Je account is geschorst';

  @override
  String get notifUnsuspended => 'Je schorsing is opgeheven';

  @override
  String get notifExport => 'Je gegevensexport staat klaar';

  @override
  String get notifOther => 'Nieuwe melding';

  @override
  String get aDiscussion => 'een discussie';

  @override
  String get notificationsLoadFailed =>
      'Je meldingen konden niet worden geladen.';

  @override
  String get notificationsSignIn => 'Log in om je meldingen te zien.';

  @override
  String get markAllRead => 'Alles als gelezen markeren';

  @override
  String get posts => 'Berichten';

  @override
  String profileJoined(String date) {
    return 'Lid sinds $date';
  }

  @override
  String get discussionsTab => 'Discussies';

  @override
  String lastSeen(String time) {
    return 'Laatst gezien $time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions discussies',
      one: '1 discussie',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments berichten',
      one: '1 bericht',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Dit profiel kon niet worden geladen.';

  @override
  String get noPostsYet => 'Nog geen berichten.';

  @override
  String searchFailedWithError(String error) {
    return 'Zoeken mislukt: $error';
  }

  @override
  String get searchHint => 'Zoek in discussies en berichten';

  @override
  String noResultsFor(String query) {
    return 'Niets gevonden voor ‘$query’.';
  }

  @override
  String get light => 'Licht';

  @override
  String get dark => 'Donker';

  @override
  String get appearance => 'Weergave';

  @override
  String get appearanceSystem => 'Systeemstandaard';

  @override
  String repliedByOne(String a) {
    return '$a reageerde hierop.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a en $b reageerden hierop.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others anderen',
      one: '1 ander',
    );
    return '$a, $b en $_temp0 reageerden hierop.';
  }

  @override
  String get repliesTitle => 'Reacties';

  @override
  String postNumber(int number) {
    return 'Bericht #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others anderen',
      one: '1 ander',
    );
    return '$a en $_temp0 reageerden hierop.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user heeft $tags toegevoegd.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user heeft $tags verwijderd.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user heeft $added toegevoegd en $removed verwijderd.';
  }

  @override
  String get privateDiscussion => 'Privédiscussie';

  @override
  String get bestAnswer => 'Beste antwoord';

  @override
  String get goToBestAnswer => 'Naar het beste antwoord';

  @override
  String get answered => 'Beantwoord';

  @override
  String eventRecipientsChanged(String user) {
    return '$user heeft de deelnemers aan deze privédiscussie gewijzigd.';
  }

  @override
  String get noTagsOnForum => 'Dit forum gebruikt geen tags.';

  @override
  String get permissionRequired => 'Toestemming vereist';
}
