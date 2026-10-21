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
  String get copyLink => '复制链接';

  @override
  String get linkCopied => '链接已复制。';

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
  String get loadEarlierPosts => '加载更多';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$index / $count 条',
      one: '$index / $count 条',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => '最早内容';

  @override
  String get scrubberNow => '最新回复';

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
  String get someone => '[已注销]';

  @override
  String get latest => '最新';

  @override
  String get unread => '未读';

  @override
  String get search => '搜索';

  @override
  String get signIn => '登录';

  @override
  String get logInToReply => '登录以回复';

  @override
  String get cannotReply => '回复已关闭';

  @override
  String get profile => '资料';

  @override
  String get following => '关注中';

  @override
  String get follow => '关注';

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
  String get noDiscussions => '这里空空如也……';

  @override
  String get discussionsLoadFailed => '无法加载讨论。';

  @override
  String get tagsLoadFailed => '无法加载标签。';

  @override
  String get signOut => '退出登录';

  @override
  String logOutQuestion(String forum) {
    return '确定要登出 $forum 吗？';
  }

  @override
  String get account => '账户';

  @override
  String get createAccount => '注册';

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
  String get noNotificationsYet => '暂无通知';

  @override
  String notifNewPost(String user, String title) {
    return '$user 在 $title 中发布了新内容';
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
    return '$user 在 $title 中提及了你所在的用户组';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$user 将标题更改为 $title';
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
    return '$user 更改了 $title 的标签';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$user 邀请你加入新的私密讨论：$title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$user 在你参与的私密讨论中发布了新内容：$title';
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
    return '$user 在 $title 中将你的帖子设为最佳回复';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$user 在 $title 中选择了最佳回复';
  }

  @override
  String notifBestAnswerPending(String title) {
    return '如果你的问题已经解决，别忘了在 $title 中选择最佳回复';
  }

  @override
  String notifMessage(String user) {
    return '$user 给你发送了一条消息';
  }

  @override
  String get notifSuspended => '你的账号已被封禁';

  @override
  String get notifUnsuspended => '你的封禁已解除';

  @override
  String get notifExport => '你的数据导出已准备好，请下载。';

  @override
  String get notifOther => '新通知';

  @override
  String notifLineNewPost(String user) {
    return '$user 发布了新内容';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user 赞了你的帖子';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$user 对你的帖子做出了回应';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user 回复了你的帖子';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user 提及了你';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$user 提及了你所在的用户组';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user 更改了标题';
  }

  @override
  String notifLineLocked(String user) {
    return '$user 锁定了讨论';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$user 发起了讨论';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$user 更改了标签';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$user 与你发起了新的私密讨论';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$user 在你参与的私密讨论中发布了新内容';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$user 将你加入私密讨论';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$user 将你移出了私密讨论';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$user 将讨论转为公开';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return '$user 将你的帖子设为最佳回复';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$user 选择了最佳回复';
  }

  @override
  String get notifLineBestAnswerPending => '如果你的问题已经解决，别忘了选择最佳回复';

  @override
  String get aDiscussion => '一个讨论';

  @override
  String get notificationsLoadFailed => '无法加载你的通知。';

  @override
  String get notificationsSignIn => '登录后查看你的通知。';

  @override
  String get markAllRead => '全部已读';

  @override
  String get markAllDiscussionsReadQuestion => '确定要将所有讨论标记为已读吗？';

  @override
  String get hideWelcomeMessage => '隐藏欢迎横幅';

  @override
  String get posts => '帖子';

  @override
  String get usersTab => '用户';

  @override
  String get likesTab => '赞';

  @override
  String get mentionsTab => '提及';

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
  String get online => '在线';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个最佳回复',
      one: '$count 个最佳回复',
    );
    return '$_temp0';
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
  String get noPostsYet => '这里空空如也……';

  @override
  String searchFailedWithError(String error) {
    return '搜索失败：$error';
  }

  @override
  String get searchHint => '搜索社区';

  @override
  String get recentSearches => '最近搜索';

  @override
  String get clearRecentSearches => '清除';

  @override
  String noResultsFor(String query) {
    return '似乎没有与“$query”相关的内容…';
  }

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get appearance => '显示模式';

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
  String get repliesTitle => '此帖的回复';

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
  String get bestAnswer => '最佳回复';

  @override
  String get goToBestAnswer => '查看最佳回复';

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

  @override
  String get bold => '粗体';

  @override
  String get underline => '下划线';

  @override
  String get strikethrough => '删除线';

  @override
  String get bulletList => '项目符号列表';

  @override
  String get numberedList => '编号列表';

  @override
  String get listItem => '列表项';

  @override
  String get mentionUser => '提及用户、用户组或帖子';

  @override
  String get title => '标题';

  @override
  String get content => '内容';

  @override
  String get send => '发送私信';

  @override
  String get postReply => '回复';

  @override
  String get postDiscussion => '发布';

  @override
  String get postPrivateDiscussion => '发起私密讨论';

  @override
  String get save => '保存';

  @override
  String get formatting => '格式';

  @override
  String get pleaseEnterTitle => '请输入标题';

  @override
  String get pleaseEnterContent => '请输入内容';

  @override
  String get composerTitleHint => '标题';

  @override
  String get privateDiscussionTitleHint => '标题';

  @override
  String get composerContentHint => '说点什么吧...';

  @override
  String get composerReplyHint => '说点什么吧...';

  @override
  String get composerFormattingHint => '打开格式选项';

  @override
  String get searchUsers => '搜索用户...';

  @override
  String get startDiscussion => '发起讨论';

  @override
  String get editPost => '编辑帖子';

  @override
  String get postingThrottled => '操作过于频繁，请稍后再试。';

  @override
  String get postAwaitingApproval => '已发送。管理员审核通过后才会显示。';

  @override
  String get chooseTags => '选择标签';

  @override
  String get ok => '确定';

  @override
  String get primaryTags => '主标签';

  @override
  String get secondaryTags => '更多标签';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '请选择 $count 个主标签。',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最多选择 $count 个主标签。',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '请再选择 $count 个标签。',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '最多再选择 $count 个标签。',
    );
    return '$_temp0';
  }

  @override
  String get noMembersFound => '未找到符合搜索条件的用户。';

  @override
  String get memberSearchNotAllowed => '此论坛不允许搜索成员。';

  @override
  String get editLoadFailed => '无法加载此帖子进行编辑。';

  @override
  String get like => '赞';

  @override
  String get unlike => '取消赞';

  @override
  String likedByOne(String a) {
    return '$a 觉得很赞。';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$a 和 $b 觉得很赞。';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others 人',
    );
    return '$a 和另外 $_temp0觉得很赞。';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others 人',
    );
    return '$a、$b 和另外 $_temp0觉得很赞。';
  }

  @override
  String get likedByYou => '你觉得很赞。';

  @override
  String likedByYouAndOne(String a) {
    return '你和 $a 觉得很赞。';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others 人',
    );
    return '你、$a 和另外 $_temp0觉得很赞。';
  }

  @override
  String get react => '回应';

  @override
  String get reactions => '回应';

  @override
  String get bookmark => '收藏';

  @override
  String get removeBookmark => '取消收藏';

  @override
  String get bookmarks => '收藏';

  @override
  String get noBookmarks => '还没有收藏。';

  @override
  String get chooseBestAnswer => '设为最佳回复';

  @override
  String get removeBestAnswer => '取消最佳回复';

  @override
  String get notFollowing => '不关注';

  @override
  String get notFollowingHint => '仅在被 @提及时通知。';

  @override
  String get followingHint => '所有回复都通知。';

  @override
  String get ignoring => '忽略';

  @override
  String get ignoringHint => '不接收任何通知，并从讨论列表中隐藏。';

  @override
  String get tagFollowingHint => '有新讨论时通知我。';

  @override
  String get lurking => '潜水';

  @override
  String get lurkingHint => '有新讨论或新回复时都通知我。';

  @override
  String get tagIgnoringHint => '永不通知。';

  @override
  String get hidden => '隐藏';

  @override
  String get hiddenHint => '在“全部讨论”中隐藏此标签下的讨论。';

  @override
  String get attachFile => '附加文件';

  @override
  String get uploadImage => '上传图片';

  @override
  String get takePhoto => '拍照';

  @override
  String uploadingFilename(String filename) {
    return '正在上传：$filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return '文件上传失败：$errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading => '请等待附件上传完成';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName 已缩小至 $size$dimensions，以符合 $limit 的上限。';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName：文件过大（$size），且无法缩小。上限为 $limit。';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName 大小为 $fileBytes。文件大小不能超过 $maxBytes。';
  }

  @override
  String get flagAction => '举报';

  @override
  String get ignoredUsers => '已屏蔽用户';

  @override
  String get ignoredUsersEmpty => '你还没有屏蔽任何人。';

  @override
  String get flagPostTitle => '举报帖子';

  @override
  String get flagReasonOffTopic => '离题';

  @override
  String get flagReasonOffTopicText => '此帖子与当前讨论无关，应移到别处。';

  @override
  String get flagReasonInappropriate => '不当内容';

  @override
  String get flagReasonInappropriateText => '此帖包含冒犯、辱骂内容，或违反了社区准则。';

  @override
  String get flagReasonSpam => '垃圾信息';

  @override
  String get flagReasonSpamText => '此帖子是广告。';

  @override
  String get flagReasonOther => '其他（请说明）';

  @override
  String get flagDetails => '补充说明（可选）';

  @override
  String get flagDetailsNeeded => '请向版主提供一些详细信息。';

  @override
  String get communityGuidelines => '社区准则';

  @override
  String get flagSent => '感谢你的举报，版主会尽快处理。';

  @override
  String ignoreUser(String name) {
    return '屏蔽 $name';
  }

  @override
  String stopIgnoringUser(String name) {
    return '取消屏蔽 $name';
  }

  @override
  String ignoreUserConfirm(String name) {
    return '确定要屏蔽 $name 吗？';
  }

  @override
  String ignoredUserPost(String name) {
    return '你已屏蔽的 $name 的帖子。';
  }

  @override
  String get showPost => '显示帖子';

  @override
  String get ignoredOnThisPhone => '此论坛没有屏蔽列表，因此应用会将你的列表保存在此手机上。';

  @override
  String get stopIgnoring => '取消屏蔽';

  @override
  String get termsBanner => '在你查看并接受新条款前，我们暂时限制了你的账号访问。';

  @override
  String get termsReview => '查看';

  @override
  String get termsTitle => '服务条款更新';

  @override
  String get termsIntro => '自你上次访问后，条款已有更新';

  @override
  String get readPolicy => '阅读';

  @override
  String get acceptTerms => '确认';

  @override
  String get termsAccepted => '感谢接受新条款，现在可以继续使用论坛';

  @override
  String get privateDiscussions => '私密讨论';

  @override
  String get startPrivateDiscussion => '发起私密讨论';

  @override
  String privateWith(String names) {
    return '与 $names';
  }

  @override
  String get addPerson => '参与者';

  @override
  String get choosePerson => '此讨论仅所选用户可见。除自己外，至少需要添加 1 个参与者。';

  @override
  String get noPrivateDiscussions => '这里空空如也……';

  @override
  String get privateOnlyOne => '此论坛一次只允许你私下写给一个人。';

  @override
  String get messages => '私信';

  @override
  String get newMessage => '发送私信';

  @override
  String get noMessages => '还没有私信，开始对话吧';

  @override
  String get sendMessage => '发送私信';

  @override
  String get messageHint => '写一条私信…';

  @override
  String get messagesLoadFailed => '无法加载私信。';

  @override
  String get moderate => '管理';

  @override
  String get renameDiscussion => '重命名';

  @override
  String get renameDiscussionTitle => '更改讨论标题';

  @override
  String get lockDiscussion => '锁定';

  @override
  String get unlockDiscussion => '解锁';

  @override
  String get stickDiscussion => '置顶';

  @override
  String get unstickDiscussion => '取消置顶';

  @override
  String get restore => '恢复';

  @override
  String get deleteForever => '永久删除';

  @override
  String get deleteForeverConfirm => '确定要永久删除吗？此操作不可撤销。';

  @override
  String get approve => '批准';

  @override
  String get unsuspend => '解除封禁';

  @override
  String suspendedUntil(String date) {
    return '封禁至 $date';
  }

  @override
  String get suspendedIndefinitely => '永久封禁';

  @override
  String youAreSuspended(String date) {
    return '此账号将被封禁至 $date';
  }

  @override
  String get youAreSuspendedIndefinitely => '此账号已被封禁';

  @override
  String get awaitingApproval => '等待审核';

  @override
  String get badgeSticky => '置顶';

  @override
  String get badgeLocked => '锁定';

  @override
  String get badgeHidden => '隐藏';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个帖子',
    );
    return '$user 将 $titles 中的$_temp0合并到了此讨论。';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个帖子',
    );
    return '$user 将$_temp0拆分到了 $title。';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个帖子',
    );
    return '$user 从 $title 拆分出了$_temp0。';
  }

  @override
  String get errorNoConnection => '网络连接异常，请检查网络后重试。';

  @override
  String get errorTimedOut => '论坛响应超时，请重试。';

  @override
  String get errorBlocked => '论坛的防火墙拦截了本应用。请稍后重试，或在浏览器中打开论坛。';

  @override
  String get errorNotFound => '你请求的资源不存在。';

  @override
  String get errorRateLimited => '操作过于频繁，请稍后再试。';

  @override
  String get errorForumDown => '论坛暂时没有响应，请稍后再试。';

  @override
  String get errorNotAllowed => '你没有权限执行此操作。';

  @override
  String get errorUnknown => '糟糕，出错啦！请重试。';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共 $count 票',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '本次投票最多可选 $count 项。',
    );
    return '$_temp0';
  }

  @override
  String get pollEnded => '投票已结束';

  @override
  String pollEndsOn(String date) {
    return '投票将于 $date 结束。';
  }

  @override
  String get pollResultsAfterVoting => '投票后即可查看结果。';

  @override
  String get pollResultsWhenClosed => '投票结束后即可查看结果。';

  @override
  String get pollVote => '投票';

  @override
  String get pollRemoveVote => '撤回我的投票';

  @override
  String get pollSeeVoters => '查看投票用户';

  @override
  String get pollNoVotes => '暂无投票';

  @override
  String get poll => '投票';

  @override
  String get pollNeedsQuestion => '请填写投票问题';

  @override
  String get pollNeedsAnswers => '至少需要添加 2 个选项';

  @override
  String get pollEndInPast => '请选择未来的结束时间。';

  @override
  String get pollQuestion => '问题';

  @override
  String pollAnswer(int number) {
    return '选项 $number';
  }

  @override
  String get pollRemoveAnswer => '删除选项';

  @override
  String get pollAddAnswer => '添加选项';

  @override
  String get pollMultipleChoice => '允许多选';

  @override
  String get pollChoicesAllowed => '每人最多可选';

  @override
  String get pollAnyNumber => '不限';

  @override
  String get pollPublic => '允许查看投票用户';

  @override
  String get pollAllowChangeVote => '允许用户修改投票';

  @override
  String get pollCloses => '投票截止时间（可选）';

  @override
  String get pollNeverCloses => '从不';

  @override
  String get pollHideVotes => '投票结束前隐藏票数';

  @override
  String get pollHideVotesNeedsEnd => '请先选择投票结束时间。';

  @override
  String get addPoll => '添加投票';

  @override
  String get submit => '提交';

  @override
  String get editPoll => '编辑投票';

  @override
  String get removePoll => '删除投票';

  @override
  String get draftSaved => '保存成功！';

  @override
  String get draftSavedWithoutPoll => '草稿已保存，但不含投票：草稿无法保存投票。';

  @override
  String get draftNeedsText => '请先写点内容再保存草稿。';

  @override
  String get drafts => '草稿';

  @override
  String get draftsLoadFailed => '无法加载你的草稿';

  @override
  String get noDrafts => '暂无保存的草稿。关闭正在写的帖子时选择“保存草稿”，即可保存在这里。';

  @override
  String draftReplyTo(String title) {
    return '回复“$title”';
  }

  @override
  String get draftUntitled => '无标题讨论';

  @override
  String get deleteDraftQuestion => '确定要删除此草稿吗？';

  @override
  String get deleteDraft => '删除草稿';
}
