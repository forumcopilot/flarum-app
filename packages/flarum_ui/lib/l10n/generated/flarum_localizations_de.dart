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
  String get signOut => 'Abmelden';

  @override
  String get account => 'Konto';

  @override
  String get createAccount => 'Konto erstellen';

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
      'Alle Benachrichtigungen als gelesen markiert';

  @override
  String get failedToMarkNotificationsRead =>
      'Benachrichtigungen konnten nicht als gelesen markiert werden';

  @override
  String get noNotificationsYet => 'Noch keine Benachrichtigungen';

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
  String get posts => 'Beiträge';

  @override
  String profileJoined(String date) {
    return 'Dabei seit $date';
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
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get searchHint => 'Search discussions and posts';

  @override
  String noResultsFor(String query) {
    return 'Nothing found for “$query”.';
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
    return '$a replied to this.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a and $b replied to this.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others others',
      one: '1 other',
    );
    return '$a, $b and $_temp0 replied to this.';
  }

  @override
  String get repliesTitle => 'Replies';

  @override
  String postNumber(int number) {
    return 'Post #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others others',
      one: '1 other',
    );
    return '$a and $_temp0 replied to this.';
  }
}
