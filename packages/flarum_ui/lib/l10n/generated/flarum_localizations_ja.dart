// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class FlarumLocalizationsJa extends FlarumLocalizations {
  FlarumLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get attachmentDefaultName => '添付ファイル';

  @override
  String get share => '共有';

  @override
  String get cancel => 'キャンセル';

  @override
  String downloading(String filename) {
    return '$filenameをダウンロード中...';
  }

  @override
  String get download => 'ダウンロード';

  @override
  String errorDownloading(String filename, String error) {
    return '$filenameのダウンロードエラー: $error';
  }

  @override
  String get video => '動画';

  @override
  String get viewOnWeb => 'Webで表示';

  @override
  String get mediaPause => '一時停止';

  @override
  String get mediaPlay => '再生';

  @override
  String get failedToLoadVideo => '動画を読み込めませんでした';

  @override
  String get close => '閉じる';

  @override
  String get spoiler => 'ネタバレ';

  @override
  String get image => '画像';

  @override
  String get fileTypeArchive => '圧縮ファイル';

  @override
  String get fileTypeAudio => '音声';

  @override
  String get fileTypeFile => 'ファイル';

  @override
  String get fileTypeText => 'テキスト';

  @override
  String get retry => '再試行';

  @override
  String get edited => '編集済み';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の返信',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'いいね $count 件',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'さらに読み込む';

  @override
  String viewProfileOfUser(String username) {
    return '$username さんのプロフィールを見る';
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
  String get latest => '最新';

  @override
  String get unread => '未読';

  @override
  String get search => '検索';

  @override
  String get signIn => 'ログイン';

  @override
  String get profile => 'プロフィール';

  @override
  String get following => 'フォロー中';

  @override
  String get home => 'ホーム';

  @override
  String get notifications => '通知';

  @override
  String get settings => '設定';

  @override
  String get tags => 'タグ';

  @override
  String get filterTop => 'トップ';

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
  String get signOut => 'サインアウト';

  @override
  String get account => 'アカウント';

  @override
  String get createAccount => 'アカウントを作成';

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
}
