// Records the composer's writes on a live test forum into test/fixtures/v1 or v2 (write_*.json),
// which the offline tests replay: starting a discussion, replying, editing, and the forum's
// refusals (no tags, the posting throttle, someone else's post).
//
// carol starts the discussion and bob replies, so alice's state, which the other fixtures depend
// on, stays as seeded; an admin deletes the discussion at the end. The texts are WriteSamples'.
//
//   FLARUM_TEST_PASSWORD=… FLARUM_ADMIN_USER=admin FLARUM_ADMIN_PASSWORD=… \
//     FLARUM_DIR=/var/www/flarumapp/flarum1 dart run tool/record_write_fixtures.dart http://127.0.0.1:8081
//
// fof/byobu hides a private discussion even from an admin who isn't in it, and flarum/messages can't
// delete a dialog, so carol's are deleted on the server, by tool/test_forums/delete_discussions.php
// and delete_dialogs.php in FLARUM_DIR (or the commands are printed).

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flarum_core/api.dart';
import 'package:flarum_core/src/testing/write_samples.dart';

import 'fixture_recorder.dart';

Future<void> main(List<String> args) async {
  final env = Platform.environment;
  final password = env['FLARUM_TEST_PASSWORD'];
  final adminUser = env['FLARUM_ADMIN_USER'];
  final adminPassword = env['FLARUM_ADMIN_PASSWORD'];
  if (args.length != 1 || password == null || adminUser == null || adminPassword == null) {
    stderr.writeln('usage: FLARUM_TEST_PASSWORD=… FLARUM_ADMIN_USER=… FLARUM_ADMIN_PASSWORD=… '
        'dart run tool/record_write_fixtures.dart <forum url>');
    exit(64);
  }
  final url = args[0];
  final recorder = FixtureRecorder();
  FlarumApi member(Interceptor recorder) => FlarumApi(FlarumClient(url, dio: Dio()..interceptors.add(recorder)));
  final carol = member(recorder);
  final bob = member(recorder);
  final admin = FlarumApi(FlarumClient(url, dio: Dio()));
  final carolId = (await carol.logIn('carol', password)).userId;
  final bobId = (await bob.logIn('bob', password)).userId;
  await admin.logIn(adminUser, adminPassword);

  /// Private discussions to delete on the server at the end (fof/byobu hides them from the admin),
  /// and dialogs (flarum/messages has no way to delete them).
  final privateIds = <String>[];
  final dialogIds = <String>[];

  /// The discussions carol starts with polls, which the admin deletes at the end.
  final pollDiscussionIds = <String>[];

  /// Records the response [call] gets as fixture [name], refusals included; returns its value.
  Future<T?> record<T>(String name, Future<T> Function() call) async {
    recorder.names.add(name);
    try {
      return await call();
    } on FlarumApiException {
      return null;
    } finally {
      if (recorder.names.isNotEmpty) throw StateError('$name: no response recorded');
    }
  }

  final info = await carol.forumInfo();
  final version = info.version;
  // Known now, so that no later call asks for it under a fixture's name.
  await bob.forumInfo();
  final general = (await carol.tags()).firstWhere((t) => t.slug == 'general').id;
  // The refusals that come before any post: a post would set off the throttle for what follows.
  await record('write_start_discussion_no_tags', () => carol.startDiscussion(WriteSamples.title, WriteSamples.noTagsContent));
  final discussion = await record(
      'write_start_discussion', () => carol.startDiscussion(WriteSamples.title, WriteSamples.content, tagIds: [general]));
  if (discussion == null) throw StateError('The discussion was not started');
  try {
    final reply = await record('write_reply', () => bob.reply(discussion.id, WriteSamples.reply));
    if (reply == null) throw StateError('The reply was not posted');
    await record('write_reply_throttled', () => bob.reply(discussion.id, WriteSamples.throttledReply));
    await record('write_edit_post', () => bob.editPost(reply.id, WriteSamples.edit));
    await record('write_edit_post_not_theirs', () => carol.editPost(reply.id, WriteSamples.editByOther));
  } finally {
    await admin.client.delete('/discussions/${discussion.id}');
  }

  // Milestone 3's uploads (fof/upload): an image and a file, then the writer deletes one.
  final image = await record(
      'write_upload_image',
      () async => (await bob.upload([
            MultipartFile.fromBytes(base64Decode(WriteSamples.uploadImageBase64),
                filename: WriteSamples.uploadImageName),
          ]))
              .single);
  final file = await record(
      'write_upload_file',
      () async => (await bob.upload([
            MultipartFile.fromBytes(utf8.encode(WriteSamples.uploadFileText), filename: WriteSamples.uploadFileName),
          ]))
              .single);
  // Members may not delete their uploads by default (fof-upload.deleteUserUploads is moderators'):
  // the refusal is recorded, and the admin deletes both.
  if (file != null) await record('write_upload_delete', () => bob.deleteUpload(file.uuid));
  for (final upload in [image, file].nonNulls) {
    await admin.deleteUpload(upload.uuid);
  }

  // Milestone 2's actions, in a Q&A discussion (best answers need fof/best-answer's Q&A tag).
  final tags = await carol.tags();
  String tagId(String slug) => tags.firstWhere((t) => t.slug == slug).id;
  final reaction = info.reactions.firstWhere((r) => r.identifier == 'heart', orElse: () => info.reactions.first);
  // Past carol's and bob's posting throttle.
  await Future<void>.delayed(const Duration(seconds: 11));
  final question = await record('write_start_question',
      () => carol.startDiscussion(WriteSamples.questionTitle, WriteSamples.question, tagIds: [tagId('tech-help')]));
  if (question == null) throw StateError('The question was not started');
  try {
    final answer = await record('write_answer', () => bob.reply(question.id, WriteSamples.answer));
    if (answer == null) throw StateError('The answer was not posted');
    // The thread as carol, who asked, opens it: for the screens' tests.
    await record('write_question_with_post_ids', () => carol.discussion(question.id, withPostIds: true));
    await record('write_question_posts', () => carol.posts(question.id));
    // The SDK's reaction toggle and best answer read the post first: before and after a reaction.
    await record('write_answer_read', () => carol.post(answer.id));
    await record('write_like', () => carol.likePost(answer.id, liked: true));
    await record('write_unlike', () => carol.likePost(answer.id, liked: false));
    await record('write_react', () => carol.reactToPost(answer.id, reaction.id));
    await record('write_answer_read_reacted', () => carol.post(answer.id));
    await record('write_unreact', () => carol.unreactToPost(answer.id, reaction.id));
    recorder.matchData.addAll(['write_best_answer', 'write_best_answer_none', 'write_tag_follow', 'write_tag_none']);
    await record('write_best_answer', () => carol.setBestAnswer(question.id, answer.id));
    await record('write_best_answer_none', () => carol.setBestAnswer(question.id, null));
    await record('write_follow', () => bob.setSubscription(question.id, 'follow'));
    await record('write_ignore', () => bob.setSubscription(question.id, 'ignore'));
    await record('write_unfollow', () => bob.setSubscription(question.id, null));
    await record('write_bookmark_post', () => bob.bookmarkPost(answer.id, bookmarked: true));
    await record('write_bookmark_discussion', () => bob.bookmarkDiscussion(question.id, bookmarked: true));
    await record('write_bookmarked_discussions', () => bob.discussions(bookmarked: true));
    await record('write_bookmarked_posts', () => bob.bookmarkedPosts());
    await record('write_unbookmark_post', () => bob.bookmarkPost(answer.id, bookmarked: false));
    await record('write_unbookmark_discussion', () => bob.bookmarkDiscussion(question.id, bookmarked: false));
    await record('write_tag_follow', () => bob.setTagSubscription(tagId('cycling'), 'follow'));
    await record('write_tag_none', () => bob.setTagSubscription(tagId('cycling'), null));

    // Milestone 4: carol reports bob's answer, and ignores him for a while.
    recorder.states.addAll({
      for (final name in ['write_forum_ignoring', 'write_question_posts_ignoring', 'write_user_ignored']) name: 'ignoring',
    });
    await record('write_flag_post',
        () => carol.flagPost(answer.id, reason: 'off_topic', detail: WriteSamples.flagDetail));
    await record('write_flag_post_without_reason', () => carol.flagPost(answer.id));
    await record('write_ignore_user', () => carol.setIgnored(bobId, true));
    await record('write_ignore_self', () => carol.setIgnored(carolId, true));
    await record('write_forum_ignoring', () => carol.forumInfo());
    await record('write_question_posts_ignoring', () => carol.posts(question.id));
    await record('write_user_ignored', () => carol.user(bobId));
    await record('write_unignore_user', () => carol.setIgnored(bobId, false));

    // fof/terms: the admin adds a policy, which carol must accept before she may post again; it's
    // deleted after, so the members' permissions are as they were.
    final policies = version == FlarumVersion.v2 ? '/fof-terms-policies' : '/fof/terms/policies';
    // Past carol's posting throttle, which the forum checks before her permissions.
    await Future<void>.delayed(const Duration(seconds: 11));
    final policy = (await admin.client.post(policies, {
      'data': {
        'type': 'fof-terms-policies',
        'attributes': {
          'name': WriteSamples.policyName,
          'url': WriteSamples.policyUrl,
          version == FlarumVersion.v2 ? 'updateMessage' : 'update_message': WriteSamples.policyUpdate,
        },
      },
    }))
        .single
        .id;
    try {
      recorder.states.addAll({'write_forum_terms': 'terms', 'write_forum_terms_accepted': 'terms'});
      await record('write_forum_terms', () => carol.forumInfo());
      await record('write_reply_before_terms', () => carol.reply(question.id, WriteSamples.termsReply));
      await record('write_accept_terms', () => carol.acceptPolicy(policy));
      await record('write_forum_terms_accepted', () => carol.forumInfo());
    } finally {
      await admin.client.delete('$policies/$policy');
    }

    // fof/byobu: carol starts a private discussion with bob (a member may have one other person in
    // one, not two), and he replies; she may not change who's in it.
    final aliceId = (await carol.userBySlug('alice')).id;
    recorder.matchData.addAll(['write_start_private_too_many', 'write_start_private']);
    await record('write_start_private_too_many',
        () => carol.startPrivateDiscussion(WriteSamples.privateTitle, WriteSamples.privateContent, [bobId, aliceId]));
    final private = await record('write_start_private',
        () => carol.startPrivateDiscussion(WriteSamples.privateTitle, WriteSamples.privateContent, [bobId]));
    if (private != null) {
      privateIds.add(private.id);
      await record('write_private_list', () => carol.discussions(private: true));
      await record('write_private_recipients', () => carol.recipients(private.id));
      await record('write_private_reply', () => bob.reply(private.id, WriteSamples.privateReply));
      await record('write_private_with_post_ids', () => carol.discussion(private.id, withPostIds: true));
      // The SDK's conversation reads it without the post ids (on 2.0 the same request).
      await record('write_private_discussion', () => carol.discussion(private.id));
      await record('write_private_posts', () => carol.posts(private.id));
      await record('write_private_set_recipients', () => carol.setRecipients(private.id, [carolId]));
    }

    // flarum/messages (2.0): carol writes to bob, he answers, and she reads it. Dialogs have no
    // delete endpoint (and members may not delete messages), so hers is deleted on the server too.
    if (version == FlarumVersion.v2) {
      final sent = await record('write_message_new', () => carol.sendMessage(WriteSamples.message, userIds: [bobId]));
      final dialogId = sent?.dialogId;
      if (dialogId != null) {
        dialogIds.add(dialogId);
        final reply =
            await record('write_message_reply', () => bob.sendMessage(WriteSamples.messageReply, dialogId: dialogId));
        await record('write_dialogs', () => carol.dialogs());
        await record('write_dialog', () => carol.dialog(dialogId));
        await record('write_dialog_messages', () => carol.dialogMessages(dialogId));
        recorder.states['write_forum_messages'] = 'messages';
        await record('write_forum_messages', () => carol.forumInfo());
        if (reply != null) await record('write_dialog_read', () => carol.markDialogRead(dialogId, reply.id));
      }
    }

    // Milestone 5: moderation, as the admin, on carol's question and bob's answer.
    final mod = member(recorder);
    await mod.logIn(adminUser, adminPassword);
    await mod.forumInfo();
    try {
      await record('write_lock', () => mod.setLocked(question.id, true));
      await record('write_unlock', () => mod.setLocked(question.id, false));
      await record('write_stick', () => mod.setSticky(question.id, true));
      await record('write_unstick', () => mod.setSticky(question.id, false));
      await record('write_rename', () => mod.renameDiscussion(question.id, WriteSamples.renamedTitle));
      await record('write_hide_post', () => mod.setPostHidden(answer.id, true));
      await record('write_restore_post', () => mod.setPostHidden(answer.id, false));
      await record('write_hide_discussion', () => mod.setDiscussionHidden(question.id, true));
      await record('write_restore_discussion', () => mod.setDiscussionHidden(question.id, false));
      // The thread as the moderator reads it, with the events those left.
      recorder.states.addAll({
        for (final name in ['write_forum_moderator', 'write_question_with_post_ids_moderator', 'write_question_posts_moderator'])
          name: 'moderator',
      });
      await record('write_forum_moderator', () => mod.forumInfo());
      await record('write_question_with_post_ids_moderator', () => mod.discussion(question.id, withPostIds: true));
      await record('write_question_posts_moderator', () => mod.posts(question.id));
      // bob's profile as the moderator sees it: they may suspend him.
      recorder.states['write_user_bob_moderator'] = 'moderator';
      await record('write_user_bob_moderator', () => mod.userBySlug('bob'));
      // A reply deleted for good, past bob's posting throttle.
      await Future<void>.delayed(const Duration(seconds: 11));
      final extra = await record('write_reply_to_delete', () => bob.reply(question.id, WriteSamples.replyToDelete));
      if (extra != null) await record('write_delete_post', () => mod.deletePost(extra.id));
      // bob suspended "indefinitely", as the web does it (until 2038), and at once let back.
      await record('write_suspend', () => mod.suspend(bobId, FlarumUser.indefiniteSuspension,
          reason: WriteSamples.suspendReason, message: WriteSamples.suspendReason));
      recorder.states['write_forum_suspended'] = 'suspended';
      await record('write_forum_suspended', () => bob.forumInfo());
      await record('write_unsuspend', () => mod.suspend(bobId, null));
    } finally {
      // Never leave bob suspended.
      await admin.suspend(bobId, null);
      await mod.logOut();
    }

    // fof/polls: carol starts a discussion with a poll, after one the forum refuses (closing in the
    // past); bob votes, changes his vote, sees who voted (it's public) and takes his vote back.
    await Future<void>.delayed(const Duration(seconds: 11));
    await record('write_poll_invalid', () => carol.startDiscussion(WriteSamples.pollTitle, WriteSamples.pollContent,
        tagIds: [general],
        poll: FlarumNewPoll(
            question: WriteSamples.pollQuestion,
            options: WriteSamples.pollOptions,
            endDate: DateTime.now().subtract(const Duration(days: 1)))));
    final polled = await record('write_poll_discussion', () => carol.startDiscussion(WriteSamples.pollTitle, WriteSamples.pollContent,
        tagIds: [general],
        poll: const FlarumNewPoll(question: WriteSamples.pollQuestion, options: WriteSamples.pollOptions, publicPoll: true)));
    if (polled == null) throw StateError('The poll was not started');
    pollDiscussionIds.add(polled.id);
    // The thread as bob opens it: the discussion with its post ids, then its posts.
    await record('write_poll_with_post_ids', () => bob.discussion(polled.id, withPostIds: true));
    final poll = (await record('write_poll_posts', () => bob.posts(polled.id)))?.items.first.polls.firstOrNull;
    if (poll == null) throw StateError('The poll did not come with its post');
    final [first, second, ...] = [for (final option in poll.options) option.id];
    recorder.matchData.addAll(['write_poll_vote', 'write_poll_vote_change', 'write_poll_unvote']);
    await record('write_poll_vote', () => bob.votePoll(poll.id, [first]));
    await record('write_poll_vote_change', () => bob.votePoll(poll.id, [second]));
    await record('write_poll_votes', () => bob.pollVotes(poll.id));
    recorder.states['write_poll_posts_voted'] = 'voted';
    await record('write_poll_posts_voted', () => bob.posts(polled.id));
    await record('write_poll_unvote', () => bob.votePoll(poll.id, []));
    // Several choices, at most two (1.x keeps "any number" whatever it's sent).
    await Future<void>.delayed(const Duration(seconds: 11));
    final multiple = await record('write_poll_multiple_discussion', () => carol.startDiscussion(
        WriteSamples.multiplePollTitle, WriteSamples.pollContent,
        tagIds: [general],
        poll: const FlarumNewPoll(
            question: WriteSamples.multiplePollQuestion,
            options: WriteSamples.multiplePollOptions,
            allowMultipleVotes: true,
            maxVotes: 2)));
    if (multiple != null) {
      pollDiscussionIds.add(multiple.id);
      final choices = (await record('write_poll_multiple_posts', () => bob.posts(multiple.id)))?.items.first.polls.firstOrNull;
      if (choices != null) {
        await record('write_poll_vote_multiple',
            () => bob.votePoll(choices.id, [for (final option in choices.options.take(2)) option.id]));
      }
    }

    // fof/drafts: carol saves a reply, a new discussion and a private one for later, lists them,
    // changes the reply, and deletes them.
    final replyDraft = await record('write_draft_reply',
        () => carol.saveDraft(content: WriteSamples.draftReply, discussionId: question.id));
    final discussionDraft = await record('write_draft_discussion',
        () => carol.saveDraft(title: WriteSamples.draftTitle, content: WriteSamples.draftContent, tagIds: [general]));
    final privateDraft = await record('write_draft_private', () => carol.saveDraft(
        title: WriteSamples.draftPrivateTitle, content: WriteSamples.draftPrivateContent, recipientIds: [bobId]));
    await record('write_drafts', () => carol.drafts());
    // A reply draft names only its discussion: the app reads it for its title, and to resume it.
    await record('write_question', () => carol.discussion(question.id));
    recorder.states['write_forum_drafts'] = 'drafts';
    await record('write_forum_drafts', () => carol.forumInfo());
    if (replyDraft != null) {
      await record('write_draft_update', () => carol.saveDraft(
          id: replyDraft.id, content: WriteSamples.draftReplyEdited, discussionId: question.id));
    }
    for (final (name, draft) in [('reply', replyDraft), ('discussion', discussionDraft), ('private', privateDraft)]) {
      if (draft != null) await record('write_draft_delete_$name', () => carol.deleteDraft(draft.id));
    }
  } finally {
    for (final id in pollDiscussionIds) {
      await admin.client.delete('/discussions/$id');
    }
    await admin.client.delete('/discussions/${question.id}');
    for (final api in [carol, bob, admin]) {
      await api.logOut();
    }
    if (privateIds.isNotEmpty) await deleteOnServer('delete_discussions.php', privateIds);
    if (dialogIds.isNotEmpty) await deleteOnServer('delete_dialogs.php', dialogIds);
  }

  final dir = Directory('test/fixtures/${version.name}')..createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  for (final MapEntry(key: name, value: fixture) in recorder.recorded.entries) {
    File('${dir.path}/$name.json').writeAsStringSync('${encoder.convert(fixture)}\n');
  }
  stdout.writeln('Recorded ${recorder.recorded.length} write fixtures into ${dir.path}');
}

/// Deletes [ids] with [script] from tool/test_forums, in the forum at FLARUM_DIR; without it, says
/// how.
Future<void> deleteOnServer(String script, List<String> ids) async {
  final dir = Platform.environment['FLARUM_DIR'];
  script = File('../../tool/test_forums/$script').absolute.path;
  final command = ['sudo', '-u', 'www-data', 'php', script, dir ?? '<the forum\'s directory>', ...ids];
  if (dir == null) {
    stderr.writeln('To delete: ${command.join(' ')}');
    return;
  }
  final result = await Process.run(command.first, command.skip(1).toList());
  stdout.write(result.stdout);
  if (result.exitCode != 0) stderr.writeln('Deleting ${ids.join(', ')} failed: ${result.stderr}');
}
