import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/src/widgets/flarum_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/app_theme.dart';

const _fixtures = '../flarum_core/test/fixtures';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Who liked and reacted to the community's welcome post, as recorded: six members like it (the
/// post names four), bob reacted 👍 and carol 👎 (fof/reactions' first two), which only a reader
/// with canSeeReactions may list (the admin, served in the `seesReactions` state).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      late FixtureForum fixtures;
      late FlarumApi api;
      late String liked;
      late List<FlarumReaction> reactions;
      late FlarumPost post;

      Future<void> setUpForum(WidgetTester tester, {Set<String> states = const {}}) async {
        fixtures = FixtureForum(version, root: _fixtures, states: states);
        api = fixtures.api();
        liked = (fixtures.seed['posts'] as Map)['liked'] as String;
        reactions = (await tester.runAsync(api.forumInfo))!.reactions;
        final likers = (await tester.runAsync(() => api.likers(liked)))!.items;
        post = FlarumPost(
          id: liked,
          number: 1,
          contentType: 'comment',
          likesCount: likers.length,
          likedBy: likers.take(4).toList(),
          reactionCounts: const {'1': 1, '2': 1},
        );
        fixtures.requests.clear();
      }

      Future<void> openSheet(WidgetTester tester, {bool likers = true, bool reactors = true, bool guest = false}) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            FlarumLocalizations.delegate,
            KitLocalizations.delegate,
            ...FlarumLocalizations.localizationsDelegates,
          ],
          home: Scaffold(
            body: Center(
              child: PostActionsRow(
                post: post,
                reactions: reactions,
                readerId: guest ? null : fixtures.userId('alice'),
                loadLikers: likers ? (offset) => api.likers(liked, offset: offset) : null,
                loadReactions: reactors ? (offset) => api.postReactions(liked, offset: offset) : null,
                likesLabel: 'Six people like this.',
              ),
            ),
          ),
        ));
        await tester.tap(find.text('8'));
        await _settle(tester);
        expect(find.text('Likes and Reactions'), findsOneWidget);
      }

      Finder inSheet(Finder finder) => find.descendant(of: find.byType(BottomSheet), matching: finder);
      Finder chip(Finder label) => find.ancestor(of: label, matching: find.byType(ChoiceChip));

      testWidgets('everyone who liked and reacted, with a chip for each kind', (tester) async {
        await setUpForum(tester, states: {'seesReactions'});
        await openSheet(tester);

        expect(inSheet(find.byType(FlarumAvatar)), findsNWidgets(8), reason: 'six likers and two who reacted');
        expect(inSheet(find.text("Grace O'Neill")), findsOneWidget, reason: 'past the four the post names');
        expect(inSheet(find.text('@grace')), findsOneWidget, reason: 'her username, under her name');
        expect(inSheet(find.textContaining('other')), findsNothing, reason: 'everyone is named');
        expect(find.byType(ChoiceChip), findsNWidgets(4), reason: 'All, Likes, 👍 and 👎');
        expect(fixtures.requests.map((r) => r.path), containsAll(['/users', contains('reactions')]));

        await tester.tap(chip(find.text('👎')));
        await _settle(tester);
        expect(inSheet(find.byType(FlarumAvatar)), findsOneWidget);
        expect(inSheet(find.text('carol')), findsOneWidget);

        await tester.tap(chip(find.byIcon(Icons.thumb_up)));
        await _settle(tester);
        expect(inSheet(find.byType(FlarumAvatar)), findsNWidgets(6));
        expect(inSheet(find.text('bob')), findsNothing);
      });

      testWidgets('where the reader may not see who reacted, the reactions show their counts', (tester) async {
        await setUpForum(tester);
        await openSheet(tester, reactors: false);

        expect(inSheet(find.byType(FlarumAvatar)), findsNWidgets(6));
        expect(find.byType(ChoiceChip), findsNothing, reason: 'one kind is named: the likes');
        expect(inSheet(find.text('Reactions')), findsOneWidget);
        expect(inSheet(find.widgetWithText(Chip, '👎')), findsOneWidget);
        expect(fixtures.requests.where((r) => r.path.contains('reactions')), isEmpty);
      });

      testWidgets('a guest sees the likers the post names, and how many more', (tester) async {
        await setUpForum(tester);
        await openSheet(tester, likers: false, reactors: false, guest: true);

        expect(inSheet(find.byType(FlarumAvatar)), findsNWidgets(4));
        expect(inSheet(find.text('and 2 others')), findsOneWidget);
        expect(fixtures.requests, isEmpty);
      });
    });
  }
}
