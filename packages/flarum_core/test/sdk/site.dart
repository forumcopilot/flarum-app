import 'package:flarum_core/flarum_core.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

import 'package:flarum_core/testing.dart';

/// A SiteContext for the fixture forum at [FixtureForum.baseUrl].
SiteContext testSite() => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: Site(
        id: null,
        name: 'Test forum',
        url: FixtureForum.baseUrl,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: FixtureForum.baseUrl,
        siteType: FlarumProxyFactory.siteType,
        language: null,
      ),
    );

