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
  String get copyLink => 'Link kopiëren';

  @override
  String get linkCopied => 'Link gekopieerd.';

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
  String get edited => 'Bijgewerkt';

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
  String get loadEarlierPosts => 'Meer laden';

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
  String get someone => '[verwijderd]';

  @override
  String get latest => 'Nieuwste';

  @override
  String get unread => 'Ongelezen';

  @override
  String get search => 'Zoeken';

  @override
  String get signIn => 'Inloggen';

  @override
  String get logInToReply => 'Log in om te reageren';

  @override
  String get cannotReply => 'Je kan niet reageren';

  @override
  String get profile => 'Profiel';

  @override
  String get following => 'Volgend';

  @override
  String get follow => 'Volgen';

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
  String get noDiscussions =>
      'Het lijkt erop dat er hier geen discussies zijn.';

  @override
  String get discussionsLoadFailed => 'Discussies konden niet worden geladen.';

  @override
  String get tagsLoadFailed => 'De tags konden niet worden geladen.';

  @override
  String get signOut => 'Uitloggen';

  @override
  String logOutQuestion(String forum) {
    return 'Weet je zeker dat je wilt uitloggen bij $forum?';
  }

  @override
  String get account => 'Account';

  @override
  String get createAccount => 'Registreren';

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
  String get noNotificationsYet => 'Geen meldingen';

  @override
  String notifNewPost(String user, String title) {
    return '$user heeft gereageerd in $title';
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
    return '$user vermeldde in $title een groep waarvan je lid bent';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user heeft de titel veranderd in $title';
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
    return '$user heeft de tag van $title veranderd';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user heeft een nieuwe privédiscussie met jou gestart: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user heeft een bericht geplaatst in een privédiscussie waar jij deel van bent: $title';
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
    return 'Je bericht is in $title als beste antwoord gemarkeerd door $user';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user heeft een beste antwoord geselecteerd in $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Selecteer een beste antwoord in $title zodra je vraag is beantwoord';
  }

  @override
  String notifMessage(String user) {
    return '$user heeft je een bericht gestuurd';
  }

  @override
  String get notifSuspended => 'Je account is geschorst';

  @override
  String get notifUnsuspended => 'Je schorsing is ongedaan gemaakt';

  @override
  String get notifExport =>
      'Je gegevensexport is nu klaar om te worden gedownload.';

  @override
  String get notifOther => 'Nieuwe melding';

  @override
  String notifLineNewPost(String user) {
    return '$user heeft gereageerd';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user vindt je bericht leuk';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user heeft op je bericht gereageerd met een emoji';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user heeft gereageerd op je bericht';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user heeft je genoemd';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user vermelde een groep waarvan je lid bent';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user heeft de titel veranderd';
  }

  @override
  String notifLineLocked(String user) {
    return '$user heeft gesloten';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user is ermee begonnen';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user heeft de tag veranderd';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user is een nieuwe privédiscussie met je begonnen';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user heeft een bericht geplaatst in een privédiscussie waar je deel van uitmaakt';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user heeft je toegevoegd aan een privédiscussie';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user heeft je uit een privédiscussie verwijderd';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user heeft alle ontvangers verwijderd en de discussie openbaar gemaakt';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Je bericht is als beste antwoord gemarkeerd door $user';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user heeft een beste antwoord geselecteerd in deze discussie';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Selecteer een Beste Antwoord zodra je vraag is beantwoord';

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
  String get markAllDiscussionsReadQuestion =>
      'Weet je zeker dat je alle discussies als gelezen wilt markeren?';

  @override
  String get hideWelcomeMessage => 'Welkomstbericht verbergen';

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
  String get noPostsYet => 'Zo te zien zijn er hier geen berichten.';

  @override
  String searchFailedWithError(String error) {
    return 'Zoeken mislukt: $error';
  }

  @override
  String get searchHint => 'Zoeken';

  @override
  String noResultsFor(String query) {
    return 'Er lijken geen resultaten te zijn voor ‘$query’.';
  }

  @override
  String get light => 'Lichte modus';

  @override
  String get dark => 'Donkere modus';

  @override
  String get appearance => 'Kleurenschema';

  @override
  String get appearanceSystem => 'Systeemvoorkeur';

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
  String get repliesTitle => 'Reacties op dit bericht';

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
  String get goToBestAnswer => 'Bekijk beste antwoord';

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
  String get mentionUser => 'Vermeld een gebruiker, groep of bericht';

  @override
  String get title => 'Titel';

  @override
  String get content => 'Inhoud';

  @override
  String get send => 'Verzend bericht';

  @override
  String get postReply => 'Plaats reactie';

  @override
  String get postDiscussion => 'Plaatsen';

  @override
  String get postPrivateDiscussion => 'Start privédiscussie';

  @override
  String get save => 'Wijzigingen opslaan';

  @override
  String get formatting => 'Opmaak';

  @override
  String get pleaseEnterTitle => 'Voer een titel in';

  @override
  String get pleaseEnterContent => 'Voer inhoud in';

  @override
  String get composerTitleHint => 'Discussietitel';

  @override
  String get privateDiscussionTitleHint => 'Titel';

  @override
  String get composerContentHint => 'Schrijf een bericht...';

  @override
  String get composerReplyHint => 'Schrijf een reactie...';

  @override
  String get composerFormattingHint => 'Opmaakopties openen';

  @override
  String get searchUsers => 'Gebruikers zoeken...';

  @override
  String get startDiscussion => 'Start een discussie';

  @override
  String get editPost => 'Bericht bewerken';

  @override
  String get postingThrottled =>
      'Je gaat een beetje te snel. Probeer het over een paar seconden nog eens.';

  @override
  String get postAwaitingApproval =>
      'Verzonden. Het verschijnt zodra een moderator het goedkeurt.';

  @override
  String get chooseTags => 'Kies tags';

  @override
  String get ok => 'Oké';

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
  String get noMembersFound =>
      'Geen gebruikers gevonden die overeenkomen met je zoekopdracht.';

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
  String likedByOne(String a) {
    return '$a vindt dit leuk.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a en $b vinden dit leuk.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others anderen',
      one: '1 ander',
    );
    return '$a en $_temp0 vinden dit leuk.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others anderen',
      one: '1 ander',
    );
    return '$a, $b en $_temp0 vinden dit leuk.';
  }

  @override
  String get likedByYou => 'Jij vindt dit leuk.';

  @override
  String likedByYouAndOne(String a) {
    return 'Jij en $a vinden dit leuk.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others anderen',
      one: '1 ander',
    );
    return 'Jij, $a en $_temp0 vinden dit leuk.';
  }

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
  String get chooseBestAnswer => 'Selecteer als beste antwoord';

  @override
  String get removeBestAnswer => 'Beste antwoord ongedaan maken';

  @override
  String get notFollowing => 'Niet volgend';

  @override
  String get notFollowingHint => 'Alleen een melding bij een @vermelding.';

  @override
  String get followingHint => 'Een melding bij alle reacties.';

  @override
  String get ignoring => 'Negeren';

  @override
  String get ignoringHint =>
      'Word niet op de hoogte gesteld. Verberg van de discussielijst.';

  @override
  String get tagFollowingHint =>
      'Geattendeerd worden op alle nieuwe discussies.';

  @override
  String get lurking => 'Meelezen';

  @override
  String get lurkingHint => 'Meldingen van alle nieuwe discussies en reacties.';

  @override
  String get tagIgnoringHint => 'Geen meldingen.';

  @override
  String get hidden => 'Verborgen';

  @override
  String get hiddenHint => 'Verberg discussies op de pagina Alle discussies.';

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
    return '$fileName is $fileBytes. Uploads boven $maxBytes worden niet geaccepteerd.';
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
      'Dit bericht is beledigend, grof of schendt onze communityrichtlijnen.';

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
    return 'Weet je zeker dat je $name wilt negeren?';
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
      'We hebben de toegang tot je account tijdelijk beperkt terwijl je de nieuwe voorwaarden bekijkt.';

  @override
  String get termsReview => 'Bekijken';

  @override
  String get termsTitle => 'Bijgewerkte voorwaarden';

  @override
  String get termsIntro =>
      'De voorwaarden zijn bijgewerkt sinds je laatste bezoek';

  @override
  String get readPolicy => 'Lezen';

  @override
  String get acceptTerms => 'Bevestigen';

  @override
  String get termsAccepted =>
      'Bedankt voor het accepteren, je kunt nu terug naar het forum';

  @override
  String get privateDiscussions => 'Privédiscussies';

  @override
  String get startPrivateDiscussion => 'Bespreek privé';

  @override
  String privateWith(String names) {
    return 'Met $names';
  }

  @override
  String get addPerson => 'Ontvangers';

  @override
  String get choosePerson =>
      'Deze discussie zal alleen zichtbaar zijn voor de gebruikers die je hier kiest. Er is minimaal 1 ontvanger (anders dan jezelf) vereist.';

  @override
  String get noPrivateDiscussions =>
      'Het lijkt erop dat er hier geen discussies zijn.';

  @override
  String get privateOnlyOne =>
      'Op dit forum kun je privé maar naar één persoon tegelijk schrijven.';

  @override
  String get messages => 'Berichten';

  @override
  String get newMessage => 'Stuur een bericht';

  @override
  String get noMessages => 'Geen nieuwe berichten';

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
  String get renameDiscussionTitle => 'Discussie hernoemen';

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
  String get deleteForever => 'Permanent verwijderen';

  @override
  String get deleteForeverConfirm =>
      'Weet je zeker dat je dit voor altijd wilt verwijderen? Deze actie kan niet ongedaan gemaakt worden.';

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
    return 'Deze schorsing is van kracht tot $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'Dit account is geschorst';

  @override
  String get awaitingApproval => 'Wacht op goedkeuring';

  @override
  String get badgeSticky => 'Vastgezet';

  @override
  String get badgeLocked => 'Gesloten';

  @override
  String get badgeHidden => 'Verborgen';

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
      'Er lijkt iets mis te zijn met je verbinding. Controleer je netwerk en probeer het opnieuw.';

  @override
  String get errorTimedOut =>
      'Het forum reageerde te traag. Probeer het opnieuw.';

  @override
  String get errorBlocked =>
      'De firewall van het forum heeft de app geblokkeerd. Probeer het later opnieuw of open het forum in een browser.';

  @override
  String get errorNotFound => 'Het opgevraagde kon niet worden gevonden.';

  @override
  String get errorRateLimited =>
      'Je gaat een beetje te snel. Probeer het over een paar seconden nog eens.';

  @override
  String get errorForumDown =>
      'Het forum reageert momenteel niet. Probeer het later opnieuw.';

  @override
  String get errorNotAllowed => 'Je hebt geen permissie om dat te doen.';

  @override
  String get errorUnknown => 'Oeps! Er is iets misgegaan. Probeer het opnieuw.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmen gegeven',
      one: '1 stem gegeven',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opties',
      one: '$count optie',
    );
    return 'Peiling staat toe om op $_temp0 te stemmen.';
  }

  @override
  String get pollEnded => 'Deze peiling is beëindigd.';

  @override
  String pollEndsOn(String date) {
    return 'Peiling eindigt op $date.';
  }

  @override
  String get pollResultsAfterVoting =>
      'Je ziet de uitslag zodra je hebt gestemd.';

  @override
  String get pollResultsWhenClosed =>
      'Je ziet de uitslag als de stemming sluit.';

  @override
  String get pollVote => 'Stemmen';

  @override
  String get pollRemoveVote => 'Mijn stem intrekken';

  @override
  String get pollSeeVoters => 'Stemmers bekijken';

  @override
  String get pollNoVotes => 'Geen stemmen';

  @override
  String get poll => 'Peiling';

  @override
  String get pollNeedsQuestion => 'Je moet een vraag toevoegen';

  @override
  String get pollNeedsAnswers => 'Je moet minimaal 2 antwoorden toevoegen';

  @override
  String get pollEndInPast => 'Kies een sluitingstijd in de toekomst.';

  @override
  String get pollQuestion => 'Vraag';

  @override
  String pollAnswer(int number) {
    return 'Antwoord $number';
  }

  @override
  String get pollRemoveAnswer => 'Dit antwoord verwijderen';

  @override
  String get pollAddAnswer => 'Antwoord toevoegen';

  @override
  String get pollMultipleChoice => 'Sta toe om op meerdere opties te stemmen';

  @override
  String get pollChoicesAllowed => 'Maximale stemmen per gebruiker';

  @override
  String get pollAnyNumber => 'Onbeperkt';

  @override
  String get pollPublic => 'Mensen laten zien wie er gestemd heeft';

  @override
  String get pollAllowChangeVote => 'Gebruikers toestaan hun stem te wijzigen';

  @override
  String get pollCloses => 'Einddatum peiling (optioneel)';

  @override
  String get pollNeverCloses => 'Nooit';

  @override
  String get pollHideVotes =>
      'Verberg resultaten totdat de peiling is beëindigd';

  @override
  String get pollHideVotesNeedsEnd => 'Kies eerst wanneer de stemming sluit.';

  @override
  String get addPoll => 'Peiling toevoegen';

  @override
  String get submit => 'Versturen';

  @override
  String get editPoll => 'Peiling bewerken';

  @override
  String get removePoll => 'Peiling verwijderen';

  @override
  String get draftSaved => 'Concept opgeslagen.';

  @override
  String get draftSavedWithoutPoll =>
      'Concept opgeslagen, zonder de peiling: concepten bewaren geen peilingen.';

  @override
  String get draftNeedsText => 'Schrijf iets om het als concept op te slaan.';

  @override
  String get drafts => 'Concepten';

  @override
  String get draftsLoadFailed => 'Je concepten konden niet worden geladen';

  @override
  String get noDrafts =>
      'Geen concepten. Sluit een bericht dat je schrijft en kies ‘Concept opslaan’ om het hier te bewaren.';

  @override
  String draftReplyTo(String title) {
    return 'Antwoord op $title';
  }

  @override
  String get draftUntitled => 'Discussie zonder titel';

  @override
  String get deleteDraftQuestion => 'Dit concept verwijderen?';

  @override
  String get deleteDraft => 'Concept verwijderen';
}
