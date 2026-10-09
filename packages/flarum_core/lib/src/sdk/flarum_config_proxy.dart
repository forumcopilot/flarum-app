import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_config_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_config_result.dart';

import '../attributes.dart';
import '../models/forum_info.dart';
import 'flarum_forum.dart';

/// The forum's capabilities, from one `GET /api`.
///
/// Flags for what Flarum has in core are constants; flags that depend on an
/// extension follow what the forum's attributes reveal ([FlarumExtensions]);
/// the rest reflect the reader's own `can*` permissions. Method-by-method
/// support is in docs/sdk-coverage.md.
class FlarumConfigProxy implements IFCConfigProxy {
  FlarumConfigProxy(this.siteContext);

  final SiteContext siteContext;

  @override
  Future<FCConfigResult> getConfig(String url, {bool forceRefresh = false}) async {
    final forum = FlarumForum.of(siteContext);
    final info = forceRefresh ? await forum.refresh() : await forum.current();
    return buildResult(info, forum);
  }

  static FCConfigResult buildResult(FlarumForumInfo info, FlarumForum forum) {
    final ext = forum.extensions;
    final a = info.attributes;
    bool can(String key) => a.boolean(key) ?? false;
    final major = info.version == FlarumVersion.v2 ? '2' : '1';
    final privateMessages = ext.byobu || ext.messages;

    return FCConfigResult(
      jsonSupport: true,
      // Flarum doesn't tell members its exact version; the major is detected.
      systemVersion: major,
      version: major,
      // Client-side protocol markers, as in discourse_core.
      hookVersion: '1.0',
      apiLevel: '4',
      releaseTimestamp: '',
      pushSlug: 'flarum',
      smartBannerInfo: '',
      setForumInfo: true,
      // GET /api answered, so the forum is up (maintenance mode answers 503).
      isOpen: true,
      guestOkay: can('canViewForum') || info.actor != null,
      reportPost: ext.flags,
      reportPm: ext.flags && ext.byobu,
      gotoPost: true,
      gotoUnread: true,
      // One request per discussion; there's no id filter on lists.
      getTopicByIds: true,
      // markedAllAsReadAt covers the whole forum only.
      markRead: true,
      markForum: false,
      subscribeForum: ext.followTags,
      disableSubscribeForum: !ext.followTags,
      disableSearch: false,
      getLatestTopic: true,
      getNewTopic: true,
      getIdByUrl: true,
      getUrlById: true,
      deleteReason: false,
      modApprove: true,
      modDelete: true,
      modReport: ext.flags,
      guestSearch: true,
      anonymous: false,
      // Seeing who's online needs viewLastSeenAt, which members lack by default.
      guestWhosOnline: false,
      searchId: false,
      avatar: true,
      // No XenForo-style inbox and sent boxes: private messages are conversations.
      pmLoad: false,
      subscribeLoad: true,
      // flarum/subscriptions: follow, normal or ignore, like Discourse's levels
      // without "tracking"; fof/follow-tags adds lurk for tags.
      subscribeTopicMode: 'level',
      subscribeForumMode: ext.followTags ? 'level' : '',
      // MySQL's default full-text minimum word length.
      minSearchLength: 3,
      inboxStat: privateMessages,
      // Quotes are built in the app (`> @"Name"#p123`), any number of them.
      multiQuote: true,
      defaultSmilies: false,
      canUnread: true,
      // Forum-wide stickies are the nearest thing to announcements.
      announcement: true,
      emoji: true,
      supportMd5: false,
      supportSha1: false,
      passwordType: 'bcrypt',
      conversation: privateMessages,
      getForum: ext.tags,
      getTopicStatus: true,
      // Approximated by followed tags, as discourse_core does with categories.
      getParticipatedForum: ext.followTags,
      getForumStatus: ext.tags,
      getSmilies: false,
      advancedHtml: false,
      idToUrlRedirect: true,
      updateProfile: ext.nicknames,
      getMemberList: can('canSearchUsers'),
      mGetInactiveUsers: false,
      mApproveUser: false,
      pollOptionsMaxCount: ext.polls,
      advancedOnlineUsers: false,
      // Read state only moves forward.
      markPmUnread: false,
      markPmRead: privateMessages,
      advancedSearch: true,
      massSubscribe: false,
      userId: info.actor?.id ?? '',
      // Sign-up is a modal on the forum's own page.
      regUrl: (a.boolean('allowSignUp') ?? false) ? forum.baseUrl : '',
      guestGroupId: '2',
      phpVersion: '',
      adsDisabledGroup: '',
      markTopicRead: true,
      advancedDelete: true,
      firstUnread: true,
      alert: true,
      getActivity: true,
      searchUser: can('canSearchUsers'),
      userRecommended: false,
      // fof/ignore-users shows itself on users, not the forum; per-user canBeIgnored decides.
      ignoreUser: true,
      getIgnoredUsers: true,
      unban: ext.suspend,
      banExpires: ext.suspend,
      advancedMerge: false,
      advancedMove: ext.tags,
      advancedEdit: true,
      twoStep: false,
      searchStartedBy: true,
      bannerControl: false,
      allowTrending: false,
      pushType: 'fcm',
      // Push runs through our own server polling the forum (plan §7), not the forum.
      push: 'enabled',
      disableHtml: false,
      contentEncoding: 'gzip',
      contentType: 'application/vnd.api+json',
      signIn: true,
      setApiKey: false,
      loginWithEmail: true,
      syncUser: false,
      getContact: false,
      userSubscription: true,
      pushContentCheck: false,
      apiKey: '',
      mbqFrameVersion: '1.0',
      forumType: 'flarum',
    );
  }
}
