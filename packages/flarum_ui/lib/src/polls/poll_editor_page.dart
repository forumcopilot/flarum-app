import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/views/widgets/discard_changes_scope.dart';
import 'package:intl/intl.dart';

import '../../l10n/flarum_l10n.dart';

/// The poll to start a discussion with (fof/polls), as the web's poll form asks for it: the
/// question, two answers or more (up to the forum's [maxOptions]), whether several may be chosen,
/// whether votes are public or may be changed, and when voting closes. Done hands it back.
class PollEditorPage extends StatefulWidget {
  const PollEditorPage({super.key, required this.maxOptions, this.poll, this.limitsChoices = true});

  /// The most answers the forum takes.
  final int maxOptions;

  /// The poll being changed, if any.
  final FlarumNewPoll? poll;

  /// Whether the forum keeps how many choices a voter may make (2.0; 1.x always allows any number).
  final bool limitsChoices;

  static Future<FlarumNewPoll?> open(BuildContext context,
          {required int maxOptions, FlarumNewPoll? poll, bool limitsChoices = true}) =>
      Navigator.of(context).push(MaterialPageRoute<FlarumNewPoll>(
        fullscreenDialog: true,
        builder: (_) => PollEditorPage(maxOptions: maxOptions, poll: poll, limitsChoices: limitsChoices),
      ));

  @override
  State<PollEditorPage> createState() => _PollEditorPageState();
}

class _PollEditorPageState extends State<PollEditorPage> {
  late final _question = _field(widget.poll?.question ?? '');
  late final List<TextEditingController> _answers = [
    for (final answer in widget.poll?.options ?? const ['', '']) _field(answer),
  ];
  late bool _multiple = widget.poll?.allowMultipleVotes ?? false;
  late int _maxVotes = widget.poll?.maxVotes ?? 0;
  late bool _public = widget.poll?.publicPoll ?? false;
  late bool _changeVote = widget.poll?.allowChangeVote ?? false;
  late bool _hideVotes = widget.poll?.hideVotes ?? false;
  late DateTime? _endDate = widget.poll?.endDate;
  String? _problem;

  /// Bumped by every edit, for the close prompt to follow ([DiscardChangesScope]).
  final _edits = ValueNotifier(0);

  /// The form as it opened, to tell whether closing would lose an edit.
  late final String _opened;

  @override
  void initState() {
    super.initState();
    _opened = _snapshot();
  }

  String _snapshot() => [
        _question.text,
        for (final answer in _answers) answer.text,
        _multiple,
        _maxVotes,
        _public,
        _changeVote,
        _hideVotes,
        _endDate,
      ].join('\u0000');

  /// A change the reader made: rebuilt, and counted as an edit.
  void _edit(VoidCallback change) {
    setState(change);
    _edits.value++;
  }

  /// A field whose editing clears what Done found wrong: the reader is putting it right. Only a
  /// change of text: a tap into the field moves the cursor, which notifies too, and the message
  /// leaving then would move the fields under the finger.
  TextEditingController _field(String text) {
    final controller = TextEditingController(text: text);
    var last = text;
    controller.addListener(() {
      if (controller.text == last) return;
      last = controller.text;
      _edits.value++;
      if (_problem != null && mounted) setState(() => _problem = null);
    });
    return controller;
  }

  @override
  void dispose() {
    _edits.dispose();
    _question.dispose();
    for (final answer in _answers) {
      answer.dispose();
    }
    super.dispose();
  }

  List<String> get _filled => [
        for (final answer in _answers)
          if (answer.text.trim().isNotEmpty) answer.text.trim(),
      ];

  Future<void> _chooseEnd() async {
    final now = DateTime.now();
    final initial = _endDate ?? now.add(const Duration(days: 7));
    final day = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      // fof/polls takes dates before 2038.
      lastDate: DateTime(2037, 12, 31),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null || !mounted) return;
    _edit(() => _endDate = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  void _done() {
    final l10n = flarumL10n(context);
    final question = _question.text.trim();
    final answers = _filled;
    final problem = question.isEmpty
        ? l10n.pollNeedsQuestion
        : answers.length < 2
            ? l10n.pollNeedsAnswers
            : _endDate != null && !_endDate!.isAfter(DateTime.now())
                ? l10n.pollEndInPast
                : null;
    if (problem != null) {
      setState(() => _problem = problem);
      return;
    }
    Navigator.of(context).pop(FlarumNewPoll(
      question: question,
      options: answers,
      allowMultipleVotes: _multiple,
      maxVotes: _multiple ? _maxVotes : 0,
      publicPoll: _public,
      allowChangeVote: _changeVote,
      hideVotes: _hideVotes && _endDate != null,
      endDate: _endDate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final answerCount = _answers.length;
    return DiscardChangesScope(
      listenable: _edits,
      hasChanges: () => _snapshot() != _opened,
      isEdit: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.poll),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
              child: FilledButton(onPressed: _done, child: Text(l10n.submit)),
            ),
          ],
        ),
        body: ListView(
          padding: DesignTokens.paddingL,
          children: [
            if (_problem case final problem?)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
                child: Text(problem, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
              ),
            TextField(
              controller: _question,
              autofocus: widget.poll == null,
              maxLength: 255,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.pollQuestion),
            ),
            const SizedBox(height: DesignTokens.spacingS),
            for (final (i, answer) in _answers.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
                child: TextField(
                  controller: answer,
                  maxLength: 255,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.pollAnswer(i + 1),
                    counterText: '',
                    suffixIcon: answerCount > 2
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: l10n.pollRemoveAnswer,
                            onPressed: () => _edit(() => _answers.removeAt(i).dispose()),
                          )
                        : null,
                  ),
                ),
              ),
            if (answerCount < widget.maxOptions)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _edit(() => _answers.add(_field(''))),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.pollAddAnswer),
                ),
              ),
            const Divider(height: DesignTokens.spacingXL),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pollMultipleChoice),
              value: _multiple,
              onChanged: (value) => _edit(() => _multiple = value),
            ),
            if (_multiple && widget.limitsChoices)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.pollChoicesAllowed),
                trailing: DropdownButton<int>(
                  value: _maxVotes > answerCount ? 0 : _maxVotes,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(l10n.pollAnyNumber)),
                    for (var n = 2; n < answerCount; n++) DropdownMenuItem(value: n, child: Text('$n')),
                  ],
                  onChanged: (value) => _edit(() => _maxVotes = value ?? 0),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pollPublic),
              value: _public,
              onChanged: (value) => _edit(() => _public = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pollAllowChangeVote),
              value: _changeVote,
              onChanged: (value) => _edit(() => _changeVote = value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pollCloses),
              subtitle: Text(_endDate == null ? l10n.pollNeverCloses : DateFormat.yMMMd(locale).add_jm().format(_endDate!)),
              onTap: _chooseEnd,
              trailing: _endDate == null
                  ? const Icon(Icons.event_outlined)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.pollNeverCloses,
                      onPressed: () => _edit(() => _endDate = null),
                    ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pollHideVotes),
              subtitle: _endDate == null ? Text(l10n.pollHideVotesNeedsEnd) : null,
              value: _hideVotes && _endDate != null,
              onChanged: _endDate == null ? null : (value) => _edit(() => _hideVotes = value),
            ),
          ],
        ),
      ),
    );
  }
}
