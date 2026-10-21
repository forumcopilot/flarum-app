// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlarumLocalizationsEn extends FlarumLocalizations {
  FlarumLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get attachmentDefaultName => 'Attachment';

  @override
  String get share => 'Share';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Link copied.';

  @override
  String get cancel => 'Cancel';

  @override
  String downloading(String filename) {
    return 'Downloading $filename...';
  }

  @override
  String get download => 'Download';

  @override
  String errorDownloading(String filename, String error) {
    return 'Error downloading $filename: $error';
  }

  @override
  String get video => 'Video';

  @override
  String get viewOnWeb => 'View on Web';

  @override
  String get saveImage => 'Save Image';

  @override
  String get imageSaved => 'Image saved.';

  @override
  String get imageSaveFailed => 'Couldn\'t save the image.';

  @override
  String get imageSaveNotAllowed =>
      'The app may not save to your photos. You can allow it in the phone\'s settings.';

  @override
  String get mediaPause => 'Pause';

  @override
  String get mediaPlay => 'Play';

  @override
  String get failedToLoadVideo => 'Failed to load video';

  @override
  String get close => 'Close';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get image => 'Image';

  @override
  String get fileTypeArchive => 'Archive';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeFile => 'File';

  @override
  String get fileTypeText => 'Text';

  @override
  String get retry => 'Retry';

  @override
  String get edited => 'Edited';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
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
  String get loadMore => 'Load More';

  @override
  String viewProfileOfUser(String username) {
    return 'View profile of $username';
  }

  @override
  String get loadEarlierPosts => 'Load More';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$index of $count posts',
      one: '$index of $count post',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => 'Original Post';

  @override
  String get scrubberNow => 'Now';

  @override
  String timeGapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days later',
      one: 'a day later',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months later',
      one: 'a month later',
    );
    return '$_temp0';
  }

  @override
  String timeGapYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years later',
      one: 'a year later',
    );
    return '$_temp0';
  }

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
  String get someone => '[deleted]';

  @override
  String get latest => 'Latest';

  @override
  String get unread => 'Unread';

  @override
  String get search => 'Search';

  @override
  String get signIn => 'Log In';

  @override
  String get logInToReply => 'Log In to Reply';

  @override
  String get cannotReply => 'Can\'t Reply';

  @override
  String get profile => 'Profile';

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get tags => 'Tags';

  @override
  String get filterTop => 'Top';

  @override
  String get viewNewest => 'Newest';

  @override
  String get allDiscussions => 'All Discussions';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortTitleAz => 'Title (A–Z)';

  @override
  String get sortTitleZa => 'Title (Z–A)';

  @override
  String get changeSorting => 'Change discussion list sorting';

  @override
  String get toggleNavigation => 'Toggle navigation dropdown menu';

  @override
  String discussionReplied(String user, String time) {
    return '$user replied $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user started $time';
  }

  @override
  String get noDiscussions =>
      'It looks as though there are no discussions here.';

  @override
  String get discussionsLoadFailed => 'Couldn\'t load discussions.';

  @override
  String get tagsLoadFailed => 'Couldn\'t load the tags.';

  @override
  String get signOut => 'Log Out';

  @override
  String logOutQuestion(String forum) {
    return 'Are you sure you want to log out of $forum?';
  }

  @override
  String get account => 'Account';

  @override
  String get createAccount => 'Sign Up';

  @override
  String signInFailedReason(String reason) {
    return 'Couldn\'t log in: $reason';
  }

  @override
  String get signInHint =>
      'Log in on the forum\'s own page. The app keeps you logged in until you log out.';

  @override
  String signedInAs(String name) {
    return 'Logged in as $name';
  }

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get failedToMarkNotificationsRead =>
      'Failed to mark notifications as read';

  @override
  String get noNotificationsYet => 'No Notifications';

  @override
  String notifNewPost(String user, String title) {
    return '$user posted in $title';
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
    return '$user mentioned a group you\'re a member of in $title';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user changed the title to $title';
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
    return '$user changed the tag of $title';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user started a new private discussion with you: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user posted in a private discussion you\'re a part of: $title';
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
    return 'Your post was set as the best answer by $user in $title';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user set a best answer in $title';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'Please select a Best Answer in $title if your question has been answered';
  }

  @override
  String notifMessage(String user) {
    return '$user sent you a message';
  }

  @override
  String get notifSuspended => 'You have been suspended';

  @override
  String get notifUnsuspended => 'You have been unsuspended';

  @override
  String get notifExport => 'Your data export is now ready to download.';

  @override
  String get notifOther => 'New notification';

  @override
  String notifLineNewPost(String user) {
    return '$user posted';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user liked your post';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user reacted to your post';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user replied to your post';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user mentioned you';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user mentioned a group you\'re a member of';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user changed the title';
  }

  @override
  String notifLineLocked(String user) {
    return '$user locked';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user started';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user changed the tag';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user started a new private discussion with you';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user posted in a private discussion you\'re a part of';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user added you to a private discussion';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user removed you from a private discussion';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user removed all recipients and made the discussion public';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'Your post was set as the best answer by $user';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user set a best answer in this discussion';
  }

  @override
  String get notifLineBestAnswerPending =>
      'Please select a Best Answer if your question has been answered';

  @override
  String get aDiscussion => 'a discussion';

  @override
  String get notificationsLoadFailed => 'Couldn\'t load your notifications.';

  @override
  String get notificationsSignIn => 'Log in to see your notifications.';

  @override
  String get markAllRead => 'Mark All as Read';

  @override
  String get markAllDiscussionsReadQuestion =>
      'Are you sure you want to mark all discussions as read?';

  @override
  String get hideWelcomeMessage => 'Hide welcome message';

  @override
  String get posts => 'Posts';

  @override
  String get usersTab => 'Users';

  @override
  String get likesTab => 'Likes';

  @override
  String get mentionsTab => 'Mentions';

  @override
  String profileJoined(String date) {
    return 'Joined $date';
  }

  @override
  String get discussionsTab => 'Discussions';

  @override
  String lastSeen(String time) {
    return 'Last seen $time';
  }

  @override
  String get online => 'Online';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count best answers',
      one: '1 best answer',
    );
    return '$_temp0';
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
  String get noPostsYet => 'It looks like there are no posts here.';

  @override
  String searchFailedWithError(String error) {
    return 'Search failed: $error';
  }

  @override
  String get searchHint => 'Search Forum';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearRecentSearches => 'Clear';

  @override
  String noResultsFor(String query) {
    return 'It looks like there are no results for “$query”.';
  }

  @override
  String get light => 'Light Mode';

  @override
  String get dark => 'Dark Mode';

  @override
  String get appearance => 'Color Scheme';

  @override
  String get appearanceSystem => 'System preference';

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
  String get repliesTitle => 'Replies to this post';

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

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user added $tags.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user removed $tags.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user added $added and removed $removed.';
  }

  @override
  String get privateDiscussion => 'Private discussion';

  @override
  String get bestAnswer => 'Best Answer';

  @override
  String get goToBestAnswer => 'View Best Answer';

  @override
  String get answered => 'Answered';

  @override
  String eventRecipientsChanged(String user) {
    return '$user changed who is in this private discussion.';
  }

  @override
  String get noTagsOnForum => 'This forum doesn\'t use tags.';

  @override
  String get permissionRequired => 'Permission required';

  @override
  String get bold => 'Bold';

  @override
  String get underline => 'Underline';

  @override
  String get strikethrough => 'Strikethrough';

  @override
  String get bulletList => 'Bullet List';

  @override
  String get numberedList => 'Numbered List';

  @override
  String get listItem => 'List Item';

  @override
  String get mentionUser => 'Mention a user, group or post';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get send => 'Send message';

  @override
  String get postReply => 'Post Reply';

  @override
  String get postDiscussion => 'Post Discussion';

  @override
  String get postPrivateDiscussion => 'Post Private Discussion';

  @override
  String get save => 'Save Changes';

  @override
  String get formatting => 'Formatting';

  @override
  String get addBold => 'Add bold text';

  @override
  String get addItalic => 'Add italic text';

  @override
  String get insertQuote => 'Insert a quote';

  @override
  String get addLink => 'Add a link';

  @override
  String get addBulletedList => 'Add a bulleted list';

  @override
  String get insertCode => 'Insert code';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterContent => 'Please enter some content';

  @override
  String get composerTitleHint => 'Discussion Title';

  @override
  String get privateDiscussionTitleHint => 'Private Discussion Title';

  @override
  String get composerContentHint => 'Write a Post...';

  @override
  String get composerReplyHint => 'Write a Reply...';

  @override
  String get composerFormattingHint => 'Open formatting options';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get startDiscussion => 'Start a Discussion';

  @override
  String get editPost => 'Edit post';

  @override
  String get postingThrottled =>
      'You\'re going a little too quickly. Please try again in a few seconds.';

  @override
  String get postAwaitingApproval =>
      'Posted. It will appear once a moderator approves it.';

  @override
  String get chooseTags => 'Choose Tags';

  @override
  String get ok => 'OK';

  @override
  String get primaryTags => 'Primary Tags';

  @override
  String get secondaryTags => 'More Tags';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choose $count primary tags.',
      one: 'Choose a primary tag.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choose at most $count primary tags.',
      one: 'Choose only 1 primary tag.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choose $count more tags.',
      one: 'Choose 1 more tag.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choose at most $count more tags.',
      one: 'Choose at most 1 more tag.',
    );
    return '$_temp0';
  }

  @override
  String get noMembersFound => 'No users found matching your search.';

  @override
  String get memberSearchNotAllowed =>
      'This forum doesn\'t let you search for members.';

  @override
  String get editLoadFailed => 'Couldn\'t load this post for editing.';

  @override
  String get like => 'Like';

  @override
  String get unlike => 'Unlike';

  @override
  String likedByOne(String a) {
    return '$a likes this.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a and $b like this.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others others',
      one: '1 other',
    );
    return '$a and $_temp0 like this.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others others',
      one: '1 other',
    );
    return '$a, $b, and $_temp0 like this.';
  }

  @override
  String get likedByYou => 'You like this.';

  @override
  String likedByYouAndOne(String a) {
    return 'You and $a like this.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others others',
      one: '1 other',
    );
    return 'You, $a, and $_temp0 like this.';
  }

  @override
  String get react => 'React';

  @override
  String get reactions => 'Reactions';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get removeBookmark => 'Remove from bookmarks';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get noBookmarks => 'You haven\'t bookmarked any posts yet.';

  @override
  String get chooseBestAnswer => 'Select Best Answer';

  @override
  String get removeBestAnswer => 'Unselect Best Answer';

  @override
  String get notFollowing => 'Not Following';

  @override
  String get notFollowingHint => 'Be notified only when @mentioned.';

  @override
  String get followingHint => 'Be notified of all replies.';

  @override
  String get ignoring => 'Ignoring';

  @override
  String get ignoringHint =>
      'Never be notified. Hide from the discussion list.';

  @override
  String get tagFollowingHint => 'Be notified of all new discussions.';

  @override
  String get lurking => 'Lurking';

  @override
  String get lurkingHint => 'Be notified of all new discussions and replies.';

  @override
  String get tagIgnoringHint => 'Never be notified.';

  @override
  String get hidden => 'Hiding';

  @override
  String get hiddenHint => 'Hide discussions from All Discussions page.';

  @override
  String get attachFile => 'Attach file';

  @override
  String get uploadImage => 'Upload image';

  @override
  String get takePhoto => 'Take photo';

  @override
  String uploadingFilename(String filename) {
    return 'Uploading: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Failed to upload file: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Please wait for attachments to finish uploading';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName resized to $size$dimensions to fit the $limit limit.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: too large ($size) and could not be resized. Limit is $limit.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName is $fileBytes. Uploads over $maxBytes are not accepted.';
  }

  @override
  String get flagAction => 'Flag';

  @override
  String get ignoredUsers => 'Ignored Users';

  @override
  String get ignoredUsersEmpty => 'It looks like you\'re not ignoring anyone.';

  @override
  String get flagPostTitle => 'Flag Post';

  @override
  String get flagReasonOffTopic => 'Off-topic';

  @override
  String get flagReasonOffTopicText =>
      'This post is not relevant to the current discussion and should be moved elsewhere.';

  @override
  String get flagReasonInappropriate => 'Inappropriate';

  @override
  String get flagReasonInappropriateText =>
      'This post is offensive, abusive, or violates our community guidelines.';

  @override
  String get flagReasonSpam => 'Spam';

  @override
  String get flagReasonSpamText => 'This post is an advertisement.';

  @override
  String get flagReasonOther => 'Other (please specify)';

  @override
  String get flagDetails => 'Additional details (optional)';

  @override
  String get flagDetailsNeeded =>
      'Please provide some details for our moderators.';

  @override
  String get communityGuidelines => 'Community Guidelines';

  @override
  String get flagSent =>
      'Thank you for flagging this post. Our moderators will look into it.';

  @override
  String ignoreUser(String name) {
    return 'Ignore $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return 'Unignore $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Are you sure you want to ignore $name?';
  }

  @override
  String ignoredUserPost(String name) {
    return 'A post by $name, whom you ignore.';
  }

  @override
  String get showPost => 'Show Post';

  @override
  String get ignoredOnThisPhone =>
      'This forum keeps no list of ignored users, so the app keeps yours on this phone.';

  @override
  String get stopIgnoring => 'Unignore';

  @override
  String get termsBanner =>
      'We\'ve temporarily restricted access to your account while you check out the new terms.';

  @override
  String get termsReview => 'Review';

  @override
  String get termsTitle => 'Terms Update';

  @override
  String get termsIntro => 'The terms were updated since your last visit';

  @override
  String get readPolicy => 'Read';

  @override
  String get acceptTerms => 'Confirm';

  @override
  String get termsAccepted =>
      'Thanks for accepting, you can now get back to the forum';

  @override
  String get privateDiscussions => 'Private Discussions';

  @override
  String get startPrivateDiscussion => 'Discuss Privately';

  @override
  String privateWith(String names) {
    return 'With $names';
  }

  @override
  String get addPerson => 'Recipients';

  @override
  String get choosePerson =>
      'This discussion will only be visible to the users you choose here. At least 1 recipient (other than yourself) is required.';

  @override
  String get noPrivateDiscussions =>
      'It looks as though there are no discussions here.';

  @override
  String get privateOnlyOne =>
      'This forum lets you write privately to one person at a time.';

  @override
  String get messages => 'Messages';

  @override
  String get newMessage => 'Send a Message';

  @override
  String get noMessages => 'No new messages';

  @override
  String get sendMessage => 'Send a message';

  @override
  String get messageHint => 'Write a message…';

  @override
  String get messagesLoadFailed => 'Couldn\'t load the messages.';

  @override
  String get moderate => 'Moderate';

  @override
  String get renameDiscussion => 'Rename';

  @override
  String get renameDiscussionTitle => 'Rename Discussion';

  @override
  String get lockDiscussion => 'Lock';

  @override
  String get unlockDiscussion => 'Unlock';

  @override
  String get stickDiscussion => 'Sticky';

  @override
  String get unstickDiscussion => 'Unsticky';

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String get deleteForeverConfirm =>
      'Are you sure you want to delete this forever? This action cannot be undone.';

  @override
  String get approve => 'Approve';

  @override
  String get unsuspend => 'Unsuspend';

  @override
  String suspendedUntil(String date) {
    return 'Suspended until $date';
  }

  @override
  String get suspendedIndefinitely => 'Suspended indefinitely';

  @override
  String youAreSuspended(String date) {
    return 'This suspension will be in force until $date';
  }

  @override
  String get youAreSuspendedIndefinitely => 'This account is suspended';

  @override
  String get awaitingApproval => 'Awaiting approval';

  @override
  String get badgeSticky => 'Sticky';

  @override
  String get badgeLocked => 'Locked';

  @override
  String get badgeHidden => 'Hidden';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$user merged $_temp0 from $titles into this discussion.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$user split $_temp0 off to $title.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$user split $_temp0 off from $title.';
  }

  @override
  String get errorNoConnection =>
      'Something seems to be wrong with your connection. Please check your network and try again.';

  @override
  String get errorTimedOut =>
      'The forum took too long to answer. Please try again.';

  @override
  String get errorBlocked =>
      'The forum\'s firewall blocked the app. Try again later, or open the forum in a browser.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorRateLimited =>
      'You\'re going a little too quickly. Please try again in a few seconds.';

  @override
  String get errorForumDown =>
      'The forum isn\'t responding right now. Please try again later.';

  @override
  String get errorNotAllowed => 'You do not have permission to do that.';

  @override
  String get errorUnknown => 'Oops! Something went wrong. Please try again.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes were given',
      one: '1 vote was given',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poll allows voting for $count options.',
      one: 'Poll allows voting for 1 option.',
    );
    return '$_temp0';
  }

  @override
  String get pollEnded => 'This poll has ended.';

  @override
  String pollEndsOn(String date) {
    return 'Poll ends $date.';
  }

  @override
  String get pollResultsAfterVoting => 'The results show once you vote.';

  @override
  String get pollResultsWhenClosed => 'The results show when voting closes.';

  @override
  String get pollVote => 'Vote';

  @override
  String get pollRemoveVote => 'Take back my vote';

  @override
  String get pollSeeVoters => 'View voters';

  @override
  String get pollNoVotes => 'No Votes';

  @override
  String get poll => 'Poll';

  @override
  String get pollNeedsQuestion => 'You must include a question';

  @override
  String get pollNeedsAnswers => 'You must include a minimum of 2 answers';

  @override
  String get pollEndInPast => 'Choose a closing time in the future.';

  @override
  String get pollQuestion => 'Question';

  @override
  String pollAnswer(int number) {
    return 'Answer $number';
  }

  @override
  String get pollRemoveAnswer => 'Remove Answer';

  @override
  String get pollAddAnswer => 'Add Answer';

  @override
  String get pollMultipleChoice => 'Allow people to vote for multiple options';

  @override
  String get pollChoicesAllowed => 'Max votes per user';

  @override
  String get pollAnyNumber => 'Any number';

  @override
  String get pollPublic => 'Allow people to see who voted';

  @override
  String get pollAllowChangeVote => 'Allow users to change their vote';

  @override
  String get pollCloses => 'Poll end date (Optional)';

  @override
  String get pollNeverCloses => 'Never';

  @override
  String get pollHideVotes => 'Hide votes until poll ends';

  @override
  String get pollHideVotesNeedsEnd => 'Choose when voting closes first.';

  @override
  String get addPoll => 'Add Poll';

  @override
  String get submit => 'Submit';

  @override
  String get editPoll => 'Edit Poll';

  @override
  String get removePoll => 'Remove Poll';

  @override
  String get draftSaved => 'Saved!';

  @override
  String get draftSavedWithoutPoll =>
      'Draft saved, without the poll: drafts don\'t keep polls.';

  @override
  String get draftNeedsText => 'Write something to save it as a draft.';

  @override
  String get drafts => 'Drafts';

  @override
  String get draftsLoadFailed => 'Couldn\'t load your drafts';

  @override
  String get noDrafts =>
      'You haven\'t saved any drafts. Close a post you\'re writing and choose Save Draft to keep it here.';

  @override
  String draftReplyTo(String title) {
    return 'Reply to $title';
  }

  @override
  String get draftUntitled => 'Untitled discussion';

  @override
  String get deleteDraftQuestion =>
      'Are you sure you want to delete your draft?';

  @override
  String get deleteDraft => 'Delete draft';
}
