import 'dart:convert';
import 'dart:io';

import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// fof/polls, replayed from the write fixtures: carol starts a discussion with a poll, bob votes,
/// changes his vote, sees who voted and takes his vote back (tool/record_write_fixtures.dart).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      Map<String, dynamic> recorded(String name) =>
          jsonDecode(File('test/fixtures/${version.name}/$name.json').readAsStringSync()) as Map<String, dynamic>;
      String discussionId(String name) => (recorded(name)['body']['data'] as Map)['id'] as String;
      final pollsPath = version == FlarumVersion.v2 ? '/polls' : '/fof/polls';

      test('a discussion starts with its poll, which fof/polls checks', () async {
        final fixtures = FixtureForum(version);
        final api = fixtures.api();
        const poll = FlarumNewPoll(question: WriteSamples.pollQuestion, options: WriteSamples.pollOptions, publicPoll: true);
        final started = await api.startDiscussion(WriteSamples.pollTitle, WriteSamples.pollContent,
            tagIds: [fixtures.tagId('general')], poll: poll);
        expect(started.title, WriteSamples.pollTitle);
        final sent = (fixtures.requests.last.data as Map)['data']['attributes']['poll'] as Map;
        expect(sent['question'], WriteSamples.pollQuestion);
        expect([for (final option in sent['options'] as List) option['answer']], WriteSamples.pollOptions);
        expect((sent['publicPoll'], sent['endDate'], sent['allowMultipleVotes']), (true, false, false));

        // One closing in the past is refused, with the forum's reason.
        await expectLater(
          api.startDiscussion(WriteSamples.pollTitle, WriteSamples.pollContent,
              tagIds: [fixtures.tagId('general')],
              poll: FlarumNewPoll(
                  question: WriteSamples.pollQuestion,
                  options: WriteSamples.pollOptions,
                  endDate: DateTime.parse((recorded('write_poll_invalid')['request']['body']['data']['attributes']['poll']
                      as Map)['endDate'] as String))),
          throwsA(isA<FlarumApiException>()
              .having((e) => e.statusCode, 'status', 422)
              .having((e) => e.hasDetail, 'says why', isTrue)),
        );
      });

      test('a thread\'s posts come with their polls; the results show once the reader votes', () async {
        final fixtures = FixtureForum(version);
        final api = fixtures.api();
        final post = (await api.posts(discussionId('write_poll_discussion'))).items.first;
        final poll = post.polls.single;
        expect((poll.question, poll.publicPoll, poll.allowMultipleVotes, poll.maxChoices), (WriteSamples.pollQuestion, true, false, 1));
        expect([for (final option in poll.options) option.answer], WriteSamples.pollOptions);
        expect((poll.canVote, poll.hasVoted, poll.takesVotes, poll.hasEnded, poll.endDate), (true, false, true, false, null));
        expect(poll.showsResults, isFalse, reason: 'members see them once they vote');
        expect(poll.options.map((o) => o.voteCount), everyElement(isNull));
        expect(fixtures.requests.last.queryParameters['include'], contains('polls.myVotes.option'));

        final [first, second, ...] = poll.options;
        final voted = await api.votePoll(poll.id, [first.id, first.id]);
        expect(fixtures.requests.last.path, '$pollsPath/${poll.id}/votes');
        expect((fixtures.requests.last.data as Map)['data'], {
          'optionIds': [first.id],
        }, reason: 'each option once: the forum would count it twice');
        expect(voted.myVotes, {first.id});
        expect((voted.voteCount, voted.options.first.voteCount), (1, 1));
        expect(voted.canChangeVote, isTrue, reason: 'members may change their vote');

        final changed = await api.votePoll(poll.id, [second.id]);
        expect(changed.myVotes, {second.id});
        expect(changed.voteCount, 1);
        expect([for (final option in changed.options) option.voteCount], [0, 1, 0]);

        final votes = await api.pollVotes(poll.id);
        expect([for (final vote in votes) (vote.optionId, vote.user?.username)], [(second.id, 'bob')]);

        final unvoted = await api.votePoll(poll.id, []);
        expect(unvoted.myVotes, isEmpty);
      });

      test('the thread read again shows the reader\'s vote', () async {
        final api = FixtureForum(version, states: {'voted'}).api();
        final poll = (await api.posts(discussionId('write_poll_discussion'))).items.first.polls.single;
        expect((poll.hasVoted, poll.showsResults, poll.takesVotes), (true, true, true));
        expect(poll.myVotes.single, poll.options[1].id);
      });

      test('a poll with several choices takes as many as it allows', () async {
        final api = FixtureForum(version).api();
        final poll = (await api.posts(discussionId('write_poll_multiple_discussion'))).items.first.polls.single;
        expect(poll.allowMultipleVotes, isTrue);
        // 1.x stores "any number" whatever it's sent.
        expect(poll.maxChoices, version == FlarumVersion.v2 ? 2 : WriteSamples.multiplePollOptions.length);
        final voted = await api.votePoll(poll.id, [for (final option in poll.options.take(2)) option.id]);
        expect(voted.myVotes, hasLength(2));
      });
    });
  }
}
