import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flarum_localizations_de.dart';
import 'flarum_localizations_en.dart';
import 'flarum_localizations_es.dart';
import 'flarum_localizations_fr.dart';
import 'flarum_localizations_it.dart';
import 'flarum_localizations_ja.dart';
import 'flarum_localizations_ko.dart';
import 'flarum_localizations_nl.dart';
import 'flarum_localizations_pt.dart';
import 'flarum_localizations_ru.dart';
import 'flarum_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlarumLocalizations
/// returned by `FlarumLocalizations.of(context)`.
///
/// Applications need to include `FlarumLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/flarum_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlarumLocalizations.localizationsDelegates,
///   supportedLocales: FlarumLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FlarumLocalizations.supportedLocales
/// property.
abstract class FlarumLocalizations {
  FlarumLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlarumLocalizations? of(BuildContext context) {
    return Localizations.of<FlarumLocalizations>(context, FlarumLocalizations);
  }

  static const LocalizationsDelegate<FlarumLocalizations> delegate =
      _FlarumLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// Name shown for a file in a post or chat message that has no name of its own
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachmentDefaultName;

  /// Menu item to share content
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Status message when downloading file
  ///
  /// In en, this message translates to:
  /// **'Downloading {filename}...'**
  String downloading(String filename);

  /// Button tooltip: download a file from a post or chat message and open it (Discourse lightbox.download)
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Error message when downloading file fails
  ///
  /// In en, this message translates to:
  /// **'Error downloading {filename}: {error}'**
  String errorDownloading(String filename, String error);

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// Menu item to view content on web browser
  ///
  /// In en, this message translates to:
  /// **'View on Web'**
  String get viewOnWeb;

  /// Accessible label for an audio or video pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get mediaPause;

  /// Accessible label for an audio or video play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get mediaPlay;

  /// Full-screen video player: the video could not be played and the player gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get failedToLoadVideo;

  /// UI text: Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @spoiler.
  ///
  /// In en, this message translates to:
  /// **'Spoiler'**
  String get spoiler;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// File type label under an attached file's name (shown in capitals): a compressed archive (zip, rar, 7z…)
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get fileTypeArchive;

  /// File type label under an attached file's name (shown in capitals): an audio file
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get fileTypeAudio;

  /// File type label under an attached file's name (shown in capitals) when the type is unknown
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileTypeFile;

  /// File type label under an attached file's name (shown in capitals): a plain text file
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fileTypeText;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// UI text: edited
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// Disclosure under a post listing its direct replies
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reply} other{{count} replies}}'**
  String nReplies(int count);

  /// Profile summary: number of likes on a topic/reply row, or between the user and another person ('Most liked by')
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 like} other{{count} likes}}'**
  String summaryLikeCount(int count);

  /// UI text: Load more
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// Screen-reader label of a user row in the who-reacted sheet
  ///
  /// In en, this message translates to:
  /// **'View profile of {username}'**
  String viewProfileOfUser(String username);

  /// Button at the top of a discussion opened part-way down: loads the posts before
  ///
  /// In en, this message translates to:
  /// **'Load earlier posts'**
  String get loadEarlierPosts;

  /// Shown in place of a deleted (hidden) post
  ///
  /// In en, this message translates to:
  /// **'This post was deleted.'**
  String get postHidden;

  /// Error shown when a discussion fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this discussion.'**
  String get threadLoadFailed;

  /// Event post: someone renamed the discussion
  ///
  /// In en, this message translates to:
  /// **'{user} changed the title from “{from}” to “{to}”.'**
  String eventRenamed(String user, String from, String to);

  /// Event post
  ///
  /// In en, this message translates to:
  /// **'{user} locked the discussion.'**
  String eventLocked(String user);

  /// Event post
  ///
  /// In en, this message translates to:
  /// **'{user} unlocked the discussion.'**
  String eventUnlocked(String user);

  /// Event post
  ///
  /// In en, this message translates to:
  /// **'{user} stickied the discussion.'**
  String eventStickied(String user);

  /// Event post
  ///
  /// In en, this message translates to:
  /// **'{user} unstickied the discussion.'**
  String eventUnstickied(String user);

  /// Event post: someone changed the discussion's tags
  ///
  /// In en, this message translates to:
  /// **'{user} changed the tags.'**
  String eventTagged(String user);

  /// Event post of a kind the app doesn't describe
  ///
  /// In en, this message translates to:
  /// **'{user} changed the discussion.'**
  String eventOther(String user);

  /// Stands in for a user the forum didn't name (deleted account)
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// Home tab title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Notifications tab title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// UI text: Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Drawer: Tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Home view: the most active topics of a period (Discourse: Top)
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get filterTop;

  /// Discussion list view: discussions by when they started, newest first
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get viewNewest;

  /// Discussion row: who replied last and when ({time} is e.g. '5 minutes ago')
  ///
  /// In en, this message translates to:
  /// **'{user} replied {time}'**
  String discussionReplied(String user, String time);

  /// Discussion row with no replies: who started it and when
  ///
  /// In en, this message translates to:
  /// **'{user} started {time}'**
  String discussionStarted(String user, String time);

  /// Empty discussion list
  ///
  /// In en, this message translates to:
  /// **'No discussions here yet.'**
  String get noDiscussions;

  /// Error shown when a discussion list fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load discussions.'**
  String get discussionsLoadFailed;

  /// Error shown when the forum's tags fail to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the tags.'**
  String get tagsLoadFailed;

  /// UI text: Sign out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Drawer: Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Button opening sign-up
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Shown when the forum doesn't accept the sign-in captured from its page
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in: {reason}'**
  String signInFailedReason(String reason);

  /// Under the Sign in button on the account tab
  ///
  /// In en, this message translates to:
  /// **'Sign in on the forum\'s own page. The app keeps you signed in until you sign out.'**
  String get signInHint;

  /// Account tab, signed in
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String signedInAs(String name);

  /// UI text: All notifications marked as read
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// Notifications tab: snackbar when Dismiss all fails and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to mark notifications as read'**
  String get failedToMarkNotificationsRead;

  /// Notifications tab, All filter: empty state
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// Notification: a new reply in a discussion the reader follows
  ///
  /// In en, this message translates to:
  /// **'{user} replied to {title}'**
  String notifNewPost(String user, String title);

  /// Notification
  ///
  /// In en, this message translates to:
  /// **'{user} liked your post in {title}'**
  String notifPostLiked(String user, String title);

  /// Notification (fof/reactions)
  ///
  /// In en, this message translates to:
  /// **'{user} reacted to your post in {title}'**
  String notifPostReacted(String user, String title);

  /// Notification: someone quoted or replied to the reader's post
  ///
  /// In en, this message translates to:
  /// **'{user} replied to your post in {title}'**
  String notifPostMentioned(String user, String title);

  /// Notification
  ///
  /// In en, this message translates to:
  /// **'{user} mentioned you in {title}'**
  String notifUserMentioned(String user, String title);

  /// Notification
  ///
  /// In en, this message translates to:
  /// **'{user} mentioned a group you\'re in, in {title}'**
  String notifGroupMentioned(String user, String title);

  /// Notification: {title} is the new title
  ///
  /// In en, this message translates to:
  /// **'{user} renamed a discussion to {title}'**
  String notifRenamed(String user, String title);

  /// Notification
  ///
  /// In en, this message translates to:
  /// **'{user} locked {title}'**
  String notifLocked(String user, String title);

  /// Notification: a new discussion in a tag the reader follows
  ///
  /// In en, this message translates to:
  /// **'{user} started {title}'**
  String notifNewDiscussion(String user, String title);

  /// Notification (fof/follow-tags)
  ///
  /// In en, this message translates to:
  /// **'{user} moved {title} to a tag you follow'**
  String notifMovedToTag(String user, String title);

  /// Notification (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} started a private discussion with you: {title}'**
  String notifPrivateCreated(String user, String title);

  /// Notification (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} replied to the private discussion {title}'**
  String notifPrivateReplied(String user, String title);

  /// Notification (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} added you to the private discussion {title}'**
  String notifPrivateAdded(String user, String title);

  /// Notification (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} removed you from the private discussion {title}'**
  String notifPrivateRemoved(String user, String title);

  /// Notification (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} made {title} public'**
  String notifMadePublic(String user, String title);

  /// Notification (fof/best-answer)
  ///
  /// In en, this message translates to:
  /// **'{user} chose your post as the best answer in {title}'**
  String notifBestAnswerAwarded(String user, String title);

  /// Notification (fof/best-answer)
  ///
  /// In en, this message translates to:
  /// **'{user} chose a best answer in {title}'**
  String notifBestAnswerChosen(String user, String title);

  /// Notification (fof/best-answer): a reminder to the discussion's author
  ///
  /// In en, this message translates to:
  /// **'Choose a best answer in {title}'**
  String notifBestAnswerPending(String title);

  /// Notification (flarum/messages, 2.0)
  ///
  /// In en, this message translates to:
  /// **'{user} sent you a message'**
  String notifMessage(String user);

  /// Notification
  ///
  /// In en, this message translates to:
  /// **'You have been suspended'**
  String get notifSuspended;

  /// Notification
  ///
  /// In en, this message translates to:
  /// **'Your suspension has been lifted'**
  String get notifUnsuspended;

  /// Notification (flarum/gdpr)
  ///
  /// In en, this message translates to:
  /// **'Your data export is ready'**
  String get notifExport;

  /// Notification of a kind the app doesn't describe
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get notifOther;

  /// Stands in for a discussion title the notification doesn't carry
  ///
  /// In en, this message translates to:
  /// **'a discussion'**
  String get aDiscussion;

  /// Error on the notifications tab
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your notifications.'**
  String get notificationsLoadFailed;

  /// Notifications tab for a guest
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your notifications.'**
  String get notificationsSignIn;

  /// Notifications tab action
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// When the person joined, e.g. 'Joined Mar 2024'
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String profileJoined(String date);

  /// Profile tab: the discussions a user started
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get discussionsTab;

  /// Profile: when the user was last online ({time} like '5 minutes ago')
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeen(String time);

  /// Profile: how many discussions the user started and posts they wrote
  ///
  /// In en, this message translates to:
  /// **'{discussions, plural, =1{1 discussion} other{{discussions} discussions}} · {comments, plural, =1{1 post} other{{comments} posts}}'**
  String userStats(int discussions, int comments);

  /// Error on a user's profile
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this profile.'**
  String get userLoadFailed;

  /// Empty list on a profile
  ///
  /// In en, this message translates to:
  /// **'No posts yet.'**
  String get noPostsYet;

  /// Search page: snackbar when a search fails, with the reason
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailedWithError(String error);

  /// Hint in the search field
  ///
  /// In en, this message translates to:
  /// **'Search discussions and posts'**
  String get searchHint;

  /// Search with no results
  ///
  /// In en, this message translates to:
  /// **'Nothing found for “{query}”.'**
  String noResultsFor(String query);

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Drawer row and sheet title for choosing light, dark or the device's setting
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Appearance option that follows the device's light/dark setting
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get appearanceSystem;
}

class _FlarumLocalizationsDelegate
    extends LocalizationsDelegate<FlarumLocalizations> {
  const _FlarumLocalizationsDelegate();

  @override
  Future<FlarumLocalizations> load(Locale locale) {
    return SynchronousFuture<FlarumLocalizations>(
        lookupFlarumLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'nl',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_FlarumLocalizationsDelegate old) => false;
}

FlarumLocalizations lookupFlarumLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FlarumLocalizationsDe();
    case 'en':
      return FlarumLocalizationsEn();
    case 'es':
      return FlarumLocalizationsEs();
    case 'fr':
      return FlarumLocalizationsFr();
    case 'it':
      return FlarumLocalizationsIt();
    case 'ja':
      return FlarumLocalizationsJa();
    case 'ko':
      return FlarumLocalizationsKo();
    case 'nl':
      return FlarumLocalizationsNl();
    case 'pt':
      return FlarumLocalizationsPt();
    case 'ru':
      return FlarumLocalizationsRu();
    case 'zh':
      return FlarumLocalizationsZh();
  }

  throw FlutterError(
      'FlarumLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
