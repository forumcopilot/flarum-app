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
    Locale('en'),
    Locale('de'),
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

  /// Menu item: puts the web address of a discussion, post or profile on the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// Shown once a link is on the clipboard
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get linkCopied;

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
  /// **'Edited'**
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
  /// **'Load More'**
  String get loadMore;

  /// Screen-reader label of a user row in the who-reacted sheet
  ///
  /// In en, this message translates to:
  /// **'View profile of {username}'**
  String viewProfileOfUser(String username);

  /// Button at the top of a discussion opened part-way down: loads the posts before
  ///
  /// In en, this message translates to:
  /// **'Load More'**
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
  /// **'[deleted]'**
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
  /// **'Log In'**
  String get signIn;

  /// A guest's Reply, as Flarum's discussion controls word it: it opens Log In first
  ///
  /// In en, this message translates to:
  /// **'Log In to Reply'**
  String get logInToReply;

  /// Where the reader may not reply (a locked discussion), as Flarum's discussion controls word it
  ///
  /// In en, this message translates to:
  /// **'Can\'t Reply'**
  String get cannotReply;

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

  /// flarum/subscriptions' button while not following: the follow menu's name
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

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
  /// **'It looks as though there are no discussions here.'**
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
  /// **'Log Out'**
  String get signOut;

  /// Asked before Log Out, as Flarum's log-out page asks
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of {forum}?'**
  String logOutQuestion(String forum);

  /// Drawer: Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Button opening sign-up
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get createAccount;

  /// Shown when the forum doesn't accept the sign-in captured from its page
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t log in: {reason}'**
  String signInFailedReason(String reason);

  /// Under the Sign in button on the account tab
  ///
  /// In en, this message translates to:
  /// **'Log in on the forum\'s own page. The app keeps you logged in until you log out.'**
  String get signInHint;

  /// Account tab, signed in
  ///
  /// In en, this message translates to:
  /// **'Logged in as {name}'**
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
  /// **'No Notifications'**
  String get noNotificationsYet;

  /// Notification: a new reply in a discussion the reader follows
  ///
  /// In en, this message translates to:
  /// **'{user} posted in {title}'**
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
  /// **'{user} mentioned a group you\'re a member of in {title}'**
  String notifGroupMentioned(String user, String title);

  /// Notification: {title} is the new title
  ///
  /// In en, this message translates to:
  /// **'{user} changed the title to {title}'**
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
  /// **'{user} changed the tag of {title}'**
  String notifMovedToTag(String user, String title);

  /// Notification (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} started a new private discussion with you: {title}'**
  String notifPrivateCreated(String user, String title);

  /// Notification (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} posted in a private discussion you\'re a part of: {title}'**
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
  /// **'Your post was set as the best answer by {user} in {title}'**
  String notifBestAnswerAwarded(String user, String title);

  /// Notification (fof/best-answer)
  ///
  /// In en, this message translates to:
  /// **'{user} set a best answer in {title}'**
  String notifBestAnswerChosen(String user, String title);

  /// Notification (fof/best-answer): a reminder to the discussion's author
  ///
  /// In en, this message translates to:
  /// **'Please select a Best Answer in {title} if your question has been answered'**
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
  /// **'You have been unsuspended'**
  String get notifUnsuspended;

  /// Notification (flarum/gdpr)
  ///
  /// In en, this message translates to:
  /// **'Your data export is now ready to download.'**
  String get notifExport;

  /// Notification of a kind the app doesn't describe
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get notifOther;

  /// Under a discussion in the grouped list: a new post in it (flarum/subscriptions)
  ///
  /// In en, this message translates to:
  /// **'{user} posted'**
  String notifLineNewPost(String user);

  /// Under a discussion: a like (flarum/likes)
  ///
  /// In en, this message translates to:
  /// **'{user} liked your post'**
  String notifLinePostLiked(String user);

  /// Under a discussion: a reaction (fof/reactions)
  ///
  /// In en, this message translates to:
  /// **'{user} reacted to your post'**
  String notifLinePostReacted(String user);

  /// Under a discussion: a reply to the reader's post (flarum/mentions)
  ///
  /// In en, this message translates to:
  /// **'{user} replied to your post'**
  String notifLinePostMentioned(String user);

  /// Under a discussion: a mention of the reader
  ///
  /// In en, this message translates to:
  /// **'{user} mentioned you'**
  String notifLineUserMentioned(String user);

  /// Under a discussion: a mention of a group the reader is in
  ///
  /// In en, this message translates to:
  /// **'{user} mentioned a group you\'re a member of'**
  String notifLineGroupMentioned(String user);

  /// Under a discussion: it was renamed
  ///
  /// In en, this message translates to:
  /// **'{user} changed the title'**
  String notifLineRenamed(String user);

  /// Under a discussion: it was locked (flarum/lock)
  ///
  /// In en, this message translates to:
  /// **'{user} locked'**
  String notifLineLocked(String user);

  /// Under a discussion: it was started in a followed tag (fof/follow-tags)
  ///
  /// In en, this message translates to:
  /// **'{user} started'**
  String notifLineNewDiscussion(String user);

  /// Under a discussion: it moved into a followed tag
  ///
  /// In en, this message translates to:
  /// **'{user} changed the tag'**
  String notifLineMovedToTag(String user);

  /// Under a discussion: a private discussion with the reader began (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'{user} started a new private discussion with you'**
  String notifLinePrivateCreated(String user);

  /// Under a discussion: a post in a private discussion
  ///
  /// In en, this message translates to:
  /// **'{user} posted in a private discussion you\'re a part of'**
  String notifLinePrivateReplied(String user);

  /// Under a discussion: the reader was added to a private discussion
  ///
  /// In en, this message translates to:
  /// **'{user} added you to a private discussion'**
  String notifLinePrivateAdded(String user);

  /// Under a discussion: the reader was removed from a private discussion
  ///
  /// In en, this message translates to:
  /// **'{user} removed you from a private discussion'**
  String notifLinePrivateRemoved(String user);

  /// Under a discussion: a private discussion was made public
  ///
  /// In en, this message translates to:
  /// **'{user} removed all recipients and made the discussion public'**
  String notifLineMadePublic(String user);

  /// Under a discussion: the reader's post became the best answer (fof/best-answer)
  ///
  /// In en, this message translates to:
  /// **'Your post was set as the best answer by {user}'**
  String notifLineBestAnswerAwarded(String user);

  /// Under a discussion: a best answer was chosen in it
  ///
  /// In en, this message translates to:
  /// **'{user} set a best answer in this discussion'**
  String notifLineBestAnswerChosen(String user);

  /// Under a discussion: a reminder to choose a best answer
  ///
  /// In en, this message translates to:
  /// **'Please select a Best Answer if your question has been answered'**
  String get notifLineBestAnswerPending;

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
  /// **'Log in to see your notifications.'**
  String get notificationsSignIn;

  /// Notifications tab action
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllRead;

  /// Asked before Home's Mark All as Read, as Flarum asks
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark all discussions as read?'**
  String get markAllDiscussionsReadQuestion;

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
  /// **'It looks like there are no posts here.'**
  String get noPostsYet;

  /// Search page: snackbar when a search fails, with the reason
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailedWithError(String error);

  /// Hint in the search field
  ///
  /// In en, this message translates to:
  /// **'Search Forum'**
  String get searchHint;

  /// Search with no results
  ///
  /// In en, this message translates to:
  /// **'It looks like there are no results for “{query}”.'**
  String noResultsFor(String query);

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark;

  /// Drawer row and sheet title for choosing light, dark or the device's setting
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get appearance;

  /// Appearance option that follows the device's light/dark setting
  ///
  /// In en, this message translates to:
  /// **'System preference'**
  String get appearanceSystem;

  /// Under a post: who replied to (mentioned) it
  ///
  /// In en, this message translates to:
  /// **'{a} replied to this.'**
  String repliedByOne(String a);

  /// Under a post: the two people who replied to it
  ///
  /// In en, this message translates to:
  /// **'{a} and {b} replied to this.'**
  String repliedByTwo(String a, String b);

  /// Under a post: two of the people who replied, and how many more replies
  ///
  /// In en, this message translates to:
  /// **'{a}, {b} and {others, plural, =1{1 other} other{{others} others}} replied to this.'**
  String repliedByMore(String a, String b, int others);

  /// Title of the sheet listing the replies to a post
  ///
  /// In en, this message translates to:
  /// **'Replies to this post'**
  String get repliesTitle;

  /// A post by its number in the discussion
  ///
  /// In en, this message translates to:
  /// **'Post #{number}'**
  String postNumber(int number);

  /// Under a post: one person who replied, and how many more replies
  ///
  /// In en, this message translates to:
  /// **'{a} and {others, plural, =1{1 other} other{{others} others}} replied to this.'**
  String repliedByOneMore(String a, int others);

  /// Event post: tags added to the discussion; {tags} is the tag names, e.g. 'Support, iOS'
  ///
  /// In en, this message translates to:
  /// **'{user} added {tags}.'**
  String eventTagsAdded(String user, String tags);

  /// Event post: tags removed from the discussion
  ///
  /// In en, this message translates to:
  /// **'{user} removed {tags}.'**
  String eventTagsRemoved(String user, String tags);

  /// Event post: tags added and others removed
  ///
  /// In en, this message translates to:
  /// **'{user} added {added} and removed {removed}.'**
  String eventTagsMoved(String user, String added, String removed);

  /// Label for a private discussion (fof/byobu) in a list
  ///
  /// In en, this message translates to:
  /// **'Private discussion'**
  String get privateDiscussion;

  /// Label above the post fof/best-answer chose as a discussion's answer
  ///
  /// In en, this message translates to:
  /// **'Best Answer'**
  String get bestAnswer;

  /// Button under a question whose best answer (fof/best-answer) is another post
  ///
  /// In en, this message translates to:
  /// **'View Best Answer'**
  String get goToBestAnswer;

  /// Screen-reader label for the check mark on a discussion that has a best answer (fof/best-answer)
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// Event post in a fof/byobu private discussion: its recipients changed (including when it was started)
  ///
  /// In en, this message translates to:
  /// **'{user} changed who is in this private discussion.'**
  String eventRecipientsChanged(String user);

  /// Tags tab on a forum that doesn't run flarum/tags
  ///
  /// In en, this message translates to:
  /// **'This forum doesn\'t use tags.'**
  String get noTagsOnForum;

  /// On a file card in a post, instead of Download, when the reader may not download files (fof/upload's download permission)
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permissionRequired;

  /// Composer: bold
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// Composer: underline
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// Composer: strikethrough
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get strikethrough;

  /// Composer: bulletList
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get bulletList;

  /// Composer: numberedList
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get numberedList;

  /// Composer: listItem
  ///
  /// In en, this message translates to:
  /// **'List Item'**
  String get listItem;

  /// Tooltip for mention user button
  ///
  /// In en, this message translates to:
  /// **'Mention a user, group or post'**
  String get mentionUser;

  /// UI text: Title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Content label for message compose
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// The message composer's send button (flarum/messages), as Flarum's
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get send;

  /// The reply composer's submit button, as Flarum's
  ///
  /// In en, this message translates to:
  /// **'Post Reply'**
  String get postReply;

  /// The new-discussion composer's submit button, as Flarum's
  ///
  /// In en, this message translates to:
  /// **'Post Discussion'**
  String get postDiscussion;

  /// The private-discussion composer's submit button, as fof/byobu's
  ///
  /// In en, this message translates to:
  /// **'Post Private Discussion'**
  String get postPrivateDiscussion;

  /// The edit composer's submit button, as Flarum's
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save;

  /// Composer: formatting
  ///
  /// In en, this message translates to:
  /// **'Formatting'**
  String get formatting;

  /// Validation message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// Validation message when content is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter some content'**
  String get pleaseEnterContent;

  /// Default hint in a composer's title field, when the page gives none of its own
  ///
  /// In en, this message translates to:
  /// **'Discussion Title'**
  String get composerTitleHint;

  /// The private-discussion composer's title placeholder, as fof/byobu's
  ///
  /// In en, this message translates to:
  /// **'Private Discussion Title'**
  String get privateDiscussionTitleHint;

  /// Default hint in a composer's text field, when the page gives none of its own
  ///
  /// In en, this message translates to:
  /// **'Write a Post...'**
  String get composerContentHint;

  /// The reply composer's text placeholder, as Flarum's
  ///
  /// In en, this message translates to:
  /// **'Write a Reply...'**
  String get composerReplyHint;

  /// Screen-reader hint of the composer's formatting menu button
  ///
  /// In en, this message translates to:
  /// **'Open formatting options'**
  String get composerFormattingHint;

  /// Hint text for searching users
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// Button and page title: start a new discussion
  ///
  /// In en, this message translates to:
  /// **'Start a Discussion'**
  String get startDiscussion;

  /// Title of the composer editing a post
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPost;

  /// The forum's posting throttle refused a post (one every 10 seconds by default)
  ///
  /// In en, this message translates to:
  /// **'You\'re going a little too quickly. Please try again in a few seconds.'**
  String get postingThrottled;

  /// After posting, when the forum holds the post for approval
  ///
  /// In en, this message translates to:
  /// **'Posted. It will appear once a moderator approves it.'**
  String get postAwaitingApproval;

  /// Button and page title: choose a new discussion's tags
  ///
  /// In en, this message translates to:
  /// **'Choose Tags'**
  String get chooseTags;

  /// Closes the tag picker, keeping the choice, as flarum/tags' button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Tag picker section: the forum's primary tags
  ///
  /// In en, this message translates to:
  /// **'Primary Tags'**
  String get primaryTags;

  /// Tag picker section: the forum's secondary tags
  ///
  /// In en, this message translates to:
  /// **'More Tags'**
  String get secondaryTags;

  /// Tag picker: fewer primary tags than the forum asks for
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Choose a primary tag.} other{Choose {count} primary tags.}}'**
  String tagsNeedPrimary(int count);

  /// Tag picker: more primary tags than the forum allows
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Choose only 1 primary tag.} other{Choose at most {count} primary tags.}}'**
  String tagsTooManyPrimary(int count);

  /// Tag picker: fewer secondary tags than the forum asks for
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Choose 1 more tag.} other{Choose {count} more tags.}}'**
  String tagsNeedSecondary(int count);

  /// Tag picker: more secondary tags than the forum allows
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Choose at most 1 more tag.} other{Choose at most {count} more tags.}}'**
  String tagsTooManySecondary(int count);

  /// Mention picker: nobody matches the search
  ///
  /// In en, this message translates to:
  /// **'No users found matching your search.'**
  String get noMembersFound;

  /// Mention picker: the reader lacks the forum's search-users permission
  ///
  /// In en, this message translates to:
  /// **'This forum doesn\'t let you search for members.'**
  String get memberSearchNotAllowed;

  /// The post's source couldn't be loaded for editing
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this post for editing.'**
  String get editLoadFailed;

  /// Button under a post: like it (flarum/likes)
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Tooltip of the like button when the reader already likes the post
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlike;

  /// Under a post liked by one person (flarum/likes' liked_by_text)
  ///
  /// In en, this message translates to:
  /// **'{a} likes this.'**
  String likedByOne(String a);

  /// Under a post liked by two people
  ///
  /// In en, this message translates to:
  /// **'{a} and {b} like this.'**
  String likedByTwo(String a, String b);

  /// Under a post liked by one person named and others
  ///
  /// In en, this message translates to:
  /// **'{a} and {others, plural, =1{1 other} other{{others} others}} like this.'**
  String likedByOneMore(String a, int others);

  /// Under a post liked by two people named and others
  ///
  /// In en, this message translates to:
  /// **'{a}, {b}, and {others, plural, =1{1 other} other{{others} others}} like this.'**
  String likedByMore(String a, String b, int others);

  /// Under a post only the reader likes
  ///
  /// In en, this message translates to:
  /// **'You like this.'**
  String get likedByYou;

  /// Under a post the reader and one other person like
  ///
  /// In en, this message translates to:
  /// **'You and {a} like this.'**
  String likedByYouAndOne(String a);

  /// Under a post the reader, one person named and others like
  ///
  /// In en, this message translates to:
  /// **'You, {a}, and {others, plural, =1{1 other} other{{others} others}} like this.'**
  String likedByYouOneMore(String a, int others);

  /// Button under a post: choose a reaction (fof/reactions)
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get react;

  /// Title of the sheet to choose a reaction
  ///
  /// In en, this message translates to:
  /// **'Reactions'**
  String get reactions;

  /// Post or discussion menu: bookmark it (fof/bookmarks)
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// Post or discussion menu: take the bookmark off
  ///
  /// In en, this message translates to:
  /// **'Remove from bookmarks'**
  String get removeBookmark;

  /// The reader's bookmarks: an account tab entry and its page's title
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// Bookmarks page with nothing bookmarked
  ///
  /// In en, this message translates to:
  /// **'You haven\'t bookmarked any posts yet.'**
  String get noBookmarks;

  /// Post menu for the one who asked (fof/best-answer)
  ///
  /// In en, this message translates to:
  /// **'Select Best Answer'**
  String get chooseBestAnswer;

  /// Post menu on the chosen answer: un-choose it
  ///
  /// In en, this message translates to:
  /// **'Unselect Best Answer'**
  String get removeBestAnswer;

  /// Follow menu: the reader's default for a discussion or tag
  ///
  /// In en, this message translates to:
  /// **'Not Following'**
  String get notFollowing;

  /// Under Not following in a discussion's follow menu
  ///
  /// In en, this message translates to:
  /// **'Be notified only when @mentioned.'**
  String get notFollowingHint;

  /// Under Following in a discussion's follow menu
  ///
  /// In en, this message translates to:
  /// **'Be notified of all replies.'**
  String get followingHint;

  /// Follow menu: ignore the discussion or tag
  ///
  /// In en, this message translates to:
  /// **'Ignoring'**
  String get ignoring;

  /// Under Ignoring in a discussion's follow menu
  ///
  /// In en, this message translates to:
  /// **'Never be notified. Hide from the discussion list.'**
  String get ignoringHint;

  /// Under Following in a tag's follow menu (fof/follow-tags)
  ///
  /// In en, this message translates to:
  /// **'Be notified of all new discussions.'**
  String get tagFollowingHint;

  /// Tag follow menu: told of new discussions and every reply
  ///
  /// In en, this message translates to:
  /// **'Lurking'**
  String get lurking;

  /// Under Lurking in a tag's follow menu
  ///
  /// In en, this message translates to:
  /// **'Be notified of all new discussions and replies.'**
  String get lurkingHint;

  /// Under Ignoring in a tag's follow menu
  ///
  /// In en, this message translates to:
  /// **'Never be notified.'**
  String get tagIgnoringHint;

  /// Tag follow menu: hide the tag's discussions
  ///
  /// In en, this message translates to:
  /// **'Hiding'**
  String get hidden;

  /// Under Hidden in a tag's follow menu
  ///
  /// In en, this message translates to:
  /// **'Hide discussions from All Discussions page.'**
  String get hiddenHint;

  /// Accessibility label for attach file button
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// Accessibility label for upload image button
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// Opens the camera to take a photo to attach.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// Placeholder put in the post text where an upload will go while it uploads (Discourse uploading_filename)
  ///
  /// In en, this message translates to:
  /// **'Uploading: {filename}…'**
  String uploadingFilename(String filename);

  /// UI text: Failed to upload file: {errorMessage}
  ///
  /// In en, this message translates to:
  /// **'Failed to upload file: {errorMessage}'**
  String failedToUploadFile2(Object errorMessage);

  /// UI text: Please wait for attachments to finish uploading
  ///
  /// In en, this message translates to:
  /// **'Please wait for attachments to finish uploading'**
  String get pleaseWaitForAttachmentsToFinishUploading;

  /// Composer notice after an oversized image was shrunk to fit the forum's upload limit; size and limit are formatted file sizes; dimensions is empty or ' (1200×800 → 900×600)' with a leading space
  ///
  /// In en, this message translates to:
  /// **'{fileName} resized to {size}{dimensions} to fit the {limit} limit.'**
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit);

  /// Composer error when a picked image is over the forum's upload limit and shrinking it failed; size and limit are formatted file sizes
  ///
  /// In en, this message translates to:
  /// **'{fileName}: too large ({size}) and could not be resized. Limit is {limit}.'**
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit);

  /// UI text: {fileName} is {fileBytes}. This forum allows up to {maxBytes
  ///
  /// In en, this message translates to:
  /// **'{fileName} is {fileBytes}. Uploads over {maxBytes} are not accepted.'**
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes);

  /// Discourse post.controls.flag_action: the post menu item that opens the flag dialog
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flagAction;

  /// UI text: Ignored users
  ///
  /// In en, this message translates to:
  /// **'Ignored Users'**
  String get ignoredUsers;

  /// Ignored users page: empty state
  ///
  /// In en, this message translates to:
  /// **'It looks like you\'re not ignoring anyone.'**
  String get ignoredUsersEmpty;

  /// Title of the page that reports a post to the moderators (flarum/flags)
  ///
  /// In en, this message translates to:
  /// **'Flag Post'**
  String get flagPostTitle;

  /// Report reason (Flarum: reason_off_topic_label)
  ///
  /// In en, this message translates to:
  /// **'Off-topic'**
  String get flagReasonOffTopic;

  /// Explains the off-topic report reason
  ///
  /// In en, this message translates to:
  /// **'This post is not relevant to the current discussion and should be moved elsewhere.'**
  String get flagReasonOffTopicText;

  /// Report reason (Flarum: reason_inappropriate_label)
  ///
  /// In en, this message translates to:
  /// **'Inappropriate'**
  String get flagReasonInappropriate;

  /// Explains the inappropriate report reason
  ///
  /// In en, this message translates to:
  /// **'This post is offensive, abusive, or violates our community guidelines.'**
  String get flagReasonInappropriateText;

  /// Report reason (Flarum: reason_spam_label)
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get flagReasonSpam;

  /// Explains the spam report reason
  ///
  /// In en, this message translates to:
  /// **'This post is an advertisement.'**
  String get flagReasonSpamText;

  /// Report reason that needs the reporter's own words
  ///
  /// In en, this message translates to:
  /// **'Other (please specify)'**
  String get flagReasonOther;

  /// Report page: the field for more details
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get flagDetails;

  /// Report page: "Other" chosen without details
  ///
  /// In en, this message translates to:
  /// **'Please provide some details for our moderators.'**
  String get flagDetailsNeeded;

  /// Link to the forum's community guidelines, on the report page
  ///
  /// In en, this message translates to:
  /// **'Community Guidelines'**
  String get communityGuidelines;

  /// Shown after a post was reported
  ///
  /// In en, this message translates to:
  /// **'Thank you for flagging this post. Our moderators will look into it.'**
  String get flagSent;

  /// Post and profile menu: ignore this person (fof/ignore-users), their posts folded away
  ///
  /// In en, this message translates to:
  /// **'Ignore {name}'**
  String ignoreUser(String name);

  /// Post and profile menu: stop ignoring this person
  ///
  /// In en, this message translates to:
  /// **'Unignore {name}'**
  String stopIgnoringUser(String name);

  /// Confirmation before ignoring someone
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to ignore {name}?'**
  String ignoreUserConfirm(String name);

  /// In place of a post by someone the reader ignores
  ///
  /// In en, this message translates to:
  /// **'A post by {name}, whom you ignore.'**
  String ignoredUserPost(String name);

  /// Button that unfolds a post by someone the reader ignores
  ///
  /// In en, this message translates to:
  /// **'Show Post'**
  String get showPost;

  /// Ignored users page, on a forum without fof/ignore-users
  ///
  /// In en, this message translates to:
  /// **'This forum keeps no list of ignored users, so the app keeps yours on this phone.'**
  String get ignoredOnThisPhone;

  /// Ignored users page: button on each person
  ///
  /// In en, this message translates to:
  /// **'Unignore'**
  String get stopIgnoring;

  /// Strip above the tab bar while the reader must accept new policies (fof/terms); until then the forum lets them only read
  ///
  /// In en, this message translates to:
  /// **'We\'ve temporarily restricted access to your account while you check out the new terms.'**
  String get termsBanner;

  /// Button on that strip: opens the policies
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get termsReview;

  /// Title of the page with the policies to accept
  ///
  /// In en, this message translates to:
  /// **'Terms Update'**
  String get termsTitle;

  /// Top of that page
  ///
  /// In en, this message translates to:
  /// **'The terms were updated since your last visit'**
  String get termsIntro;

  /// Opens a policy's text on the forum's site
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readPolicy;

  /// Accepts the policies
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get acceptTerms;

  /// Shown once the policies are accepted
  ///
  /// In en, this message translates to:
  /// **'Thanks for accepting, you can now get back to the forum'**
  String get termsAccepted;

  /// Account entry and page title: the reader's private discussions (fof/byobu)
  ///
  /// In en, this message translates to:
  /// **'Private Discussions'**
  String get privateDiscussions;

  /// Button and composer title: a discussion only the people in it can read
  ///
  /// In en, this message translates to:
  /// **'Discuss Privately'**
  String get startPrivateDiscussion;

  /// Who a private discussion is with; names is a list of display names
  ///
  /// In en, this message translates to:
  /// **'With {names}'**
  String privateWith(String names);

  /// Composer button that adds someone to a private discussion
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get addPerson;

  /// Composer: a private discussion started with no one in it
  ///
  /// In en, this message translates to:
  /// **'This discussion will only be visible to the users you choose here. At least 1 recipient (other than yourself) is required.'**
  String get choosePerson;

  /// Empty private discussions page
  ///
  /// In en, this message translates to:
  /// **'It looks as though there are no discussions here.'**
  String get noPrivateDiscussions;

  /// Composer: the forum lets members write privately to one other person only
  ///
  /// In en, this message translates to:
  /// **'This forum lets you write privately to one person at a time.'**
  String get privateOnlyOne;

  /// Account entry and page title: direct messages (flarum/messages, Flarum 2.0)
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Button that starts a direct message to someone
  ///
  /// In en, this message translates to:
  /// **'Send a Message'**
  String get newMessage;

  /// Empty messages page
  ///
  /// In en, this message translates to:
  /// **'No new messages'**
  String get noMessages;

  /// Profile menu: write a direct message to this person
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get sendMessage;

  /// The reply field at the bottom of a conversation
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get messageHint;

  /// A conversation or the messages list failed to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the messages.'**
  String get messagesLoadFailed;

  /// Tooltip of the moderators' menu on a discussion
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// Moderator menu: rename the discussion
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameDiscussion;

  /// Title of the dialog that renames a discussion, as Flarum's
  ///
  /// In en, this message translates to:
  /// **'Rename Discussion'**
  String get renameDiscussionTitle;

  /// Moderator menu: lock the discussion (flarum/lock)
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lockDiscussion;

  /// Moderator menu: unlock it
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockDiscussion;

  /// Moderator menu: pin the discussion to the top (flarum/sticky, the web says Sticky)
  ///
  /// In en, this message translates to:
  /// **'Sticky'**
  String get stickDiscussion;

  /// Moderator menu: unpin it (the web says Unsticky)
  ///
  /// In en, this message translates to:
  /// **'Unsticky'**
  String get unstickDiscussion;

  /// Brings back a deleted (hidden) post or discussion
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Deletes a post or discussion permanently
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// Confirmation before deleting permanently
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this forever? This action cannot be undone.'**
  String get deleteForeverConfirm;

  /// Approves a post held for approval (flarum/approval)
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Profile menu: lift a suspension (flarum/suspend)
  ///
  /// In en, this message translates to:
  /// **'Unsuspend'**
  String get unsuspend;

  /// Profile: a suspended member, until a date
  ///
  /// In en, this message translates to:
  /// **'Suspended until {date}'**
  String suspendedUntil(String date);

  /// Profile: a member suspended with no end
  ///
  /// In en, this message translates to:
  /// **'Suspended indefinitely'**
  String get suspendedIndefinitely;

  /// Strip above the tabs for a suspended reader, until a date
  ///
  /// In en, this message translates to:
  /// **'This suspension will be in force until {date}'**
  String youAreSuspended(String date);

  /// Strip above the tabs for a reader suspended with no end
  ///
  /// In en, this message translates to:
  /// **'This account is suspended'**
  String get youAreSuspendedIndefinitely;

  /// Label on a post held for a moderator's approval
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get awaitingApproval;

  /// Event post (fof/merge-discussions): posts from other discussions merged into this one; titles is their titles, e.g. '“A”, “B”'
  ///
  /// In en, this message translates to:
  /// **'{user} merged {count, plural, =1{1 post} other{{count} posts}} from {titles} into this discussion.'**
  String eventMerged(String user, int count, String titles);

  /// Event post (fof/split), in the discussion posts were split from: title is the new discussion
  ///
  /// In en, this message translates to:
  /// **'{user} split {count, plural, =1{1 post} other{{count} posts}} off to {title}.'**
  String eventSplitTo(String user, int count, String title);

  /// Event post (fof/split), in the new discussion: title is the one its posts came from
  ///
  /// In en, this message translates to:
  /// **'{user} split {count, plural, =1{1 post} other{{count} posts}} off from {title}.'**
  String eventSplitFrom(String user, int count, String title);

  /// Error: no response from the forum (offline, DNS, refused).
  ///
  /// In en, this message translates to:
  /// **'Something seems to be wrong with your connection. Please check your network and try again.'**
  String get errorNoConnection;

  /// Error: the forum did not answer in time.
  ///
  /// In en, this message translates to:
  /// **'The forum took too long to answer. Please try again.'**
  String get errorTimedOut;

  /// Error: a firewall's page answered instead of the forum (a 403 without the forum's own error).
  ///
  /// In en, this message translates to:
  /// **'The forum\'s firewall blocked the app. Try again later, or open the forum in a browser.'**
  String get errorBlocked;

  /// Error: 404/410 without the forum saying more.
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get errorNotFound;

  /// Error: 429, too many requests.
  ///
  /// In en, this message translates to:
  /// **'You\'re going a little too quickly. Please try again in a few seconds.'**
  String get errorRateLimited;

  /// Error: 5xx, the forum is down or failing.
  ///
  /// In en, this message translates to:
  /// **'The forum isn\'t responding right now. Please try again later.'**
  String get errorForumDown;

  /// Error: 401/403 from the forum without its own words (Flarum 1.x's permission_denied).
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorNotAllowed;

  /// Error: anything else, instead of the exception text.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong. Please try again.'**
  String get errorUnknown;

  /// Under a poll: how many votes it has, when the reader may see the results.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vote was given} other{{count} votes were given}}'**
  String pollVotes(int count);

  /// Under a poll where several answers may be chosen: how many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Poll allows voting for 1 option.} other{Poll allows voting for {count} options.}}'**
  String pollChooseUpTo(int count);

  /// Under a poll whose voting has closed.
  ///
  /// In en, this message translates to:
  /// **'This poll has ended.'**
  String get pollEnded;

  /// Under a poll: when voting closes (a date and time).
  ///
  /// In en, this message translates to:
  /// **'Poll ends {date}.'**
  String pollEndsOn(String date);

  /// Under a poll whose results the reader sees only once they have voted.
  ///
  /// In en, this message translates to:
  /// **'The results show once you vote.'**
  String get pollResultsAfterVoting;

  /// Under a poll whose results stay hidden until voting closes, after the reader voted.
  ///
  /// In en, this message translates to:
  /// **'The results show when voting closes.'**
  String get pollResultsWhenClosed;

  /// Button: sends the answers chosen in a multiple-choice poll.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get pollVote;

  /// Button under a poll the reader voted in: takes their vote back.
  ///
  /// In en, this message translates to:
  /// **'Take back my vote'**
  String get pollRemoveVote;

  /// Button under a public poll: lists who voted for what.
  ///
  /// In en, this message translates to:
  /// **'View voters'**
  String get pollSeeVoters;

  /// The voters sheet of a poll nobody has voted in.
  ///
  /// In en, this message translates to:
  /// **'No Votes'**
  String get pollNoVotes;

  /// The poll editor's title.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get poll;

  /// Poll editor: Done with no question.
  ///
  /// In en, this message translates to:
  /// **'You must include a question'**
  String get pollNeedsQuestion;

  /// Poll editor: Done with fewer than two answers.
  ///
  /// In en, this message translates to:
  /// **'You must include a minimum of 2 answers'**
  String get pollNeedsAnswers;

  /// Poll editor: the closing time chosen has passed.
  ///
  /// In en, this message translates to:
  /// **'Choose a closing time in the future.'**
  String get pollEndInPast;

  /// Poll editor: the question field's label.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get pollQuestion;

  /// Poll editor: an answer field's label, numbered from 1.
  ///
  /// In en, this message translates to:
  /// **'Answer {number}'**
  String pollAnswer(int number);

  /// Poll editor: tooltip of the button that removes an answer.
  ///
  /// In en, this message translates to:
  /// **'Remove Answer'**
  String get pollRemoveAnswer;

  /// Poll editor: adds another answer field.
  ///
  /// In en, this message translates to:
  /// **'Add Answer'**
  String get pollAddAnswer;

  /// Poll editor switch: voters may choose several answers.
  ///
  /// In en, this message translates to:
  /// **'Allow people to vote for multiple options'**
  String get pollMultipleChoice;

  /// Poll editor: how many answers a voter may choose, in a multiple-choice poll.
  ///
  /// In en, this message translates to:
  /// **'Max votes per user'**
  String get pollChoicesAllowed;

  /// Poll editor: no limit on how many answers a voter may choose.
  ///
  /// In en, this message translates to:
  /// **'Any number'**
  String get pollAnyNumber;

  /// Poll editor switch: who voted for which answer is shown.
  ///
  /// In en, this message translates to:
  /// **'Allow people to see who voted'**
  String get pollPublic;

  /// Poll editor switch: voters may change their vote.
  ///
  /// In en, this message translates to:
  /// **'Allow users to change their vote'**
  String get pollAllowChangeVote;

  /// Poll editor: when voting closes.
  ///
  /// In en, this message translates to:
  /// **'Poll end date (Optional)'**
  String get pollCloses;

  /// Poll editor: voting never closes.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get pollNeverCloses;

  /// Poll editor switch: results stay hidden until voting closes.
  ///
  /// In en, this message translates to:
  /// **'Hide votes until poll ends'**
  String get pollHideVotes;

  /// Poll editor: why hiding the results is off (it needs a closing time).
  ///
  /// In en, this message translates to:
  /// **'Choose when voting closes first.'**
  String get pollHideVotesNeedsEnd;

  /// New discussion composer: adds a poll (fof/polls).
  ///
  /// In en, this message translates to:
  /// **'Add Poll'**
  String get addPoll;

  /// Closes the poll editor, keeping the poll, as fof/polls' button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// New discussion composer: tooltip of the poll's chip.
  ///
  /// In en, this message translates to:
  /// **'Edit Poll'**
  String get editPoll;

  /// New discussion composer: removes the poll.
  ///
  /// In en, this message translates to:
  /// **'Remove Poll'**
  String get removePoll;

  /// After Save draft when closing the composer.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get draftSaved;

  /// After Save draft for a new discussion with a poll: fof/drafts has nowhere to keep it.
  ///
  /// In en, this message translates to:
  /// **'Draft saved, without the poll: drafts don\'t keep polls.'**
  String get draftSavedWithoutPoll;

  /// Save draft with no text: the forum refuses an empty draft.
  ///
  /// In en, this message translates to:
  /// **'Write something to save it as a draft.'**
  String get draftNeedsText;

  /// The reader's drafts (fof/drafts): the Account entry and the page's title.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// The drafts page couldn't load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your drafts'**
  String get draftsLoadFailed;

  /// The drafts page with none. The quoted button is the composer's close prompt's Save draft.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any drafts. Close a post you\'re writing and choose Save Draft to keep it here.'**
  String get noDrafts;

  /// A reply draft in the drafts list: the discussion it replies to.
  ///
  /// In en, this message translates to:
  /// **'Reply to {title}'**
  String draftReplyTo(String title);

  /// A new-discussion draft without a title, in the drafts list.
  ///
  /// In en, this message translates to:
  /// **'Untitled discussion'**
  String get draftUntitled;

  /// Asked before deleting a draft.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your draft?'**
  String get deleteDraftQuestion;

  /// Deletes a draft from the drafts list.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get deleteDraft;
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
