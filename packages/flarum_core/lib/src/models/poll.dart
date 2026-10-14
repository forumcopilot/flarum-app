import '../attributes.dart';
import '../json_api.dart';
import 'user.dart';

/// A poll (fof/polls), as the reader sees it. Polls belong to a post: a new discussion's poll is
/// on its first post, and the web lets a reply have one too.
class FlarumPoll {
  const FlarumPoll({
    required this.id,
    required this.question,
    this.subtitle,
    this.endDate,
    this.hasEnded = false,
    this.allowMultipleVotes = false,
    this.maxVotes = 0,
    this.publicPoll = false,
    this.voteCount,
    this.canVote = false,
    this.canChangeVote = false,
    this.canSeeVoters = false,
    this.options = const [],
    this.myVotes = const {},
  });

  factory FlarumPoll.fromResource(JsonApiResource resource, JsonApiDocument document) {
    final a = resource.attributes;
    return FlarumPoll(
      id: resource.id,
      question: a.string('question') ?? '',
      subtitle: a.nonEmptyString('subtitle'),
      endDate: a.date('endDate'),
      hasEnded: a.boolean('hasEnded') ?? false,
      allowMultipleVotes: a.boolean('allowMultipleVotes') ?? false,
      maxVotes: a.integer('maxVotes') ?? 0,
      publicPoll: a.boolean('publicPoll') ?? false,
      voteCount: a.integer('voteCount'),
      canVote: a.boolean('canVote') ?? false,
      canChangeVote: a.boolean('canChangeVote') ?? false,
      canSeeVoters: a.boolean('canSeeVoters') ?? false,
      options: [
        for (final option in document.findAll(resource.toMany('options'))) FlarumPollOption.fromResource(option),
      ],
      myVotes: {
        for (final vote in document.findAll(resource.toMany('myVotes')))
          if (vote.toOne('option')?.id ?? vote.attributes.string('optionId') case final id?) id,
      },
    );
  }

  final String id;
  final String question;
  final String? subtitle;

  /// When voting closes; null for a poll that stays open.
  final DateTime? endDate;
  final bool hasEnded;
  final bool allowMultipleVotes;

  /// The most options a reader may choose when [allowMultipleVotes]: 0 for any number of them.
  final int maxVotes;

  /// Whether who voted for what is shown ([canSeeVoters] says whether to this reader).
  final bool publicPoll;

  /// Votes cast, when the reader may see the results: once they have voted, or always with the
  /// permission to see them first. Null while they're hidden; so are the options' counts.
  final int? voteCount;
  final bool canVote;
  final bool canChangeVote;
  final bool canSeeVoters;
  final List<FlarumPollOption> options;

  /// The options the reader voted for.
  final Set<String> myVotes;

  bool get hasVoted => myVotes.isNotEmpty;

  /// Whether the results are shown to this reader.
  bool get showsResults => voteCount != null;

  /// How many options the reader may choose.
  int get maxChoices => !allowMultipleVotes ? 1 : (maxVotes > 0 ? maxVotes : options.length);

  /// Whether the reader may vote now, or vote again: not once they've voted, unless they may change
  /// their vote.
  bool get takesVotes => canVote && !hasEnded && (!hasVoted || canChangeVote);
}

/// One of a [FlarumPoll]'s answers.
class FlarumPollOption {
  const FlarumPollOption({required this.id, required this.answer, this.imageUrl, this.voteCount});

  factory FlarumPollOption.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    return FlarumPollOption(
      id: resource.id,
      answer: a.string('answer') ?? '',
      imageUrl: a.nonEmptyString('imageUrl'),
      // 1.x sends null while the results are hidden, 2.0 leaves it out.
      voteCount: a.integer('voteCount'),
    );
  }

  final String id;
  final String answer;
  final String? imageUrl;
  final int? voteCount;
}

/// Someone's vote in a public poll: who, and for which option.
class FlarumPollVote {
  const FlarumPollVote({required this.optionId, this.user});

  final String optionId;
  final FlarumUser? user;
}

/// A poll to start with a new discussion, as the web's poll form sends it.
class FlarumNewPoll {
  const FlarumNewPoll({
    required this.question,
    required this.options,
    this.subtitle = '',
    this.endDate,
    this.allowMultipleVotes = false,
    this.maxVotes = 0,
    this.publicPoll = false,
    this.hideVotes = false,
    this.allowChangeVote = true,
  });

  final String question;
  final String subtitle;
  final List<String> options;

  /// When voting closes; null for never. fof/polls refuses one that isn't in the future.
  final DateTime? endDate;
  final bool allowMultipleVotes;

  /// The most options one may choose, 0 for any number. 1.x keeps 0 whatever is sent.
  final int maxVotes;

  /// Whether who voted for what is shown.
  final bool publicPoll;

  /// Whether the results stay hidden until voting closes (it needs an [endDate]).
  final bool hideVotes;

  /// Whether voters may change their vote (members may anyway when the forum lets them).
  final bool allowChangeVote;

  /// The `poll` attribute of the discussion the poll starts with.
  Map<String, Object?> toJson() => {
        'question': question,
        'subtitle': subtitle,
        'endDate': endDate?.toUtc().toIso8601String() ?? false,
        'publicPoll': publicPoll,
        'hideVotes': hideVotes && endDate != null,
        'allowChangeVote': allowChangeVote,
        'allowMultipleVotes': allowMultipleVotes,
        'maxVotes': allowMultipleVotes ? maxVotes : 0,
        'options': [
          for (final answer in options) {'answer': answer, 'imageUrl': null},
        ],
      };
}
