// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class FlarumLocalizationsZh extends FlarumLocalizations {
  FlarumLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get attachmentDefaultName => '附件';

  @override
  String get share => '分享';

  @override
  String get cancel => '取消';

  @override
  String downloading(String filename) {
    return '正在下载$filename...';
  }

  @override
  String get download => '下载';

  @override
  String errorDownloading(String filename, String error) {
    return '下载$filename时出错: $error';
  }

  @override
  String get video => '视频';

  @override
  String get viewOnWeb => '在网页中查看';

  @override
  String get mediaPause => '暂停';

  @override
  String get mediaPlay => '播放';

  @override
  String get failedToLoadVideo => '无法加载视频';

  @override
  String get close => '关闭';

  @override
  String get spoiler => '剧透';

  @override
  String get image => '图片';

  @override
  String get fileTypeArchive => '压缩包';

  @override
  String get fileTypeAudio => '音频';

  @override
  String get fileTypeFile => '文件';

  @override
  String get fileTypeText => '文本';

  @override
  String get retry => '重试';

  @override
  String get edited => '已编辑';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条回复',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个赞',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => '加载更多';

  @override
  String viewProfileOfUser(String username) {
    return '查看 $username 的个人资料';
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
  String get unread => '未读';

  @override
  String get search => '搜索';

  @override
  String get signIn => '登录';

  @override
  String get profile => '资料';

  @override
  String get following => '关注中';

  @override
  String get home => '首页';

  @override
  String get notifications => '通知';

  @override
  String get settings => '设置';

  @override
  String get tags => '标签';

  @override
  String get filterTop => '热门';

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
