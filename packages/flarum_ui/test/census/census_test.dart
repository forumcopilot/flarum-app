// Reads real Flarum forums from the plan's census (data/flarum-census-2026-10-08.json), as a
// guest and read-only, and renders their posts with the app's renderer: the server-side half of
// Phase 2's exit check (browse 20 census forums on both versions and several languages). A few
// GET requests per forum, with the app's User-Agent. Skipped by default; it needs the network:
//
//   flutter test --run-skipped -t census test/census/census_test.dart
//
// Writes build/census_report.txt. Fails on what the app should handle: a forum that answers
// but whose data doesn't parse, or a post the renderer can't draw. A forum that doesn't answer
// (down, blocking, Cloudflare) is reported, not failed.
@Tags(['census'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// 20 active, guest-readable forums from the census (12 on 1.x, 8 on 2.0; English, French,
/// German, Spanish, Dutch, Turkish, Ukrainian, Russian, Arabic, Chinese, Thai, Italian,
/// Japanese; two in a subfolder), and the template's default forum.
const _forums = [
  'https://mondedie.fr',
  'https://forum.osticket.com',
  'https://community.swisscom.ch',
  'https://flarum.es',
  'https://www.linuxmint.com.ua',
  'https://foro.arsoporte.com',
  'https://bbs.liht.cc',
  'https://yazilimtoplulugu.com',
  'https://forum.acteurs-gezocht.nl',
  'https://mazdaminitruckin.com/forums',
  'https://lepointdarret.com/public',
  'https://forum.kaosx.us',
  'https://flarum2.huseyinfiliz.com',
  'https://discuss.flarum.org.cn',
  'https://forum-einsamkeit.org',
  'https://questpost.ru',
  'https://ngbc.kku.ac.th',
  'https://community.peopleinside.it',
  'https://f.ani-nya.com',
  'https://www.flarumde.com',
  'https://discuss.flarum.org',
];

class _Visit {
  _Visit(this.url);

  final String url;
  FlarumForumInfo? info;
  int discussions = 0;
  int tags = 0;
  FlarumDiscussion? thread;
  List<FlarumPost> posts = const [];
  Object? unreachable;
  Object? parseError;
  final renderErrors = <String>[];
}

void main() {
  final visits = [for (final url in _forums) _Visit(url)];

  setUpAll(() async {
    HttpOverrides.global = null;
    for (final visit in visits) {
      final forum = FlarumForum.forUrl(visit.url);
      try {
        visit.info = await forum.refresh().timeout(const Duration(seconds: 30));
      } catch (e) {
        visit.unreachable = e;
        continue;
      }
      try {
        final page = await forum.api.discussions(limit: 10).timeout(const Duration(seconds: 30));
        visit.discussions = page.items.length;
        visit.tags = (await forum.api.tags().timeout(const Duration(seconds: 30))).length;
        final candidates = page.items.where((d) => !d.isSticky && d.commentCount > 1);
        final pick = candidates.isNotEmpty ? candidates.first : page.items.firstOrNull;
        if (pick != null) {
          visit.thread = await forum.api.discussion(pick.id, withPostIds: true).timeout(const Duration(seconds: 30));
          visit.posts = (await forum.api.posts(pick.id, limit: 20).timeout(const Duration(seconds: 30))).items;
        }
      } on TimeoutException catch (e) {
        visit.unreachable = e;
      } on FlarumApiException catch (e) {
        // A refusal (permissions, rate limits) is the forum's answer, not a parsing fault.
        visit.unreachable = e;
      } catch (e, stack) {
        visit.parseError = '$e\n$stack';
      }
    }
  });

  tearDownAll(() {
    final report = StringBuffer('Census check, ${DateTime.now().toUtc().toIso8601String()}\n\n');
    for (final v in visits) {
      final info = v.info;
      report.writeln(v.url);
      if (info == null) {
        report.writeln('  unreachable: ${v.unreachable}');
        continue;
      }
      report
        ..writeln('  ${info.title} — Flarum ${info.version.name}')
        ..writeln('  ${v.discussions} discussions listed, ${v.tags} tags')
        ..writeln('  thread: ${v.thread?.title ?? '-'} (${v.thread?.postIds.length ?? 0} post ids), '
            '${v.posts.length} posts rendered');
      if (v.unreachable != null) report.writeln('  refused or slow: ${v.unreachable}');
      if (v.parseError != null) report.writeln('  PARSE ERROR: ${v.parseError}');
      for (final e in v.renderErrors) {
        report.writeln('  RENDER ERROR: $e');
      }
    }
    Directory('build').createSync(recursive: true);
    File('build/census_report.txt').writeAsStringSync(report.toString());
    // ignore: avoid_print
    print(report);
  });

  group('census', () {
    for (final visit in visits) {
      testWidgets(visit.url, (tester) async {
        expect(visit.parseError, isNull, reason: 'the forum answered but its data did not parse');
        if (visit.info == null) return;
        expect(visit.info!.version, isIn(FlarumVersion.values));
        final site = SiteContext(
          siteType: FlarumProxyFactory.siteType,
          site: AppForumConfig(name: visit.info!.title, baseUrl: visit.url).toSite(),
        );
        for (final post in visit.posts.where((p) => p.isComment)) {
          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: PostTile(site: site, post: post),
              ),
            ),
          ));
          final error = tester.takeException();
          if (error != null && !'$error'.contains('HTTP request failed')) {
            visit.renderErrors.add('post ${post.number}: ${'$error'.split('\n').first}');
          }
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(minutes: 1));
        expect(visit.renderErrors, isEmpty);
      });
    }
  }, skip: 'reads real forums; run with --run-skipped -t census');
}
