import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/interfaces/interfaces.dart';

import 'flarum_config_proxy.dart';
import 'flarum_forum_proxy.dart';
import 'flarum_post_proxy.dart';
import 'flarum_social_proxy.dart';
import 'flarum_topic_proxy.dart';
import 'flarum_user_proxy.dart';

/// Flarum's implementations of the SDK proxies, registered under [siteType].
///
/// Proxies arrive through Phase 2 one interface at a time; until an interface
/// has one, asking for it fails loudly rather than pretending.
class FlarumProxyFactory extends SiteProxyFactory {
  static const siteType = 'flarum';

  /// Registers Flarum with the SDK. Call once at startup.
  static void register() => SiteProxyFactory.register(siteType, FlarumProxyFactory());

  @override
  IFCConfigProxy createConfigProxy(SiteContext context) => FlarumConfigProxy(context);

  @override
  IFCAccountProxy createAccountProxy(SiteContext context) => _notYet('account');
  @override
  IFCUserProxy createUserProxy(SiteContext context) => FlarumUserProxy(context);
  @override
  IFCForumProxy createForumProxy(SiteContext context) => FlarumForumProxy(context);
  @override
  IFCTopicProxy createTopicProxy(SiteContext context) => FlarumTopicProxy(context);
  @override
  IFCPostProxy createPostProxy(SiteContext context) => FlarumPostProxy(context);
  @override
  IFCSubscriptionProxy createSubscriptionProxy(SiteContext context) => _notYet('subscription');
  @override
  IFCModerationProxy createModerationProxy(SiteContext context) => _notYet('moderation');
  @override
  IFCSearchProxy createSearchProxy(SiteContext context) => _notYet('search');
  @override
  IFCSocialProxy createSocialProxy(SiteContext context) => FlarumSocialProxy(context);
  @override
  IFCPrivateConversationProxy createPrivateConversationProxy(SiteContext context) => _notYet('private conversation');
  @override
  IFCPrivateMessageProxy createPrivateMessageProxy(SiteContext context) => _notYet('private message');
  @override
  IFCAttachmentProxy createAttachmentProxy(SiteContext context) => _notYet('attachment');

  static Never _notYet(String proxy) => throw UnimplementedError('Flarum $proxy proxy is not implemented yet');
}
