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
  String get copyLink => '링크 복사';

  @override
  String get linkCopied => '링크를 복사했습니다.';

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
  String get saveImage => '이미지 저장';

  @override
  String get imageSaved => '이미지를 저장했습니다.';

  @override
  String get imageSaveFailed => '이미지를 저장하지 못했습니다.';

  @override
  String get imageSaveNotAllowed => '앱에 사진 저장 권한이 없습니다. 휴대폰 설정에서 허용할 수 있습니다.';

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
  String get loadMore => '더 보기';

  @override
  String viewProfileOfUser(String username) {
    return '$username님의 프로필 보기';
  }

  @override
  String get loadEarlierPosts => '더 보기';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 게시물 중 $index',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => '원본 게시물';

  @override
  String get scrubberNow => '최신 게시물';

  @override
  String timeGapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 후',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개월 후',
    );
    return '$_temp0';
  }

  @override
  String timeGapYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count년 후',
    );
    return '$_temp0';
  }

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
  String get someone => '[삭제됨]';

  @override
  String get latest => '최신';

  @override
  String get unread => '읽지 않음';

  @override
  String get search => '검색';

  @override
  String get signIn => '로그인';

  @override
  String get logInToReply => '로그인하고 답글 달기';

  @override
  String get cannotReply => '답장할 수 없음';

  @override
  String get profile => '프로필';

  @override
  String get following => '팔로잉';

  @override
  String get follow => '팔로우';

  @override
  String get home => '홈';

  @override
  String get notifications => '알림';

  @override
  String get notifyPrefNewPost => '누군가 내가 팔로우 중인 게시물에 답장했을 때';

  @override
  String get notifyPrefPostMentioned => '누군가 내 게시물 중 하나에 답장했을 때';

  @override
  String get notifyPrefUserMentioned => '누군가 게시물에서 나를 언급했을 때';

  @override
  String get notifyPrefGroupMentioned => '누군가가 게시물에서 내가 속한 그룹을 언급';

  @override
  String get notifyPrefPostLiked => '누군가 내 게시물 중 하나에 좋아요를 눌렀을 때';

  @override
  String get notifyPrefPostReacted => '누군가 내 게시물 중 하나에 반응했을 때';

  @override
  String get notifyPrefDiscussionRenamed => '누군가 내가 시작한 게시물의 이름을 바꿨을 때';

  @override
  String get notifyPrefDiscussionLocked => '누군가 내 게시물을 잠궜을 때';

  @override
  String get notifyPrefMessageReceived => '누군가 나에게 메시지를 보냈을 때';

  @override
  String get notifyPrefByobuPrivateDiscussionCreated =>
      '누군가 나를 새 비공개 토의에 포함했을 때';

  @override
  String get notifyPrefByobuPrivateDiscussionReplied =>
      '내가 참여한 비공개 토의에 누군가 글을 올렸을 때';

  @override
  String get notifyPrefByobuPrivateDiscussionAdded =>
      '누군가 나를 기존 비공개 토의에 추가했을 때';

  @override
  String get notifyPrefByobuRecipientRemoved => '참여 중인 비공개 토의에서 누군가 나갔을 때';

  @override
  String get notifyPrefAwardedBestAnswer => '누군가 내 게시물을 베스트 답변으로 선택했을 때';

  @override
  String get notifyPrefBestAnswerInDiscussion => '내가 참여한 토의에서 베스트 답변이 선택되었을 때';

  @override
  String get notifyPrefSelectBestAnswer => '내가 시작한 토의에서 베스트 답변을 고르라는 자동 알림';

  @override
  String get notifyPrefNewDiscussionInTag => '내가 팔로우하는 태그에 누군가 토의를 만들었을 때';

  @override
  String get notifyPrefNewPostInTag => '내가 팔로우하는 태그에 누군가 글을 올렸을 때';

  @override
  String get notifyPrefNewDiscussionTag => '누군가 토의의 태그를 내가 팔로우하는 태그로 바꿨을 때';

  @override
  String get notifyByWeb => '웹';

  @override
  String get notifyByEmail => '이메일';

  @override
  String get notifyByPush => '푸시 알림';

  @override
  String get followAfterReply => '답장한 게시물을 자동으로 팔로우';

  @override
  String get followAfterCreate => '내가 만든 토의를 자동으로 팔로우';

  @override
  String get notifyForAllPosts => '토론에서 모든 새로운 게시물에 대해 알림을 받도록 설정';

  @override
  String get settings => '설정';

  @override
  String get tags => '태그';

  @override
  String get filterTop => '인기';

  @override
  String get viewNewest => '새 토론';

  @override
  String get allDiscussions => '모든 토의';

  @override
  String get sortOldest => '오래된 순';

  @override
  String get sortTitleAz => '제목 (A–Z)';

  @override
  String get sortTitleZa => '제목 (Z–A)';

  @override
  String get changeSorting => '토의 정렬 방식 변경';

  @override
  String get toggleNavigation => '탐색 드롭다운 메뉴 토글하기';

  @override
  String discussionReplied(String user, String time) {
    return '$user님이 $time에 답글';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user님이 $time에 시작';
  }

  @override
  String get noDiscussions => '여기엔 토론이 없는 것 같습니다.';

  @override
  String get discussionsLoadFailed => '토론을 불러오지 못했습니다.';

  @override
  String get tagsLoadFailed => '태그를 불러오지 못했습니다.';

  @override
  String get signOut => '로그아웃';

  @override
  String logOutQuestion(String forum) {
    return '$forum에서 로그아웃하시겠습니까?';
  }

  @override
  String get account => '계정';

  @override
  String get createAccount => '가입';

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
  String get noNotificationsYet => '알림 없음';

  @override
  String notifNewPost(String user, String title) {
    return '$user님이 $title에 게시했습니다';
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
    return '$user님이 제목을 $title(으)로 변경했습니다';
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
    return '$user님이 $title의 태그를 변경했습니다';
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
    return '질문이 해결되었다면 $title에서 베스트 답변을 선택하세요';
  }

  @override
  String notifMessage(String user) {
    return '$user님이 메시지를 보냈습니다';
  }

  @override
  String get notifSuspended => '계정이 정지되었습니다';

  @override
  String get notifUnsuspended => '정지가 해제되었습니다';

  @override
  String get notifExport => '데이터 내보내기가 준비되었습니다';

  @override
  String get notifOther => '새 알림';

  @override
  String notifLineNewPost(String user) {
    return '$user님이 글을 올렸습니다';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user님이 회원님의 글을 좋아합니다';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user님이 회원님의 글에 반응했습니다';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user님이 회원님의 글에 답글을 남겼습니다';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user님이 회원님을 언급했습니다';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user님이 회원님이 속한 그룹을 언급했습니다';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user님이 제목을 변경했습니다';
  }

  @override
  String notifLineLocked(String user) {
    return '$user님이 잠갔습니다';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user님이 시작했습니다';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user님이 태그를 변경했습니다';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user님이 회원님과 비공개 토론을 시작했습니다';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user님이 회원님이 참여한 비공개 토론에 글을 올렸습니다';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user님이 회원님을 비공개 토론에 추가했습니다';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user님이 회원님을 비공개 토론에서 제외했습니다';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user님이 모든 참여자를 제외하고 토론을 공개했습니다';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return '회원님의 글이 $user님에 의해 베스트 답변으로 선택되었습니다';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user님이 이 토론의 베스트 답변을 선택했습니다';
  }

  @override
  String get notifLineBestAnswerPending => '질문에 답을 얻었다면 베스트 답변을 선택해 주세요';

  @override
  String get aDiscussion => '토론';

  @override
  String get notificationsLoadFailed => '알림을 불러오지 못했습니다.';

  @override
  String get notificationsSignIn => '알림을 보려면 로그인하세요.';

  @override
  String get markAllRead => '모두 읽음으로 표시';

  @override
  String get markAsRead => '읽음으로 표시';

  @override
  String get markAllDiscussionsReadQuestion => '모든 토론을 읽은 것으로 표시하시겠습니까?';

  @override
  String get hideWelcomeMessage => '환영 메세지 숨기기';

  @override
  String get posts => '게시물';

  @override
  String get usersTab => '사용자';

  @override
  String get likesTab => '좋아요';

  @override
  String get mentionsTab => '언급';

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
  String get online => '온라인';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개',
    );
    return '베스트 답변 $_temp0';
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
  String get noPostsYet => '여기엔 게시물이 없는 것 같습니다.';

  @override
  String searchFailedWithError(String error) {
    return '검색 실패: $error';
  }

  @override
  String get searchHint => '검색';

  @override
  String get recentSearches => '최근 검색';

  @override
  String get clearRecentSearches => '지우기';

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
  String get repliesTitle => '이 게시물에 대한 답글';

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
  String get mentionUser => '사용자, 그룹 또는 게시물 언급';

  @override
  String get title => '제목';

  @override
  String get content => '내용';

  @override
  String get send => '메시지 보내기';

  @override
  String get postReply => '글쓰기';

  @override
  String get postDiscussion => '토론 게시';

  @override
  String get postPrivateDiscussion => '비공개 토론 게시';

  @override
  String get save => '변경사항 저장';

  @override
  String get discardReplyQuestion => '답글을 게시하지 않았습니다. 답글을 버리시겠습니까?';

  @override
  String get discardDiscussionQuestion => '토의 내용을 게시하지 않았습니다. 게시를 취소하시겠습니까?';

  @override
  String get discardEditQuestion => '변경 내용을 저장하지 않았습니다. 변경 내용을 취소하시겠습니까?';

  @override
  String get discard => '버리기';

  @override
  String get saveDraft => '임시 저장';

  @override
  String get formatting => '서식';

  @override
  String get addBold => '굵은 텍스트 추가';

  @override
  String get addItalic => '이탤릭체 텍스트 추가';

  @override
  String get insertQuote => '인용문 삽입';

  @override
  String get addLink => '링크 추가';

  @override
  String get addBulletedList => '글머리 기호 목록 추가';

  @override
  String get insertCode => '코드 삽입';

  @override
  String get pleaseEnterTitle => '제목을 입력하세요';

  @override
  String get pleaseEnterContent => '내용을 입력하세요';

  @override
  String get composerTitleHint => '토론 제목';

  @override
  String get privateDiscussionTitleHint => '비공개 토론 제목';

  @override
  String get composerContentHint => '게시물을 작성하세요...';

  @override
  String get composerReplyHint => '답장 쓰기...';

  @override
  String get composerFormattingHint => '서식 옵션 열기';

  @override
  String get searchUsers => '사용자 검색...';

  @override
  String get startDiscussion => '토론 시작';

  @override
  String get editPost => '게시물 수정';

  @override
  String get postingThrottled => '요청이 너무 빠릅니다. 잠시 후에 다시 시도하세요.';

  @override
  String get postAwaitingApproval => '게시되었습니다. 운영자가 승인하면 표시됩니다.';

  @override
  String get chooseTags => '태그 선택';

  @override
  String get ok => '확인';

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
  String likedByOne(String a) {
    return '$a님이 좋아합니다.';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a님과 $b님이 좋아합니다.';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others명',
    );
    return '$a님 외 $_temp0이 좋아합니다.';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others명',
    );
    return '$a님, $b님 외 $_temp0이 좋아합니다.';
  }

  @override
  String get likedByYou => '회원님이 좋아합니다.';

  @override
  String likedByYouAndOne(String a) {
    return '회원님과 $a님이 좋아합니다.';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others명',
    );
    return '회원님, $a님 외 $_temp0이 좋아합니다.';
  }

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
  String get notFollowing => '팔로우 안 함';

  @override
  String get notFollowingHint => '@멘션될 때만 알림을 받습니다.';

  @override
  String get followingHint => '모든 답글 알림을 받습니다.';

  @override
  String get ignoring => '무시';

  @override
  String get ignoringHint => '알림을 받지 않고 토론 목록에서도 숨깁니다.';

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
      '이 게시물은 모욕적, 폭력적이거나 커뮤니티 가이드라인을 위반합니다.';

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
  String get flaggedPosts => '신고된 게시물';

  @override
  String get noFlags => '신고 없음';

  @override
  String flaggedPostItem(String username, String discussion) {
    return '$discussion의 $username님';
  }

  @override
  String flaggedByWithReason(String username, String reason) {
    return '$username님이 $reason로 신고함';
  }

  @override
  String flaggedBy(String username) {
    return '$username님이 신고함';
  }

  @override
  String get dismissFlag => '신고 해제';

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
    return '$name 님을 무시하시겠습니까?';
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
  String get termsBanner => '새 약관을 확인하는 동안 계정 접근이 일시적으로 제한되었습니다.';

  @override
  String get termsReview => '검토';

  @override
  String get termsTitle => '변경된 약관';

  @override
  String get termsIntro => '마지막 방문 이후 약관이 변경되었습니다';

  @override
  String get readPolicy => '읽기';

  @override
  String get acceptTerms => '동의';

  @override
  String get termsAccepted => '동의해 주셔서 감사합니다. 이제 포럼으로 돌아갈 수 있습니다.';

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
  String get choosePerson =>
      '이 토론은 여기에서 선택한 사용자에게만 표시됩니다. 나를 제외하고 최소 1명의 참여자가 필요합니다.';

  @override
  String get noPrivateDiscussions => '여기엔 토론이 없는 것 같습니다.';

  @override
  String get privateOnlyOne => '이 포럼에서는 한 번에 한 사람에게만 비공개로 글을 쓸 수 있습니다.';

  @override
  String get messages => '메시지';

  @override
  String get markAllMessagesRead => '모두 읽음으로 표시';

  @override
  String get startOfConversation => '대화의 시작';

  @override
  String get messageCopied => '메시지를 복사했습니다.';

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
  String get editTags => '태그 편집';

  @override
  String get renameDiscussionTitle => '토론 이름 변경';

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
  String get deleteForeverConfirm => '영구히 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get approve => '승인';

  @override
  String get unsuspend => '정지 해제';

  @override
  String get suspend => '정지';

  @override
  String suspendUserTitle(String username) {
    return '$username님을 정지';
  }

  @override
  String get suspensionStatus => '정지 상태';

  @override
  String get notSuspended => '일시 정지되지 않음';

  @override
  String get suspendIndefinitely => '무기한 정지';

  @override
  String get suspendLimitedTime => '일정 기간 정지...';

  @override
  String get suspendDays => '일간';

  @override
  String get suspendReasonLabel => '정지 사유';

  @override
  String get suspendMessageLabel => '사용자에게 표시할 메시지';

  @override
  String get optional => '선택 사항';

  @override
  String suspendedUntil(String date) {
    return '$date까지 정지됨';
  }

  @override
  String get suspendedIndefinitely => '무기한 정지됨';

  @override
  String youAreSuspended(String date) {
    return '이 정지는 $date까지 유지됩니다';
  }

  @override
  String get youAreSuspendedIndefinitely => '이 계정은 정지되었습니다';

  @override
  String get awaitingApproval => '승인 대기 중';

  @override
  String get badgeSticky => '고정';

  @override
  String get badgeLocked => '잠금';

  @override
  String get badgeHidden => '숨김';

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
  String get errorNotFound => '요청한 리소스를 찾을 수 없습니다.';

  @override
  String get errorRateLimited => '요청이 너무 빠릅니다. 잠시 후에 다시 시도하세요.';

  @override
  String get errorForumDown => '포럼이 지금 응답하지 않습니다. 나중에 다시 시도하세요.';

  @override
  String get errorNotAllowed => '이에 대한 권한이 없습니다.';

  @override
  String get errorUnknown => '이런! 뭔가 잘못되었습니다. 다시 시도하세요.';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count표',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '최대 $count개까지 선택',
    );
    return '$_temp0';
  }

  @override
  String get pollEnded => '투표가 마감되었습니다';

  @override
  String pollEndsOn(String date) {
    return '$date 마감';
  }

  @override
  String get pollResultsAfterVoting => '투표하면 결과를 볼 수 있습니다.';

  @override
  String get pollResultsWhenClosed => '투표가 마감되면 결과를 볼 수 있습니다.';

  @override
  String get pollVote => '투표하기';

  @override
  String get pollRemoveVote => '내 투표 취소';

  @override
  String get pollSeeVoters => '투표한 사람 보기';

  @override
  String get pollNoVotes => '아직 투표가 없습니다.';

  @override
  String get poll => '투표';

  @override
  String get pollNeedsQuestion => '질문을 입력하세요.';

  @override
  String get pollNeedsAnswers => '답변을 두 개 이상 입력하세요.';

  @override
  String get pollEndInPast => '마감 시간은 미래로 선택하세요.';

  @override
  String get pollQuestion => '질문';

  @override
  String pollAnswer(int number) {
    return '답변 $number';
  }

  @override
  String get pollRemoveAnswer => '이 답변 삭제';

  @override
  String get pollAddAnswer => '답변 추가';

  @override
  String get pollMultipleChoice => '여러 개 선택 허용';

  @override
  String get pollChoicesAllowed => '선택 가능 개수';

  @override
  String get pollAnyNumber => '제한 없음';

  @override
  String get pollPublic => '누가 무엇에 투표했는지 표시';

  @override
  String get pollAllowChangeVote => '투표 변경 허용';

  @override
  String get pollCloses => '투표 마감';

  @override
  String get pollNeverCloses => '없음';

  @override
  String get pollHideVotes => '마감 전까지 결과 숨기기';

  @override
  String get pollHideVotesNeedsEnd => '먼저 마감 시간을 선택하세요.';

  @override
  String get addPoll => '투표 추가';

  @override
  String get submit => '제출';

  @override
  String get editPoll => '투표 편집';

  @override
  String get removePoll => '투표 삭제';

  @override
  String get draftSaved => '임시글을 저장했습니다.';

  @override
  String get draftSavedWithoutPoll => '투표 없이 임시글을 저장했습니다. 임시글에는 투표가 저장되지 않습니다.';

  @override
  String get draftNeedsText => '임시글로 저장하려면 내용을 입력하세요.';

  @override
  String get drafts => '임시글';

  @override
  String get draftsLoadFailed => '임시글을 불러오지 못했습니다';

  @override
  String get noDrafts =>
      '임시글이 없습니다. 작성 중인 글을 닫을 때 \'임시 저장\'을(를) 선택하면 여기에 보관됩니다.';

  @override
  String draftReplyTo(String title) {
    return '\'$title\'에 대한 답글';
  }

  @override
  String get draftUntitled => '제목 없는 토론';

  @override
  String get deleteDraftQuestion => '이 임시글을 삭제할까요?';

  @override
  String get deleteDraft => '임시글 삭제';

  @override
  String unreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '읽지 않은 답글 $count개',
    );
    return '$_temp0';
  }

  @override
  String replyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '답글 $count개',
    );
    return '$_temp0';
  }

  @override
  String tagDiscussionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '토론 $count개',
    );
    return '$_temp0';
  }

  @override
  String searchForum(String name) {
    return '$name 검색';
  }

  @override
  String get community => '커뮤니티';

  @override
  String get allTags => '모든 태그';

  @override
  String get otherTags => '기타 태그';

  @override
  String get myPosts => '내 게시물';

  @override
  String get directMessages => '다이렉트 메시지';

  @override
  String get drawerIntroduction =>
      '포럼의 태그와 내 목록이 여기에 있습니다. ☰을 탭하면 다시 열 수 있습니다.';

  @override
  String get goToYourProfile => '내 프로필로 이동';

  @override
  String get notLoggedIn => '로그인하지 않음';

  @override
  String get logInToTakePart => '로그인하면 글을 쓰고, 답글을 달고, 알림을 받을 수 있습니다.';

  @override
  String get logInToSeeMessages => '메시지를 보려면 로그인하세요.';

  @override
  String get noFollowedDiscussions => '아직 팔로우 중인 토론이 없습니다.';

  @override
  String showChildTags(String name) {
    return '$name의 태그 보기';
  }

  @override
  String hideChildTags(String name) {
    return '$name의 태그 숨기기';
  }

  @override
  String get holdForReactions => '길게 눌러 반응 남기기';

  @override
  String removeYourReaction(String name) {
    return '내 반응: $name. 탭하면 취소됩니다.';
  }

  @override
  String get reactionTapAgainToRemove => '같은 반응을 다시 선택하면 취소됩니다.';

  @override
  String get likesAndReactions => '좋아요와 반응';

  @override
  String get you => '나';

  @override
  String andOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '외 $count명',
    );
    return '$_temp0';
  }

  @override
  String likesAndReactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '좋아요와 반응 $count개. 누가 했는지 보기',
    );
    return '$_temp0';
  }

  @override
  String get accountAndPrivacy => '계정 및 개인정보';

  @override
  String get editProfile => '프로필 편집';

  @override
  String get forumSettingsPage => '이메일, 비밀번호 등';

  @override
  String get forumSettingsPageHint => '포럼 설정 페이지에서';

  @override
  String get ignoredUsersHint => '게시물을 숨긴 회원';

  @override
  String get message => '메시지';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get privacy => '개인정보';

  @override
  String get viewProfile => '프로필 보기';

  @override
  String get yourStuff => '내 항목';

  @override
  String joinForum(String name) {
    return '$name에 가입';
  }

  @override
  String statDiscussions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '토론',
    );
    return '$_temp0';
  }

  @override
  String statPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '게시물',
    );
    return '$_temp0';
  }

  @override
  String statBestAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '베스트 답변',
    );
    return '$_temp0';
  }

  @override
  String get composerPost => '게시';

  @override
  String get composerSend => '보내기';

  @override
  String get composerSave => '저장';

  @override
  String get bulletedList => '글머리 기호 목록';

  @override
  String get profilePicture => '프로필 사진';

  @override
  String get changeProfilePicture => '프로필 사진 변경';

  @override
  String get chooseFromLibrary => '보관함에서 선택';

  @override
  String get removeProfilePicture => '사진 삭제';

  @override
  String get profilePictureUpdated => '프로필 사진을 변경했습니다.';

  @override
  String get profilePictureRemoved => '프로필 사진을 삭제했습니다.';

  @override
  String get displayName => '표시 이름';

  @override
  String displayNameHelper(String username) {
    return '비워 두면 사용자 이름($username)이 표시됩니다.';
  }

  @override
  String get displayNameSaved => '표시 이름을 저장했습니다.';

  @override
  String get displayNameLocked => '이 포럼에서는 표시 이름을 변경할 수 없습니다.';

  @override
  String get usernameField => '사용자 이름';

  @override
  String get usernameAdminsOnly => '사용자 이름은 포럼 관리자만 변경할 수 있습니다.';

  @override
  String get undo => '실행 취소';

  @override
  String get googleSignInRefused =>
      'Google은 앱 안에서의 로그인을 허용하지 않습니다. 사용자 이름이나 이메일과 비밀번호로 로그인하세요.';

  @override
  String get googleSignInNeedsExtension =>
      'Google은 앱 안에서의 로그인을 허용하지 않습니다. 비밀번호로 로그인하거나, 이 포럼 관리자에게 Flapp 확장 기능 설치를 요청하세요. 설치되면 Google로 로그인할 수 있습니다.';

  @override
  String get confirmEmailTitle => '이메일을 확인하세요';

  @override
  String confirmEmailText(String email) {
    return '포럼이 $email(으)로 링크를 보냈습니다. 링크를 열어 가입을 마치세요. 그때까지는 읽기만 할 수 있습니다.';
  }

  @override
  String get confirmEmailTextNoAddress =>
      '포럼이 이메일로 링크를 보냈습니다. 링크를 열어 가입을 마치세요. 그때까지는 읽기만 할 수 있습니다.';

  @override
  String get resendConfirmationEmail => '다시 보내기';

  @override
  String get confirmationEmailSent => '보냈습니다. 받은편지함을 확인하세요.';
}
