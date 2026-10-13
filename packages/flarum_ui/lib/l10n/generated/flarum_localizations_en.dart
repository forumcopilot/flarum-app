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
  String get edited => 'edited';

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
  String get loadMore => 'Load more';

  @override
  String viewProfileOfUser(String username) {
    return 'View profile of $username';
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
  String get latest => 'Latest';

  @override
  String get unread => 'Unread';

  @override
  String get search => 'Search';

  @override
  String get signIn => 'Sign in';

  @override
  String get profile => 'Profile';

  @override
  String get following => 'Following';

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
  String get signOut => 'Sign out';

  @override
  String get account => 'Account';

  @override
  String get createAccount => 'Create account';

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
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get failedToMarkNotificationsRead =>
      'Failed to mark notifications as read';

  @override
  String get noNotificationsYet => 'No notifications yet';

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
  String get posts => 'Posts';

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
    return 'Search failed: $error';
  }

  @override
  String get searchHint => 'Search discussions and posts';

  @override
  String noResultsFor(String query) {
    return 'Nothing found for “$query”.';
  }

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSystem => 'System default';

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
  String get bestAnswer => 'Best answer';

  @override
  String get goToBestAnswer => 'Go to best answer';

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
  String get mentionUser => 'Mention User';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get send => 'Send';

  @override
  String get save => 'Save';

  @override
  String get formatting => 'Formatting';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterContent => 'Please enter some content';

  @override
  String get composerTitleHint => 'Write your title...';

  @override
  String get composerContentHint => 'Write your content...';

  @override
  String get composerFormattingHint => 'Open formatting options';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get startDiscussion => 'Start a discussion';

  @override
  String get editPost => 'Edit post';

  @override
  String get postingThrottled =>
      'You\'re posting too quickly. Wait a few seconds and try again.';

  @override
  String get postAwaitingApproval =>
      'Posted. It will appear once a moderator approves it.';

  @override
  String get chooseTags => 'Choose tags';

  @override
  String get primaryTags => 'Primary tags';

  @override
  String get secondaryTags => 'More tags';

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
  String get done => 'Done';

  @override
  String get noMembersFound => 'No members found.';

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
  String get react => 'React';

  @override
  String get reactions => 'Reactions';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get noBookmarks => 'No bookmarks yet.';

  @override
  String get chooseBestAnswer => 'Choose as best answer';

  @override
  String get removeBestAnswer => 'Remove best answer';

  @override
  String get notificationSettings => 'Notifications for this discussion';

  @override
  String get notFollowing => 'Not following';

  @override
  String get notFollowingHint => 'Be notified only when @mentioned.';

  @override
  String get followingHint => 'Be notified of all replies.';

  @override
  String get ignoring => 'Ignoring';

  @override
  String get ignoringHint =>
      'Never be notified, and hide it from the discussion lists.';

  @override
  String get tagFollowingHint => 'Be notified of new discussions.';

  @override
  String get lurking => 'Lurking';

  @override
  String get lurkingHint => 'Be notified of new discussions and every reply.';

  @override
  String get tagIgnoringHint => 'Never be notified of discussions here.';

  @override
  String get hidden => 'Hidden';

  @override
  String get hiddenHint =>
      'Hide this tag\'s discussions from the discussion lists.';

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
    return '$fileName is $fileBytes. This forum allows up to $maxBytes.';
  }

  @override
  String get flagAction => 'Flag';

  @override
  String get ignoredUsers => 'Ignored users';

  @override
  String get ignoredUsersEmpty => 'You\'re not ignoring anyone.';

  @override
  String get flagPostTitle => 'Flag post';

  @override
  String get flagReasonOffTopic => 'Off-topic';

  @override
  String get flagReasonOffTopicText =>
      'This post is not relevant to the current discussion and should be moved elsewhere.';

  @override
  String get flagReasonInappropriate => 'Inappropriate';

  @override
  String get flagReasonInappropriateText =>
      'This post is offensive, abusive, or breaks the community guidelines.';

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
  String get communityGuidelines => 'Community guidelines';

  @override
  String get flagSent =>
      'Thank you for flagging this post. Our moderators will look into it.';

  @override
  String ignoreUser(String name) {
    return 'Ignore $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return 'Stop ignoring $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return 'Ignore $name? Their posts will be folded away. You can stop ignoring them from your account.';
  }

  @override
  String ignoredUserPost(String name) {
    return 'A post by $name, whom you ignore.';
  }

  @override
  String get showPost => 'Show post';

  @override
  String get ignoredOnThisPhone =>
      'This forum keeps no list of ignored users, so the app keeps yours on this phone.';

  @override
  String get stopIgnoring => 'Stop ignoring';

  @override
  String get termsBanner => 'Accept this forum\'s updated terms to post again.';

  @override
  String get termsReview => 'Review';

  @override
  String get termsTitle => 'Updated terms';

  @override
  String get termsIntro =>
      'Before you post again, accept the forum\'s updated policies.';

  @override
  String get readPolicy => 'Read';

  @override
  String get acceptTerms => 'Accept';

  @override
  String get termsAccepted => 'Thank you. You can post again.';

  @override
  String get privateDiscussions => 'Private discussions';

  @override
  String get startPrivateDiscussion => 'Start a private discussion';

  @override
  String privateWith(String names) {
    return 'With $names';
  }

  @override
  String get addPerson => 'Add someone';

  @override
  String get choosePerson => 'Choose who to write to.';

  @override
  String get noPrivateDiscussions => 'No private discussions yet.';

  @override
  String get privateOnlyOne =>
      'This forum lets you write privately to one person at a time.';

  @override
  String get messages => 'Messages';

  @override
  String get newMessage => 'New message';

  @override
  String get noMessages => 'No messages yet.';

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
  String get deleteForever => 'Delete forever';

  @override
  String get deleteForeverConfirm =>
      'Delete this for good? It can\'t be undone.';

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
    return 'You\'re suspended until $date.';
  }

  @override
  String get youAreSuspendedIndefinitely => 'You\'re suspended.';

  @override
  String get awaitingApproval => 'Awaiting approval';

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
}
