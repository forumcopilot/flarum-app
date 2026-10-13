import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Moderation (Milestone 5), replayed from the write fixtures: the admin on carol's question and
/// bob's answer, and bob suspended for a moment (tool/record_write_fixtures.dart).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Map<String, dynamic> recorded(String name) =>
          jsonDecode(File('test/fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;
      String lastPathPart(String name) => (recorded(name)['request']['path'] as String).split('/').last;
      final questionId = lastPathPart('write_lock');
      final answerId = lastPathPart('write_hide_post');
      final bobId = lastPathPart('write_suspend');

      test('locks and unlocks, pins and unpins, renames', () async {
        final api = FixtureForum(version).api();
        expect((await api.setLocked(questionId, true)).isLocked, isTrue);
        expect((await api.setLocked(questionId, false)).isLocked, isFalse);
        expect((await api.setSticky(questionId, true)).isSticky, isTrue);
        expect((await api.setSticky(questionId, false)).isSticky, isFalse);
        expect((await api.renameDiscussion(questionId, WriteSamples.renamedTitle)).title, WriteSamples.renamedTitle);
      });

      test('hides and restores a post and a discussion, and deletes a post for good', () async {
        final api = FixtureForum(version).api();
        expect((await api.setPostHidden(answerId, true)).isHidden, isTrue, reason: '2.0 says so only by hiddenAt');
        expect((await api.setPostHidden(answerId, false)).isHidden, isFalse);
        expect((await api.setDiscussionHidden(questionId, true)).isHidden, isTrue);
        expect((await api.setDiscussionHidden(questionId, false)).isHidden, isFalse);
        await api.deletePost(lastPathPart('write_delete_post'));
      });

      test('a moderator may do it all; the thread shows the rename', () async {
        final api = FixtureForum(version, states: {'moderator'}).api();
        final discussion = await api.discussion(questionId, withPostIds: true);
        expect((discussion.title, discussion.canLock, discussion.canSticky, discussion.canRename, discussion.canHide),
            (WriteSamples.renamedTitle, true, true, true, true));
        final posts = (await api.posts(questionId)).items;
        expect(posts.last.contentType, 'discussionRenamed');
        expect(posts[1].canHide && posts[1].canDelete, isTrue);
      });

      test('suspends a member indefinitely, as the web does, and lets them back', () async {
        final api = FixtureForum(version).api();
        final suspended = await api.suspend(bobId, FlarumUser.indefiniteSuspension,
            reason: WriteSamples.suspendReason, message: WriteSamples.suspendReason);
        expect((suspended.isSuspended, suspended.isSuspendedIndefinitely), (true, true));
        expect((suspended.suspendReason, suspended.suspendMessage, suspended.canSuspend),
            (WriteSamples.suspendReason, WriteSamples.suspendReason, true));
        final back = await api.suspend(bobId, null);
        expect((back.suspendedUntil, back.isSuspended), (null, false));
      });

      test('the suspended member sees until when, and why', () async {
        final actor = (await FixtureForum(version, states: {'suspended'}).api().forumInfo()).actor!;
        expect((actor.username, actor.isSuspendedIndefinitely, actor.suspendMessage),
            ('bob', true, WriteSamples.suspendReason));
      });
    });
  }
}
