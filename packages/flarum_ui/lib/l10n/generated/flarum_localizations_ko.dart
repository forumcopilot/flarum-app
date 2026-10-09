// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class FlarumLocalizationsKo extends FlarumLocalizations {
  FlarumLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get attachmentDefaultName => '첨부파일';

  @override
  String get share => '공유';

  @override
  String get cancel => '취소';

  @override
  String downloading(String filename) {
    return '$filename 다운로드 중...';
  }

  @override
  String get download => '다운로드';

  @override
  String errorDownloading(String filename, String error) {
    return '$filename 다운로드 오류: $error';
  }

  @override
  String get video => '동영상';

  @override
  String get viewOnWeb => '웹에서 보기';

  @override
  String get mediaPause => '일시 정지';

  @override
  String get mediaPlay => '재생';

  @override
  String get failedToLoadVideo => '동영상을 불러오지 못했습니다';

  @override
  String get close => '닫기';

  @override
  String get spoiler => '스포일러';

  @override
  String get image => '이미지';

  @override
  String get fileTypeArchive => '압축 파일';

  @override
  String get fileTypeAudio => '오디오';

  @override
  String get fileTypeFile => '파일';

  @override
  String get fileTypeText => '텍스트';

  @override
  String get retry => '다시 시도';

  @override
  String get edited => '수정됨';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '답글 $count개',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '좋아요 $count개',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => '더 불러오기';

  @override
  String viewProfileOfUser(String username) {
    return '$username님의 프로필 보기';
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
  String get latest => '최신';

  @override
  String get unread => '읽지 않음';

  @override
  String get search => '검색';

  @override
  String get signIn => '로그인';

  @override
  String get profile => '프로필';

  @override
  String get following => '팔로잉';

  @override
  String get home => '홈';

  @override
  String get notifications => '알림';

  @override
  String get settings => '설정';

  @override
  String get tags => '태그';

  @override
  String get filterTop => '인기';

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
  String get signOut => '로그아웃';

  @override
  String get account => '계정';

  @override
  String get createAccount => '계정 만들기';

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
  String get allNotificationsMarkedAsRead => '모든 알림을 읽음으로 표시했습니다';

  @override
  String get failedToMarkNotificationsRead => '알림을 읽음으로 표시하지 못했습니다';

  @override
  String get noNotificationsYet => '아직 알림이 없습니다';

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
  String get posts => '게시물';

  @override
  String profileJoined(String date) {
    return '$date 가입';
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
    return '검색 실패: $error';
  }

  @override
  String get searchHint => 'Search discussions and posts';

  @override
  String noResultsFor(String query) {
    return 'Nothing found for “$query”.';
  }

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get appearance => '테마';

  @override
  String get appearanceSystem => '시스템 기본값';
}
