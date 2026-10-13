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

  @override
  String get bold => 'Vet';

  @override
  String get underline => 'Onderstreept';

  @override
  String get strikethrough => 'Doorgehaald';

  @override
  String get bulletList => 'Opsomming';

  @override
  String get numberedList => 'Genummerde lijst';

  @override
  String get listItem => 'Lijstitem';

  @override
  String get mentionUser => 'Gebruiker vermelden';

  @override
  String get title => 'Titel';

  @override
  String get content => 'Inhoud';

  @override
  String get send => 'Verzenden';

  @override
  String get save => 'Opslaan';

  @override
  String get formatting => 'Opmaak';

  @override
  String get pleaseEnterTitle => 'Voer een titel in';

  @override
  String get pleaseEnterContent => 'Voer inhoud in';

  @override
  String get composerTitleHint => 'Schrijf je titel…';

  @override
  String get composerContentHint => 'Schrijf je inhoud…';

  @override
  String get composerFormattingHint => 'Opmaakopties openen';

  @override
  String get searchUsers => 'Gebruikers zoeken...';

  @override
  String get startDiscussion => 'Discussie starten';

  @override
  String get editPost => 'Bericht bewerken';

  @override
  String get postingThrottled =>
      'Je plaatst te snel. Wacht een paar seconden en probeer het opnieuw.';

  @override
  String get postAwaitingApproval =>
      'Verzonden. Het verschijnt zodra een moderator het goedkeurt.';

  @override
  String get chooseTags => 'Tags kiezen';

  @override
  String get primaryTags => 'Hoofdtags';

  @override
  String get secondaryTags => 'Meer tags';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kies $count hoofdtags.',
      one: 'Kies een hoofdtag.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kies hoogstens $count hoofdtags.',
      one: 'Kies maar één hoofdtag.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kies nog $count tags.',
      one: 'Kies nog 1 tag.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kies hoogstens $count andere tags.',
      one: 'Kies hoogstens 1 andere tag.',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Klaar';

  @override
  String get noMembersFound => 'Geen leden gevonden.';

  @override
  String get memberSearchNotAllowed =>
      'Dit forum staat het zoeken naar leden niet toe.';

  @override
  String get editLoadFailed =>
      'Dit bericht kon niet worden geladen om te bewerken.';

  @override
  String get like => 'Vind ik leuk';

  @override
  String get unlike => 'Vind ik niet meer leuk';

  @override
  String get react => 'Reageren';

  @override
  String get reactions => 'Reacties';

  @override
  String get bookmark => 'Bladwijzer toevoegen';

  @override
  String get removeBookmark => 'Bladwijzer verwijderen';

  @override
  String get bookmarks => 'Bladwijzers';

  @override
  String get noBookmarks => 'Nog geen bladwijzers.';

  @override
  String get chooseBestAnswer => 'Kiezen als beste antwoord';

  @override
  String get removeBestAnswer => 'Beste antwoord verwijderen';

  @override
  String get notificationSettings => 'Meldingen voor deze discussie';

  @override
  String get notFollowing => 'Niet volgen';

  @override
  String get notFollowingHint => 'Alleen een melding bij een @vermelding.';

  @override
  String get followingHint => 'Een melding bij alle reacties.';

  @override
  String get ignoring => 'Negeren';

  @override
  String get ignoringHint =>
      'Nooit een melding, en verbergen in de discussielijsten.';

  @override
  String get tagFollowingHint => 'Een melding bij nieuwe discussies.';

  @override
  String get lurking => 'Meelezen';

  @override
  String get lurkingHint =>
      'Een melding bij nieuwe discussies en elke reactie.';

  @override
  String get tagIgnoringHint => 'Nooit een melding over discussies hier.';

  @override
  String get hidden => 'Verborgen';

  @override
  String get hiddenHint =>
      'De discussies van deze tag verbergen in de discussielijsten.';

  @override
  String get attachFile => 'Bestand bijvoegen';

  @override
  String get uploadImage => 'Afbeelding uploaden';

  @override
  String get takePhoto => 'Foto maken';

  @override
  String uploadingFilename(String filename) {
    return 'Uploaden: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Bestand uploaden mislukt: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Wacht tot de bijlagen klaar zijn met uploaden';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName verkleind tot $size$dimensions om binnen de limiet van $limit te blijven.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: te groot ($size) en kon niet worden verkleind. De limiet is $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName is $fileBytes. Dit forum staat maximaal $maxBytes toe.';
  }

  @override
  String get flagAction => 'Melden';

  @override
  String get ignoredUsers => 'Genegeerde gebruikers';

  @override
  String get ignoredUsersEmpty => 'Je negeert niemand.';

  @override
  String get flagPostTitle => 'Bericht melden';

  @override
  String get flagReasonOffTopic => 'Off-topic';

  @override
  String get flagReasonOffTopicText =>
      'Dit bericht hoort niet bij deze discussie en zou ergens anders moeten staan.';

  @override
  String get flagReasonInappropriate => 'Ongepast';

  @override
  String get flagReasonInappropriateText =>
      'Dit bericht is beledigend, kwetsend of in strijd met de communityrichtlijnen.';

  @override
  String get flagReasonSpam => 'Spam';

  @override
  String get flagReasonSpamText => 'Dit bericht is reclame.';

  @override
  String get flagReasonOther => 'Anders (licht toe)';

  @override
  String get flagDetails => 'Extra toelichting (optioneel)';

  @override
  String get flagDetailsNeeded => 'Geef de moderators wat meer details.';

  @override
  String get communityGuidelines => 'Communityrichtlijnen';

  @override
  String get flagSent =>
      'Bedankt voor je melding. Onze moderators kijken ernaar.';

  @override
  String ignoreUser(String name) {
    return '$name negeren';
  }

  @override
  String stopIgnoringUser(String name) {
    return '$name niet meer negeren';
  }

  @override
  String ignoreUserConfirm(String name) {
    return '$name negeren? Hun berichten worden ingeklapt. Je kunt dit ongedaan maken vanuit je account.';
  }

  @override
  String ignoredUserPost(String name) {
    return 'Een bericht van $name, die je negeert.';
  }

  @override
  String get showPost => 'Bericht tonen';

  @override
  String get ignoredOnThisPhone =>
      'Dit forum houdt geen lijst van genegeerde gebruikers bij, dus de app bewaart de jouwe op deze telefoon.';

  @override
  String get stopIgnoring => 'Niet meer negeren';

  @override
  String get termsBanner =>
      'Accepteer de bijgewerkte voorwaarden van dit forum om weer te kunnen posten.';

  @override
  String get termsReview => 'Bekijken';

  @override
  String get termsTitle => 'Bijgewerkte voorwaarden';

  @override
  String get termsIntro =>
      'Accepteer het bijgewerkte beleid van het forum voordat je weer post.';

  @override
  String get readPolicy => 'Lezen';

  @override
  String get acceptTerms => 'Accepteren';

  @override
  String get termsAccepted => 'Bedankt. Je kunt weer posten.';

  @override
  String get privateDiscussions => 'Privédiscussies';

  @override
  String get startPrivateDiscussion => 'Een privédiscussie starten';

  @override
  String privateWith(String names) {
    return 'Met $names';
  }

  @override
  String get addPerson => 'Iemand toevoegen';

  @override
  String get choosePerson => 'Kies aan wie je schrijft.';

  @override
  String get noPrivateDiscussions => 'Nog geen privédiscussies.';

  @override
  String get privateOnlyOne =>
      'Op dit forum kun je privé maar naar één persoon tegelijk schrijven.';

  @override
  String get messages => 'Berichten';

  @override
  String get newMessage => 'Nieuw bericht';

  @override
  String get noMessages => 'Nog geen berichten.';

  @override
  String get sendMessage => 'Een bericht sturen';

  @override
  String get messageHint => 'Schrijf een bericht…';

  @override
  String get messagesLoadFailed => 'De berichten konden niet worden geladen.';

  @override
  String get moderate => 'Modereren';

  @override
  String get renameDiscussion => 'Hernoemen';

  @override
  String get lockDiscussion => 'Vergrendelen';

  @override
  String get unlockDiscussion => 'Ontgrendelen';

  @override
  String get stickDiscussion => 'Vastzetten';

  @override
  String get unstickDiscussion => 'Losmaken';

  @override
  String get restore => 'Herstellen';

  @override
  String get deleteForever => 'Definitief verwijderen';

  @override
  String get deleteForeverConfirm =>
      'Definitief verwijderen? Dit kan niet ongedaan worden gemaakt.';

  @override
  String get approve => 'Goedkeuren';

  @override
  String get unsuspend => 'Schorsing opheffen';

  @override
  String suspendedUntil(String date) {
    return 'Geschorst tot $date';
  }

  @override
  String get suspendedIndefinitely => 'Voor onbepaalde tijd geschorst';

  @override
  String youAreSuspended(String date) {
    return 'Je bent geschorst tot $date.';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Je bent geschorst.';

  @override
  String get awaitingApproval => 'Wacht op goedkeuring';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berichten',
      one: '1 bericht',
    );
    return '$user heeft $_temp0 uit $titles met deze discussie samengevoegd.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berichten',
      one: '1 bericht',
    );
    return '$user heeft $_temp0 afgesplitst naar $title.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berichten',
      one: '1 bericht',
    );
    return '$user heeft $_temp0 afgesplitst van $title.';
  }

  @override
  String get errorNoConnection =>
      'Het forum is niet bereikbaar. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get errorTimedOut =>
      'Het forum reageerde te traag. Probeer het opnieuw.';

  @override
  String get errorBlocked =>
      'De firewall van het forum heeft de app geblokkeerd. Probeer het later opnieuw of open het forum in een browser.';

  @override
  String get errorNotFound => 'Dit bestaat niet of is verwijderd.';

  @override
  String get errorRateLimited =>
      'Je doet dat te vaak. Wacht even en probeer het opnieuw.';

  @override
  String get errorForumDown =>
      'Het forum reageert momenteel niet. Probeer het later opnieuw.';

  @override
  String get errorNotAllowed => 'Je hebt geen toestemming om dat te doen.';

  @override
  String get errorUnknown => 'Er ging iets mis. Probeer het opnieuw.';
}
