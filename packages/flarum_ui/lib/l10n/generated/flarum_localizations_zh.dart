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
  String get loadEarlierPosts => '加载更早的帖子';

  @override
  String get postHidden => '此帖子已被删除。';

  @override
  String get threadLoadFailed => '无法加载此讨论。';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$user 将标题从“$from”改为“$to”。';
  }

  @override
  String eventLocked(String user) {
    return '$user 锁定了讨论。';
  }

  @override
  String eventUnlocked(String user) {
    return '$user 解锁了讨论。';
  }

  @override
  String eventStickied(String user) {
    return '$user 置顶了讨论。';
  }

  @override
  String eventUnstickied(String user) {
    return '$user 取消了讨论置顶。';
  }

  @override
  String eventTagged(String user) {
    return '$user 更改了标签。';
  }

  @override
  String eventOther(String user) {
    return '$user 修改了讨论。';
  }

  @override
  String get someone => '某人';

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
  String get viewNewest => '最新发布';

  @override
  String discussionReplied(String user, String time) {
    return '$user 回复于 $time';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$user 发起于 $time';
  }

  @override
  String get noDiscussions => '这里还没有讨论。';

  @override
  String get discussionsLoadFailed => '无法加载讨论。';

  @override
  String get tagsLoadFailed => '无法加载标签。';

  @override
  String get signOut => '退出登录';

  @override
  String get account => '账户';

  @override
  String get createAccount => '创建账户';

  @override
  String signInFailedReason(String reason) {
    return '无法登录：$reason';
  }

  @override
  String get signInHint => '请在论坛自己的页面登录。退出之前，应用会一直保持登录。';

  @override
  String signedInAs(String name) {
    return '已登录为 $name';
  }

  @override
  String get allNotificationsMarkedAsRead => '所有通知已标记为已读';

  @override
  String get failedToMarkNotificationsRead => '无法将通知标记为已读';

  @override
  String get noNotificationsYet => '还没有通知';

  @override
  String notifNewPost(String user, String title) {
    return '$user 回复了 $title';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$user 赞了你在 $title 中的帖子';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$user 对你在 $title 中的帖子做出了回应';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$user 回复了你在 $title 中的帖子';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$user 在 $title 中提到了你';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$user 在 $title 中提到了你所在的群组';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user 将一个讨论重命名为 $title';
  }

  @override
  String notifLocked(String user, String title) {
    return '$user 锁定了 $title';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$user 发起了 $title';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$user 将 $title 移到了你关注的标签';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user 与你发起了私密讨论：$title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user 回复了私密讨论 $title';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$user 将你加入了私密讨论 $title';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$user 将你移出了私密讨论 $title';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$user 公开了 $title';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$user 在 $title 中将你的帖子选为最佳答案';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user 在 $title 中选出了最佳答案';
  }

  @override
  String notifBestAnswerPending(String title) {
    return '请在 $title 中选出最佳答案';
  }

  @override
  String notifMessage(String user) {
    return '$user 给你发送了一条消息';
  }

  @override
  String get notifSuspended => '你的账号已被封禁';

  @override
  String get notifUnsuspended => '你的账号已解除封禁';

  @override
  String get notifExport => '你的数据导出已就绪';

  @override
  String get notifOther => '新通知';

  @override
  String get aDiscussion => '一个讨论';

  @override
  String get notificationsLoadFailed => '无法加载你的通知。';

  @override
  String get notificationsSignIn => '登录后查看你的通知。';

  @override
  String get markAllRead => '全部标为已读';

  @override
  String get posts => '帖子';

  @override
  String profileJoined(String date) {
    return '$date 加入';
  }

  @override
  String get discussionsTab => '讨论';

  @override
  String lastSeen(String time) {
    return '最后在线：$time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: '$discussions 个讨论',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments 个帖子',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => '无法加载此个人资料。';

  @override
  String get noPostsYet => '还没有帖子。';

  @override
  String searchFailedWithError(String error) {
    return '搜索失败：$error';
  }

  @override
  String get searchHint => '搜索讨论和帖子';

  @override
  String noResultsFor(String query) {
    return '未找到与“$query”相关的内容。';
  }

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get appearance => '外观';

  @override
  String get appearanceSystem => '跟随系统';

  @override
  String repliedByOne(String a) {
    return '$a 回复了此帖。';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$a 和 $b 回复了此帖。';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others',
    );
    return '$a、$b 和另外 $_temp0 条回复。';
  }

  @override
  String get repliesTitle => '回复';

  @override
  String postNumber(int number) {
    return '第 $number 楼';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others',
    );
    return '$a 和另外 $_temp0 条回复。';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$user 添加了 $tags。';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$user 移除了 $tags。';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$user 添加了 $added，移除了 $removed。';
  }

  @override
  String get privateDiscussion => '私密讨论';

  @override
  String get bestAnswer => '最佳答案';

  @override
  String get goToBestAnswer => '查看最佳答案';

  @override
  String get answered => '已解决';

  @override
  String eventRecipientsChanged(String user) {
    return '$user 更改了此私密讨论的参与者。';
  }

  @override
  String get noTagsOnForum => '此论坛未使用标签。';

  @override
  String get permissionRequired => '需要权限';
}
