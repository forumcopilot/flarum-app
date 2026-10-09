import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
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
