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
}
