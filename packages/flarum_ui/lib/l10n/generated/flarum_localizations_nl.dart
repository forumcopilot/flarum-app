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
  String get loadEarlierPosts => 'Load earlier posts';

  @override
  String get postHidden => 'This post was deleted.';

  @override
  String get threadLoadFailed => 'Couldn\'t load this discussion.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user changed the title from “$from” to “$to”.';
  }

  @override
  String eventLocked(String user) {
    return '$user locked the discussion.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user unlocked the discussion.';
  }

  @override
  String eventStickied(String user) {
    return '$user stickied the discussion.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user unstickied the discussion.';
  }

  @override
  String eventTagged(String user) {
    return '$user changed the tags.';
  }

  @override
  String eventOther(String user) {
    return '$user changed the discussion.';
  }

  @override
  String get someone => 'Someone';

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
  String get viewNewest => 'Newest';

  @override
  String discussionReplied(String user, String time) {
    return '$user replied $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user started $time';
  }

  @override
  String get noDiscussions => 'No discussions here yet.';

  @override
  String get discussionsLoadFailed => 'Couldn\'t load discussions.';

  @override
  String get tagsLoadFailed => 'Couldn\'t load the tags.';

  @override
  String get signOut => 'Afmelden';

  @override
  String get account => 'Account';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String signInFailedReason(String reason) {
    return 'Couldn\'t sign in: $reason';
  }

  @override
  String get signInHint =>
      'Sign in on the forum\'s own page. The app keeps you signed in until you sign out.';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
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
    return '$user replied to $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user liked your post in $title';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user reacted to your post in $title';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user replied to your post in $title';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user mentioned you in $title';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user mentioned a group you\'re in, in $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user renamed a discussion to $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user locked $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user started $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user moved $title to a tag you follow';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user started a private discussion with you: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user replied to the private discussion $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user added you to the private discussion $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user removed you from the private discussion $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user made $title public';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user chose your post as the best answer in $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user chose a best answer in $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Choose a best answer in $title';
  }

  @override
  String notifMessage(String user) {
    return '$user sent you a message';
  }

  @override
  String get notifSuspended => 'You have been suspended';

  @override
  String get notifUnsuspended => 'Your suspension has been lifted';

  @override
  String get notifExport => 'Your data export is ready';

  @override
  String get notifOther => 'New notification';

  @override
  String get aDiscussion => 'a discussion';

  @override
  String get notificationsLoadFailed => 'Couldn\'t load your notifications.';

  @override
  String get notificationsSignIn => 'Sign in to see your notifications.';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get posts => 'Berichten';

  @override
  String profileJoined(String date) {
    return 'Lid sinds $date';
  }

  @override
  String get discussionsTab => 'Discussions';

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
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
      other: '$comments posts',
      one: '1 post',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'Couldn\'t load this profile.';

  @override
  String get noPostsYet => 'No posts yet.';

  @override
  String searchFailedWithError(String error) {
    return 'Zoeken mislukt: $error';
  }

  @override
  String get searchHint => 'Search discussions and posts';

  @override
  String noResultsFor(String query) {
    return 'Nothing found for “$query”.';
  }
}
