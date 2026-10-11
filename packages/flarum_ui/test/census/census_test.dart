// Reads real Flarum forums from the plan's census (data/flarum-census-2026-10-08.json), as a
// guest and read-only, and renders their posts with the app's renderer: the server-side half of
// Phase 2's exit check (browse 20 census forums on both versions and several languages). A few
// GET requests per forum, with the app's User-Agent: the forum, its latest discussions and tags,
// a tag's discussions, a thread, and its first poster's profile found by slug with their posts and
// discussions. Skipped by default; it needs the network:
//
//   flutter test --run-skipped -t census test/census/census_test.dart
//
// With CENSUS_FILE pointing at the census file, it reads every guest-readable forum in it on
// 1.0 or later (about 200), a few at a time; the file isn't in this repository.
//
// Writes build/census_report.txt. Fails on what the app should handle: a forum that answers
// but whose data doesn't parse, or a post the renderer can't draw. A forum that doesn't answer
// (down, blocking, Cloudflare) is reported, not failed.
@Tags(['census'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/theme/app_theme.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// By default, 20 active, guest-readable forums from the census (12 on 1.x, 8 on 2.0; English, French,
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

/// [_forums], or every guest-readable forum on 1.0 or later in the census file at CENSUS_FILE.
List<String> _forumsToVisit() {
  final file = Platform.environment['CENSUS_FILE'];
  if (file == null || file.isEmpty) return _forums;
  final census = jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final forum in (census['forums'] as List).cast<Map<String, dynamic>>())
      if (forum['guest_readable'] == true && (forum['version'] == '1.x' || forum['version'] == '2.0'))
        (forum['url'] as String).replaceAll(RegExp(r'/+$'), ''),
  ];
}

class _Visit {
  _Visit(this.url);

  final String url;
  FlarumForumInfo? info;
  int discussions = 0;
  int tags = 0;
  String? tagListed;
  FlarumDiscussion? thread;
  List<FlarumPost> posts = const [];

  /// The thread's first poster, found by slug, and how many posts and discussions of theirs list.
  String? profile;
  Object? profileRefused;
  Object? unreachable;
  Object? parseError;
  final renderErrors = <String>[];
}

const _timeout = Duration(seconds: 30);

Future<void> _read(_Visit visit) async {
  final forum = FlarumForum.forUrl(visit.url);
  try {
    visit.info = await forum.refresh().timeout(_timeout);
  } catch (e) {
    visit.unreachable = e;
    return;
  }
  try {
    final page = await forum.api.discussions(limit: 10).timeout(_timeout);
    visit.discussions = page.items.length;
    final tags = await forum.api.tags().timeout(_timeout);
    visit.tags = tags.length;
    final tag = tags.where((t) => t.isPrimary).firstOrNull;
    if (tag != null) {
      final listed = await forum.api.discussions(tagSlug: tag.slug, limit: 5).timeout(_timeout);
      visit.tagListed = '${tag.slug}: ${listed.items.length}';
    }
    final candidates = page.items.where((d) => !d.isSticky && d.commentCount > 1);
    final pick = candidates.isNotEmpty ? candidates.first : page.items.firstOrNull;
    if (pick != null) {
      visit.thread = await forum.api.discussion(pick.id, withPostIds: true).timeout(_timeout);
      visit.posts = (await forum.api.posts(pick.id, limit: 20).timeout(_timeout)).items;
    }
  } on TimeoutException catch (e) {
    visit.unreachable = e;
  } on FlarumApiException catch (e) {
    // A refusal (permissions, rate limits) is the forum's answer, not a parsing fault.
    visit.unreachable = e;
  } catch (e, stack) {
    visit.parseError = '$e\n$stack';
  }
  // The profile as the app opens it from a post: by the author's slug, then their lists by username.
  final author = visit.posts.map((p) => p.author).nonNulls.firstOrNull;
  if (author == null || visit.parseError != null) return;
  try {
    final user = await forum.api.userBySlug(author.slug ?? author.username).timeout(_timeout);
    final key = await forum.api.authorKey(user);
    final posts = await forum.api.userPosts(key, limit: 5).timeout(_timeout);
    final discussions = await forum.api.discussions(author: key, limit: 5).timeout(_timeout);
    visit.profile = '@${user.username} (slug ${author.slug ?? '-'}): ${posts.items.length} posts, '
        '${discussions.items.length} discussions';
  } on TimeoutException catch (e) {
    visit.profileRefused = e;
  } on FlarumApiException catch (e) {
    // Forums can keep profiles from guests.
    visit.profileRefused = e;
  } catch (e, stack) {
    visit.parseError = 'profile: $e\n$stack';
  }
}

void main() {
  final visits = [for (final url in _forumsToVisit()) _Visit(url)];

  setUpAll(() async {
    HttpOverrides.global = null;
    // A few forums at a time: each sees its few requests one after another.
    final queue = [...visits];
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        await _read(queue.removeAt(0));
      }
    }

    await Future.wait([for (var i = 0; i < 6; i++) worker()]);
  });

  tearDownAll(() {
    final read = visits.where((v) => v.info != null);
    final report = StringBuffer('Census check, ${DateTime.now().toUtc().toIso8601String()}\n')
      ..writeln('${visits.length} forums: ${read.length} read '
          '(${read.where((v) => v.info!.version == FlarumVersion.v1).length} on 1.x, '
          '${read.where((v) => v.info!.version == FlarumVersion.v2).length} on 2.0), '
          '${visits.length - read.length} unreachable; '
          '${read.fold(0, (n, v) => n + v.posts.length)} posts rendered; '
          '${read.where((v) => v.profile != null).length} profiles found by slug; '
          '${visits.where((v) => v.parseError != null).length} parse errors, '
          '${visits.where((v) => v.renderErrors.isNotEmpty).length} forums with render errors\n');
    for (final v in visits) {
      final info = v.info;
      report.writeln(v.url);
      if (info == null) {
        report.writeln('  unreachable: ${v.unreachable}');
        continue;
      }
      report
        ..writeln('  ${info.title} — Flarum ${info.version.name}')
        ..writeln('  ${v.discussions} discussions listed, ${v.tags} tags; a tag lists ${v.tagListed ?? '-'}')
        ..writeln('  profile: ${v.profile ?? 'refused: ${v.profileRefused}'}')
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
