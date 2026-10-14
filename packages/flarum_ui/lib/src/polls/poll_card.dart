import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';
import '../widgets/flarum_avatar.dart';

/// A post's poll (fof/polls): its question and answers, and the results once the reader may see
/// them. Voting is as the web's: in a single-choice poll a tap votes (and, where the reader may
/// change their vote, a tap on another answer changes it, on theirs takes it back); in a
/// multiple-choice one the reader chooses, then votes, unless they may change their vote, when
/// each tap counts at once.
class PollCard extends StatefulWidget {
  const PollCard({super.key, required this.site, required this.poll, this.onChanged});

  final SiteContext site;
  final FlarumPoll poll;

  /// The poll after the reader voted; null where the reader can't vote.
  final ValueChanged<FlarumPoll>? onChanged;

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  late Set<String> _chosen = {...widget.poll.myVotes};
  bool _sending = false;

  FlarumPoll get _poll => widget.poll;

  @override
  void didUpdateWidget(PollCard old) {
    super.didUpdateWidget(old);
    if (!identical(old.poll, widget.poll)) _chosen = {...widget.poll.myVotes};
  }

  bool get _canVote => _poll.takesVotes && widget.onChanged != null && !_sending;

  /// Choices are collected and sent with Vote: several, where they can't be changed once sent.
  bool get _collects => _poll.allowMultipleVotes && !_poll.canChangeVote;

  void _tap(FlarumPollOption option) {
    if (!_canVote) return;
    final l10n = flarumL10n(context);
    if (!_poll.allowMultipleVotes) {
      _send(_chosen.contains(option.id) ? {} : {option.id});
      return;
    }
    final chosen = {..._chosen};
    if (!chosen.remove(option.id)) {
      if (chosen.length >= _poll.maxChoices) {
        SnackbarHelper.showInfo(context, l10n.pollChooseUpTo(_poll.maxChoices));
        return;
      }
      chosen.add(option.id);
    }
    if (_collects) {
      setState(() => _chosen = chosen);
    } else {
      _send(chosen);
    }
  }

  Future<void> _send(Set<String> optionIds) async {
    final before = _chosen;
    setState(() {
      _sending = true;
      _chosen = optionIds;
    });
    try {
      final poll = await FlarumForum.of(widget.site).api.votePoll(_poll.id, optionIds.toList());
      if (!mounted) return;
      setState(() => _sending = false);
      widget.onChanged?.call(poll);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _chosen = before;
      });
      SnackbarHelper.showError(context, describeError(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = flarumL10n(context);
    final poll = _poll;
    final total = poll.voteCount ?? 0;
    final notes = [
      if (poll.voteCount case final count?) l10n.pollVotes(count),
      if (poll.hasEnded)
        l10n.pollEnded
      else if (poll.endDate case final end?)
        l10n.pollEndsOn(DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_jm().format(end.toLocal())),
      if (poll.allowMultipleVotes && poll.takesVotes) l10n.pollChooseUpTo(poll.maxChoices),
    ];
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.spacingS),
      padding: const EdgeInsets.all(DesignTokens.spacingM),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.poll_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: DesignTokens.spacingS),
              Expanded(child: Text(poll.question, style: theme.textTheme.titleSmall)),
            ],
          ),
          if (poll.subtitle case final subtitle?)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
              child: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
          const SizedBox(height: DesignTokens.spacingS),
          for (final option in poll.options)
            _OptionRow(
              option: option,
              chosen: _chosen.contains(option.id),
              multiple: poll.allowMultipleVotes,
              selectable: _canVote,
              share: poll.showsResults && total > 0 ? (option.voteCount ?? 0) / total : null,
              onTap: () => _tap(option),
            ),
          if (notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
              child: Text(notes.join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
          if (!poll.showsResults && !poll.hasEnded)
            Text(poll.hasVoted ? l10n.pollResultsWhenClosed : l10n.pollResultsAfterVoting,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          Wrap(
            spacing: DesignTokens.spacingS,
            children: [
              if (_collects && !poll.hasVoted && _canVote)
                FilledButton(onPressed: _chosen.isEmpty ? null : () => _send(_chosen), child: Text(l10n.pollVote)),
              if (poll.hasVoted && poll.canChangeVote && _canVote)
                TextButton(onPressed: () => _send({}), child: Text(l10n.pollRemoveVote)),
              if (poll.canSeeVoters)
                TextButton(onPressed: () => _PollVotersSheet.show(context, widget.site, poll), child: Text(l10n.pollSeeVoters)),
            ],
          ),
          if (_sending) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.chosen,
    required this.multiple,
    required this.selectable,
    required this.share,
    required this.onTap,
  });

  final FlarumPollOption option;
  final bool chosen;
  final bool multiple;
  final bool selectable;

  /// Its part of the votes, 0 to 1, when the results show.
  final double? share;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = multiple
        ? (chosen ? Icons.check_box : Icons.check_box_outline_blank)
        : (chosen ? Icons.radio_button_checked : Icons.radio_button_unchecked);
    final share = this.share;
    return Semantics(
      selected: chosen,
      button: selectable,
      child: InkWell(
        onTap: selectable ? onTap : null,
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
          child: Stack(
            children: [
              if (share != null)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: share.clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: (chosen ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingS),
                child: Row(
                  children: [
                    if (selectable || chosen) ...[
                      Icon(icon, size: 20, color: chosen ? colorScheme.primary : colorScheme.onSurfaceVariant),
                      const SizedBox(width: DesignTokens.spacingS),
                    ],
                    Expanded(child: Text(option.answer, style: theme.textTheme.bodyMedium)),
                    if (share != null)
                      Text(NumberFormat.percentPattern(Localizations.localeOf(context).toString()).format(share),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Who voted for what, in a public poll.
class _PollVotersSheet extends StatelessWidget {
  const _PollVotersSheet({required this.poll, required this.votes});

  final FlarumPoll poll;
  final Future<List<FlarumPollVote>> votes;

  static Future<void> show(BuildContext context, SiteContext site, FlarumPoll poll) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _PollVotersSheet(poll: poll, votes: FlarumForum.of(site).api.pollVotes(poll.id)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, controller) => FutureBuilder<List<FlarumPollVote>>(
        future: votes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: DesignTokens.paddingL,
                child: Text(describeError(context, snapshot.error), textAlign: TextAlign.center),
              ),
            );
          }
          final votes = snapshot.data;
          if (votes == null) return const Center(child: CircularProgressIndicator());
          if (votes.isEmpty) return Center(child: Text(l10n.pollNoVotes));
          return ListView(
            controller: controller,
            children: [
              for (final option in poll.options) ...[
                if (votes.any((v) => v.optionId == option.id))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        DesignTokens.spacingL, DesignTokens.spacingM, DesignTokens.spacingL, DesignTokens.spacingXS),
                    child: Text(option.answer, style: theme.textTheme.titleSmall),
                  ),
                for (final vote in votes.where((v) => v.optionId == option.id))
                  ListTile(
                    dense: true,
                    leading: FlarumAvatar(user: vote.user, radius: 16),
                    title: Text(vote.user?.displayName ?? l10n.someone),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
