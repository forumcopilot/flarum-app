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
  String get loadEarlierPosts => '이전 게시물 불러오기';

  @override
  String get postHidden => '삭제된 게시물입니다.';

  @override
  String get threadLoadFailed => '이 토론을 불러오지 못했습니다.';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user님이 제목을 “$from”에서 “$to”(으)로 변경했습니다.';
  }

  @override
  String eventLocked(String user) {
    return '$user님이 토론을 잠갔습니다.';
  }

  @override
  String eventUnlocked(String user) {
    return '$user님이 토론 잠금을 해제했습니다.';
  }

  @override
  String eventStickied(String user) {
    return '$user님이 토론을 고정했습니다.';
  }

  @override
  String eventUnstickied(String user) {
    return '$user님이 토론 고정을 해제했습니다.';
  }

  @override
  String eventTagged(String user) {
    return '$user님이 태그를 변경했습니다.';
  }

  @override
  String eventOther(String user) {
    return '$user님이 토론을 변경했습니다.';
  }

  @override
  String get someone => '누군가';

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
  String get viewNewest => '새 토론';

  @override
  String discussionReplied(String user, String time) {
    return '$user님이 $time에 답글';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user님이 $time에 시작';
  }

  @override
  String get noDiscussions => '아직 토론이 없습니다.';

  @override
  String get discussionsLoadFailed => '토론을 불러오지 못했습니다.';

  @override
  String get tagsLoadFailed => '태그를 불러오지 못했습니다.';

  @override
  String get signOut => '로그아웃';

  @override
  String get account => '계정';

  @override
  String get createAccount => '계정 만들기';

  @override
  String signInFailedReason(String reason) {
    return '로그인하지 못했습니다: $reason';
  }

  @override
  String get signInHint => '포럼 페이지에서 로그인하세요. 로그아웃할 때까지 로그인 상태가 유지됩니다.';

  @override
  String signedInAs(String name) {
    return '$name(으)로 로그인됨';
  }

  @override
  String get allNotificationsMarkedAsRead => '모든 알림을 읽음으로 표시했습니다';

  @override
  String get failedToMarkNotificationsRead => '알림을 읽음으로 표시하지 못했습니다';

  @override
  String get noNotificationsYet => '아직 알림이 없습니다';

  @override
  String notifNewPost(String user, String title) {
    return '$user님이 $title에 답글을 남겼습니다';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user님이 $title의 내 게시물을 좋아합니다';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user님이 $title의 내 게시물에 반응했습니다';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user님이 $title의 내 게시물에 답글을 남겼습니다';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user님이 $title에서 나를 언급했습니다';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user님이 $title에서 내가 속한 그룹을 언급했습니다';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user님이 토론 제목을 $title(으)로 바꿨습니다';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user님이 $title을(를) 잠갔습니다';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user님이 $title을(를) 시작했습니다';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user님이 $title을(를) 내가 팔로우하는 태그로 옮겼습니다';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user님이 나와 비공개 토론을 시작했습니다: $title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user님이 비공개 토론 $title에 답글을 남겼습니다';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user님이 나를 비공개 토론 $title에 추가했습니다';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user님이 나를 비공개 토론 $title에서 제외했습니다';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user님이 $title을(를) 공개했습니다';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user님이 $title에서 내 게시물을 베스트 답변으로 선택했습니다';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user님이 $title에서 베스트 답변을 선택했습니다';
  }

  @override
  String notifBestAnswerPending(String title) {
    return '$title에서 베스트 답변을 선택하세요';
  }

  @override
  String notifMessage(String user) {
    return '$user님이 메시지를 보냈습니다';
  }

  @override
  String get notifSuspended => '계정이 정지되었습니다';

  @override
  String get notifUnsuspended => '계정 정지가 해제되었습니다';

  @override
  String get notifExport => '데이터 내보내기가 준비되었습니다';

  @override
  String get notifOther => '새 알림';

  @override
  String get aDiscussion => '토론';

  @override
  String get notificationsLoadFailed => '알림을 불러오지 못했습니다.';

  @override
  String get notificationsSignIn => '알림을 보려면 로그인하세요.';

  @override
  String get markAllRead => '모두 읽음으로 표시';

  @override
  String get posts => '게시물';

  @override
  String profileJoined(String date) {
    return '$date 가입';
  }

  @override
  String get discussionsTab => '토론';

  @override
  String lastSeen(String time) {
    return '마지막 접속: $time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '토론 $discussions개',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '게시물 $comments개',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => '이 프로필을 불러오지 못했습니다.';

  @override
  String get noPostsYet => '아직 게시물이 없습니다.';

  @override
  String searchFailedWithError(String error) {
    return '검색 실패: $error';
  }

  @override
  String get searchHint => '토론과 게시물 검색';

  @override
  String noResultsFor(String query) {
    return '“$query”에 대한 결과가 없습니다.';
  }

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get appearance => '테마';

  @override
  String get appearanceSystem => '시스템 기본값';

  @override
  String repliedByOne(String a) {
    return '$a님이 답글을 남겼습니다.';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a님과 $b님이 답글을 남겼습니다.';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others건',
    );
    return '$a님, $b님 외 $_temp0의 답글이 있습니다.';
  }

  @override
  String get repliesTitle => '답글';

  @override
  String postNumber(int number) {
    return '게시물 #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others건',
    );
    return '$a님 외 $_temp0의 답글이 있습니다.';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user님이 $tags을(를) 추가했습니다.';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user님이 $tags을(를) 제거했습니다.';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user님이 $added을(를) 추가하고 $removed을(를) 제거했습니다.';
  }

  @override
  String get privateDiscussion => '비공개 토론';

  @override
  String get bestAnswer => '베스트 답변';

  @override
  String get goToBestAnswer => '베스트 답변으로 이동';

  @override
  String get answered => '해결됨';

  @override
  String eventRecipientsChanged(String user) {
    return '$user님이 이 비공개 토론의 참여자를 변경했습니다.';
  }

  @override
  String get noTagsOnForum => '이 포럼은 태그를 사용하지 않습니다.';

  @override
  String get permissionRequired => '권한이 필요합니다';

  @override
  String get bold => '굵게';

  @override
  String get underline => '밑줄';

  @override
  String get strikethrough => '취소선';

  @override
  String get bulletList => '글머리 기호 목록';

  @override
  String get numberedList => '번호 매기기 목록';

  @override
  String get listItem => '목록 항목';

  @override
  String get mentionUser => '사용자 멘션';

  @override
  String get title => '제목';

  @override
  String get content => '내용';

  @override
  String get send => '보내기';

  @override
  String get save => '저장';

  @override
  String get formatting => '서식';

  @override
  String get pleaseEnterTitle => '제목을 입력하세요';

  @override
  String get pleaseEnterContent => '내용을 입력하세요';

  @override
  String get composerTitleHint => '제목 작성...';

  @override
  String get composerContentHint => '내용 작성...';

  @override
  String get composerFormattingHint => '서식 옵션 열기';

  @override
  String get searchUsers => '사용자 검색...';

  @override
  String get startDiscussion => '토론 시작하기';

  @override
  String get editPost => '게시물 수정';

  @override
  String get postingThrottled => '너무 빨리 게시하고 있습니다. 몇 초 후에 다시 시도하세요.';

  @override
  String get postAwaitingApproval => '게시되었습니다. 운영자가 승인하면 표시됩니다.';

  @override
  String get chooseTags => '태그 선택';

  @override
  String get primaryTags => '주요 태그';

  @override
  String get secondaryTags => '추가 태그';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '주요 태그를 $count개 선택하세요.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '주요 태그는 최대 $count개까지 선택할 수 있습니다.',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '태그를 $count개 더 선택하세요.',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '추가 태그는 최대 $count개까지 선택할 수 있습니다.',
    );
    return '$_temp0';
  }

  @override
  String get done => '완료';

  @override
  String get noMembersFound => '회원을 찾을 수 없습니다.';

  @override
  String get memberSearchNotAllowed => '이 포럼에서는 회원을 검색할 수 없습니다.';

  @override
  String get editLoadFailed => '수정할 게시물을 불러오지 못했습니다.';

  @override
  String get like => '좋아요';

  @override
  String get unlike => '좋아요 취소';

  @override
  String get react => '반응';

  @override
  String get reactions => '반응';

  @override
  String get bookmark => '북마크';

  @override
  String get removeBookmark => '북마크 해제';

  @override
  String get bookmarks => '북마크';

  @override
  String get noBookmarks => '아직 북마크가 없습니다.';

  @override
  String get chooseBestAnswer => '베스트 답변으로 선택';

  @override
  String get removeBestAnswer => '베스트 답변 해제';

  @override
  String get notificationSettings => '이 토론의 알림';

  @override
  String get notFollowing => '팔로우 안 함';

  @override
  String get notFollowingHint => '@멘션될 때만 알림을 받습니다.';

  @override
  String get followingHint => '모든 답글 알림을 받습니다.';

  @override
  String get ignoring => '무시';

  @override
  String get ignoringHint => '알림을 받지 않고 목록에서도 숨깁니다.';

  @override
  String get tagFollowingHint => '새 토론 알림을 받습니다.';

  @override
  String get lurking => '지켜보기';

  @override
  String get lurkingHint => '새 토론과 모든 답글 알림을 받습니다.';

  @override
  String get tagIgnoringHint => '여기의 토론은 알림을 받지 않습니다.';

  @override
  String get hidden => '숨김';

  @override
  String get hiddenHint => '이 태그의 토론을 목록에서 숨깁니다.';

  @override
  String get attachFile => '파일 첨부';

  @override
  String get uploadImage => '이미지 업로드';

  @override
  String get takePhoto => '사진 촬영';

  @override
  String uploadingFilename(String filename) {
    return '업로드 중: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return '파일 업로드 실패: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      '첨부 파일 업로드가 끝날 때까지 기다려 주세요';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName을(를) $limit 제한에 맞게 $size$dimensions(으)로 줄였습니다.';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: 너무 크며($size) 크기를 줄일 수 없습니다. 제한은 $limit입니다.';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName의 크기는 $fileBytes입니다. 이 포럼은 최대 $maxBytes까지 허용합니다.';
  }

  @override
  String get flagAction => '신고';

  @override
  String get ignoredUsers => '무시한 사용자';

  @override
  String get ignoredUsersEmpty => '무시하고 있는 사용자가 없습니다.';

  @override
  String get flagPostTitle => '게시물 신고';

  @override
  String get flagReasonOffTopic => '주제에서 벗어남';

  @override
  String get flagReasonOffTopicText => '이 게시물은 현재 토론과 관련이 없어 다른 곳으로 옮겨야 합니다.';

  @override
  String get flagReasonInappropriate => '부적절함';

  @override
  String get flagReasonInappropriateText =>
      '이 게시물은 공격적이거나 모욕적이거나 커뮤니티 가이드라인을 위반합니다.';

  @override
  String get flagReasonSpam => '스팸';

  @override
  String get flagReasonSpamText => '이 게시물은 광고입니다.';

  @override
  String get flagReasonOther => '기타 (직접 입력)';

  @override
  String get flagDetails => '추가 설명 (선택)';

  @override
  String get flagDetailsNeeded => '운영진에게 자세한 내용을 알려 주세요.';

  @override
  String get communityGuidelines => '커뮤니티 가이드라인';

  @override
  String get flagSent => '신고해 주셔서 감사합니다. 운영진이 확인할 예정입니다.';

  @override
  String ignoreUser(String name) {
    return '$name 무시하기';
  }

  @override
  String stopIgnoringUser(String name) {
    return '$name 무시 해제';
  }

  @override
  String ignoreUserConfirm(String name) {
    return '$name 님을 무시할까요? 이 사용자의 게시물이 접혀서 표시됩니다. 계정에서 언제든 해제할 수 있습니다.';
  }

  @override
  String ignoredUserPost(String name) {
    return '무시 중인 $name 님의 게시물입니다.';
  }

  @override
  String get showPost => '게시물 보기';

  @override
  String get ignoredOnThisPhone => '이 포럼에는 무시 목록이 없어 앱이 이 기기에 목록을 저장합니다.';

  @override
  String get stopIgnoring => '무시 해제';

  @override
  String get termsBanner => '다시 글을 쓰려면 이 포럼의 변경된 약관에 동의하세요.';

  @override
  String get termsReview => '검토';

  @override
  String get termsTitle => '변경된 약관';

  @override
  String get termsIntro => '다시 글을 쓰기 전에 포럼의 변경된 정책에 동의해 주세요.';

  @override
  String get readPolicy => '읽기';

  @override
  String get acceptTerms => '동의';

  @override
  String get termsAccepted => '감사합니다. 이제 다시 글을 쓸 수 있습니다.';

  @override
  String get privateDiscussions => '비공개 토론';

  @override
  String get startPrivateDiscussion => '비공개 토론 시작';

  @override
  String privateWith(String names) {
    return '$names 님과';
  }

  @override
  String get addPerson => '사람 추가';

  @override
  String get choosePerson => '글을 보낼 사람을 선택하세요.';

  @override
  String get noPrivateDiscussions => '아직 비공개 토론이 없습니다.';

  @override
  String get privateOnlyOne => '이 포럼에서는 한 번에 한 사람에게만 비공개로 글을 쓸 수 있습니다.';

  @override
  String get messages => '메시지';

  @override
  String get newMessage => '새 메시지';

  @override
  String get noMessages => '아직 메시지가 없습니다.';

  @override
  String get sendMessage => '메시지 보내기';

  @override
  String get messageHint => '메시지 작성…';

  @override
  String get messagesLoadFailed => '메시지를 불러오지 못했습니다.';

  @override
  String get moderate => '관리';

  @override
  String get renameDiscussion => '이름 바꾸기';

  @override
  String get lockDiscussion => '잠금';

  @override
  String get unlockDiscussion => '잠금 해제';

  @override
  String get stickDiscussion => '고정';

  @override
  String get unstickDiscussion => '고정 해제';

  @override
  String get restore => '복원';

  @override
  String get deleteForever => '영구 삭제';

  @override
  String get deleteForeverConfirm => '영구 삭제할까요? 되돌릴 수 없습니다.';

  @override
  String get approve => '승인';

  @override
  String get unsuspend => '정지 해제';

  @override
  String suspendedUntil(String date) {
    return '$date까지 정지됨';
  }

  @override
  String get suspendedIndefinitely => '무기한 정지됨';

  @override
  String youAreSuspended(String date) {
    return '$date까지 이용이 정지되었습니다.';
  }

  @override
  String get youAreSuspendedIndefinitely => '이용이 정지되었습니다.';

  @override
  String get awaitingApproval => '승인 대기 중';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '게시물 $count개',
    );
    return '$user 님이 $titles의 $_temp0를 이 토론으로 병합했습니다.';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '게시물 $count개',
    );
    return '$user 님이 $_temp0를 $title(으)로 분리했습니다.';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '게시물 $count개',
    );
    return '$user 님이 $title에서 $_temp0를 분리했습니다.';
  }

  @override
  String get errorNoConnection => '포럼에 연결할 수 없습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get errorTimedOut => '포럼 응답이 너무 오래 걸립니다. 다시 시도하세요.';

  @override
  String get errorBlocked => '포럼의 방화벽이 앱을 차단했습니다. 나중에 다시 시도하거나 브라우저에서 포럼을 여세요.';

  @override
  String get errorNotFound => '존재하지 않거나 삭제되었습니다.';

  @override
  String get errorRateLimited => '너무 자주 시도하고 있습니다. 잠시 후 다시 시도하세요.';

  @override
  String get errorForumDown => '포럼이 지금 응답하지 않습니다. 나중에 다시 시도하세요.';

  @override
  String get errorNotAllowed => '그 작업을 할 권한이 없습니다.';

  @override
  String get errorUnknown => '문제가 발생했습니다. 다시 시도하세요.';
}
