import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forum_kit/views/widgets/code_block.dart';
import 'package:forum_kit/views/widgets/post_content_callbacks.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

/// Posts recorded from the 1.8 and 2.0 test forums
/// (tool/test_forums/formatting_samples.php), rendered as the thread will.
final _samples = jsonDecode(File('test/fixtures/render_samples.json').readAsStringSync()) as Map<String, dynamic>;

SiteContext _site(String baseUrl) => SiteContext(
      siteType: FlarumProxyFactory.siteType,
      site: Site(
        id: null,
        name: 'Test forum',
        url: baseUrl,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: baseUrl,
        siteType: FlarumProxyFactory.siteType,
        language: null,
      ),
    );

class _Taps {
  final urls = <String>[];
  final images = <String>[];
  final users = <String>[];

  PostContentCallbacks get callbacks => PostContentCallbacks(
        onUrlTap: urls.add,
        onImageTap: (url, _, __) => images.add(url),
        onMentionTap: users.add,
      );
}

void main() {
  setUp(FlarumForum.resetForTesting);

  group('fof/upload\'s download permission', () {
    test('comes from the forum (fof-upload.canDownload)', () async {
      final forum = FixtureForum(FlarumVersion.v2, root: '../flarum_core/test/fixtures').forum();
      expect(ForumMediaAuth.of(_site(FixtureForum.baseUrl)).mayDownloadFiles, isTrue,
          reason: 'until the forum is read, it decides');
      await forum.refresh();
      expect(ForumMediaAuth.of(_site(FixtureForum.baseUrl)).mayDownloadFiles, isFalse,
          reason: 'members of the test forums may not download');
    });

    testWidgets('without it a file card says so instead of offering a download', (tester) async {
      const auth = ForumMediaAuth(
          siteUrl: 'https://forum.test', credentials: {'Authorization': 'Token t'}, mayDownloadFiles: false);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Column(children: [
            AttachmentFileCard(name: 'notes.txt', url: 'https://forum.test/api/fof/download/abc', auth: auth),
            AttachmentFileCard(name: 'elsewhere.pdf', url: 'https://example.com/elsewhere.pdf', auth: auth),
          ]),
        ),
      ));
      expect(find.text('Permission required'), findsOneWidget, reason: "only the forum's own downloads are guarded");
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });
  });

  testWidgets('a tag mention (flarum/tags 2.0) is a pill in the tag\'s colour that opens the tag', (tester) async {
    final taps = _Taps();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: FlarumContent(
          siteContext: _site('https://forum.test'),
          callbacks: taps.callbacks,
          content: '<p>See <a href="https://forum.test/t/general" data-id="1" class="TagMention TagMention--colored" '
              'style="--color:#FF914D"><span class="TagMention-text"><i class="icon fas fa-home"></i> General</span></a>.</p>',
        ),
      ),
    ));
    await tester.pump();
    final pill = find.ancestor(of: find.text('General'), matching: find.byType(Container)).first;
    expect((tester.widget<Container>(pill).decoration! as BoxDecoration).color, const Color(0xFFFF914D));
    expect(find.byIcon(Icons.home_outlined), findsOneWidget, reason: "the tag's Font Awesome icon (fa-home)");
    await tester.tap(find.text('General'));
    expect(taps.urls, ['https://forum.test/t/general']);
  });

  // Markup recorded from discuss.flarum.org (Flarum 2.0), as docs/thread-rendering-review.md found it.
  group('as the web draws them', () {
    Future<_Taps> pump(WidgetTester tester, String content) async {
      final taps = _Taps();
      tester.view.physicalSize = const Size(412, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          // Prepared as the thread prepares every post.
          body: FlarumContent(
            siteContext: _site('https://discuss.flarum.org'),
            callbacks: taps.callbacks,
            content: FlarumHtml.parse(content, forumBaseUrl: 'https://discuss.flarum.org').html,
          ),
        ),
      ));
      await tester.pump();
      return taps;
    }

    testWidgets('inline code is text in the sentence, so it wraps with it', (tester) async {
      await pump(
          tester,
          '<p>Deck gives the message <code>Use filters only, such as tag:support is:unread. Plain words '
          "aren't supported.</code> and won't add it.</p>");
      // A chip (a WidgetSpan) was a Text of its own, which couldn't break; as text, the code is part
      // of the paragraph's own text.
      expect(find.textContaining(RegExp(r"message\W+Use filters only.*supported\.\W+and won't", dotAll: true), findRichText: true),
          findsOneWidget);
    });

    testWidgets('a GitHub link is a pill: the mark, the repository, and its number after an icon', (tester) async {
      final taps = await pump(
          tester,
          '<p>in <a class="Github-embed github-pr-link" target="_blank" rel="ugc noopener noreferrer" '
          'href="https://github.com/FriendsOfFlarum/anti-spam/pull/4"><i class="fab fa-github" aria-hidden="true"></i>'
          '<span class="github-repo-name">FriendsOfFlarum/anti-spam</span><i class="fas fa-code-branch" aria-hidden="true">'
          '</i><span class="github-pr-link--number">4</span></a></p>');
      expect(find.text('FriendsOfFlarum/anti-spam'), findsOneWidget, reason: 'not run into the number ("anti-spam4")');
      expect(find.text('4'), findsOneWidget);
      expect(find.byIcon(Icons.call_split), findsOneWidget, reason: 'the pull request icon (fa-code-branch)');
      await tester.tap(find.text('FriendsOfFlarum/anti-spam'));
      expect(taps.urls, ['https://github.com/FriendsOfFlarum/anti-spam/pull/4']);
    });

    testWidgets('a link to a post is a pill: the favicon small, the discussion, then the post', (tester) async {
      final taps = await pump(
          tester,
          '<p>Found this, helpful: <a href="https://discuss.flarum.org/d/4011-x/13" rel="ugc" target="_self" '
          'class="UrlLink UrlLink--internal UrlLink--discussion"><img src="https://discuss.flarum.org/assets/favicon.png" '
          'class="UrlLink-favicon" alt="" aria-hidden="true"><span class="UrlLink-discussion">#4011</span>'
          '<span class="UrlLink-post"><i class="icon fas fa-comment UrlLink-postIcon" aria-hidden="true"></i>13</span></a></p>');
      expect(find.text('#4011'), findsOneWidget, reason: 'not run into the post number ("#401113")');
      expect(find.text('13'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      final favicon = tester.getSize(find.byType(Image));
      expect(favicon.height, lessThan(20), reason: 'the favicon at text size, not a full-size picture');
      await tester.tap(find.text('#4011'));
      expect(taps.urls, ['https://discuss.flarum.org/d/4011-x/13']);
    });

    test('badges come from shields.io as PNG, sit in the line and stay out of the picture viewer', () {
      expect(FlarumHtml.rasterBadge('https://img.shields.io/badge/license-MIT-blue.svg'),
          'https://raster.shields.io/badge/license-MIT-blue.png');
      expect(FlarumHtml.rasterBadge('https://img.shields.io/packagist/v/fof/photoswipe'),
          'https://raster.shields.io/packagist/v/fof/photoswipe.png', reason: 'no extension: SVG, by default');
      expect(FlarumHtml.rasterBadge('http://poser.pugx.org/fof/upload/downloads'),
          'https://raster.shields.io/packagist/dt/fof/upload.png', reason: "poser's badge, as shields.io draws it");
      expect(FlarumHtml.rasterBadge('https://poser.pugx.org/fof/upload/something-else'), isNull);
      expect(FlarumHtml.rasterBadge('https://example.com/logo.svg'), isNull);

      final prepared = FlarumHtml.parse(
          '<p><a href="https://packagist.org/packages/fof/photoswipe"><img src="https://img.shields.io/packagist/v/fof/photoswipe" '
          'alt="Latest Stable Version"></a> <img src="https://weblate.rob006.net/widgets/flarum/-/svg-badge.svg" alt="Translation"> '
          '<img src="https://example.com/screenshot.png" alt="Screenshot"></p>',
          forumBaseUrl: 'https://discuss.flarum.org');
      expect(RegExp(r'class="badge"').allMatches(prepared.html), hasLength(2), reason: 'shields.io and Weblate');
      expect(prepared.imageUrls, ['https://example.com/screenshot.png']);
    });

    test("fof/upload's text-file preview is the file's card and its first lines", () {
      final prepared = FlarumHtml.parse(
          '<figure class="FofUpload-TextPreview" data-hassnippet="true"><figcaption class="FofUpload-TextPreviewTitle">'
          '<i class="icon far fa-file"></i> <span class="FofUpload-TextPreviewLabel">flarum.log</span></figcaption>'
          '<div class="FofUpload-TextPreviewSnippet"><pre><code>[2026-07-31] flarum.ERROR: one</code></pre></div>'
          '<div class="FofUpload-TextPreviewFull"></div><button type="button" class="Button FofUpload-TextPreviewToggle">'
          '<span class="Button-label">Expand preview</span></button><a href="https://cdn.example.com/flarum.log" '
          'class="Button hasIcon FofUpload-TextPreviewDownload"><span class="Button-label">Download file</span></a>'
          '<div class="FofUpload-TextPreviewError"><p>Error previewing file.</p></div></figure>',
          forumBaseUrl: 'https://discuss.flarum.org');
      expect(prepared.html, contains('<a class="attachment" href="https://cdn.example.com/flarum.log">flarum.log</a>'));
      expect(prepared.html, contains('<pre><code>[2026-07-31] flarum.ERROR: one</code></pre>'));
      expect(prepared.html, isNot(contains('Error previewing')), reason: "the web's scripts hide it");
      expect(prepared.html, isNot(contains('Expand preview')));
    });

    testWidgets('a badge in a link opens the link', (tester) async {
      final taps = await pump(
          tester,
          '<p><a href="https://packagist.org/packages/fof/photoswipe"><img src="https://img.shields.io/packagist/v/fof/photoswipe" '
          'alt="Latest Stable Version"></a></p>');
      // It doesn't load in a test: what shows is its alt text, in the line.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.tap(find.text('Latest Stable Version'));
      expect(taps.urls, ['https://packagist.org/packages/fof/photoswipe']);
      expect(taps.images, isEmpty);
    });

    testWidgets("a picture that doesn't load says what it was, in a small box", (tester) async {
      await pump(tester, '<p><img src="https://example.com/missing.png" title="" alt="Bespoke"></p>');
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('Bespoke'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(tester.getSize(find.ancestor(of: find.text('Bespoke'), matching: find.byType(Container)).first).width,
          lessThan(200), reason: 'not the whole width');
    });

    testWidgets('a mention of someone deleted is a muted pill that goes nowhere', (tester) async {
      final taps = await pump(
          tester, '<p>Message disappeared as <span class="UserMention UserMention--deleted">@[deleted]</span> said.</p>');
      final pill = find.text('@[deleted]');
      expect(pill, findsOneWidget, reason: 'a pill of its own');
      expect(tester.widget<Text>(pill).style?.color, AppTheme.lightTheme.colorScheme.onSurfaceVariant);
      await tester.tap(pill);
      expect(taps.urls, isEmpty);
      expect(taps.users, isEmpty);
    });
  });

  group('a post\'s direction', () {
    test('comes from most of its letters, markup aside', () {
      expect(FlarumContent.directionOf('<p>مرحبا بكم في <a href="https://forum.test/d/1-hello">Flarum</a></p>'),
          TextDirection.rtl);
      expect(FlarumContent.directionOf('<p>שלום עולם, hello</p>'), TextDirection.rtl);
      expect(FlarumContent.directionOf('<p class="UserMention">Hello <b>world</b>, مرحبا</p>'), TextDirection.ltr);
      expect(FlarumContent.directionOf('<p>🎉 123 &amp; 456</p>'), isNull);
    });

    testWidgets('an Arabic post is laid out right to left, its code left to right', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: FlarumContent(
            siteContext: _site('https://forum.test'),
            content: '<p>مرحبا بكم</p><ul><li>عنصر أول</li></ul><pre><code>final x = 1;</code></pre>',
          ),
        ),
      ));
      await tester.pump();
      expect(Directionality.of(tester.element(find.byType(Html))), TextDirection.rtl);
      expect(Directionality.of(tester.element(find.byType(CodeBlock))), TextDirection.ltr);
    });

    testWidgets('an English post keeps the app\'s direction', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: FlarumContent(siteContext: _site('https://forum.test'), content: '<p>Hello, مرحبا</p>'),
        ),
      ));
      await tester.pump();
      expect(find.descendant(of: find.byType(FlarumContent), matching: find.byType(Directionality)), findsNothing);
    });
  });

  for (final version in ['v1', 'v2']) {
    final forum = _samples[version] as Map<String, dynamic>;
    final baseUrl = forum['baseUrl'] as String;
    final samples = (forum['samples'] as Map<String, dynamic>).cast<String, String>();

    Future<(_Taps, FlarumHtml)> render(WidgetTester tester, String name) async {
      final taps = _Taps();
      final prepared = FlarumHtml.parse(samples[name]!, forumBaseUrl: baseUrl);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: FlarumContent(siteContext: _site(baseUrl), content: prepared.html, callbacks: taps.callbacks),
          ),
        ),
      ));
      await tester.pump();
      return (taps, prepared);
    }

    group('Flarum $version:', () {
      for (final name in samples.keys) {
        testWidgets('$name renders without errors', (tester) async {
          await render(tester, name);
          final error = tester.takeException();
          // Widget tests can't load network pictures; that isn't a rendering fault.
          if (error != null && !'$error'.contains('HTTP request failed')) fail('$error');
        });
      }

      testWidgets('code blocks show the code, not the highlighter\'s loader', (tester) async {
        await render(tester, 'code');
        expect(find.byType(CodeBlock), findsWidgets);
        expect(find.textContaining('jsdelivr', findRichText: true), findsNothing);
        expect(find.textContaining('hljs', findRichText: true), findsNothing);
        expect(FlarumHtml.parse(samples['code']!, forumBaseUrl: baseUrl).html, isNot(contains('<script')));
      });

      testWidgets('a user mention opens the user', (tester) async {
        final (taps, _) = await render(tester, 'mentions');
        await tester.tap(find.text('@bob'));
        expect(taps.users, ['bob']);
      });

      testWidgets('a post mention has a reply glyph and opens the post', (tester) async {
        final (taps, _) = await render(tester, 'quote_reply');
        expect(find.byIcon(Icons.reply), findsOneWidget);
        await tester.tap(find.text('alice'));
        expect(taps.urls.single, matches(RegExp(r'/d/\d+-welcome-to-the-test-forum/2$')));
      });

      testWidgets('task lists show their boxes, checked or not', (tester) async {
        await render(tester, 'tables_tasks');
        expect(find.byIcon(Icons.check_box), findsWidgets);
        expect(find.byIcon(Icons.check_box_outline_blank), findsWidgets);
      });

      testWidgets('a file is a card that downloads it through the API', (tester) async {
        final (_, prepared) = await render(tester, 'attachment');
        final card = tester.widget<AttachmentFileCard>(find.byType(AttachmentFileCard));
        expect(card.name, 'notes.txt');
        expect(card.size, '25B');
        expect(card.url, matches(RegExp('^${RegExp.escape(baseUrl)}/api/fof/download/[0-9a-f-]{36}\$')));
        expect(prepared.html, isNot(contains('ButtonGroup')));
      });

      testWidgets('a block spoiler is labelled, an inline one blurred', (tester) async {
        await render(tester, 'spoilers');
        expect(find.text('Spoiler'), findsOneWidget);
        expect(find.byType(SpoilerBox), findsOneWidget);
      });

      testWidgets('a YouTube embed is a preview card, a video a player card', (tester) async {
        await render(tester, 'media');
        expect(find.byType(EmbedPreviewCard), findsOneWidget);
        expect(find.byType(PostVideoCard), findsOneWidget);
      });
    });
  }

  testWidgets('a 2.0 upload preview opens the full size, not the thumbnail', (tester) async {
    final forum = _samples['v2'] as Map<String, dynamic>;
    final baseUrl = forum['baseUrl'] as String;
    final prepared = FlarumHtml.parse((forum['samples'] as Map)['uploads'] as String, forumBaseUrl: baseUrl);
    expect(prepared.imageUrls.single, endsWith('-green.png'));

    final taps = _Taps();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: FlarumContent(siteContext: _site(baseUrl), content: prepared.html, callbacks: taps.callbacks),
      ),
    ));
    await tester.tap(find.byType(Image).first);
    expect(taps.images.single, endsWith('-green.png'));
    tester.takeException();
  });
}
