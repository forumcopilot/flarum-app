import 'package:flarum_core/flarum_core.dart';
import 'package:flutter/material.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';
import 'package:forum_kit/theme/design_tokens.dart';
import 'package:forum_kit/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/flarum_l10n.dart';
import '../tags/tag_label.dart';
import 'compose_page.dart';
import 'flarum_markup.dart';
import 'tag_picker_page.dart';

/// Opens the composer for a reply in [discussion], starting from [initialContent] (a quote, a
/// reply to a post). The reply once posted, or null.
Future<FlarumPost?> composeReply(BuildContext context, SiteContext site, FlarumDiscussion discussion,
    {String? initialContent}) {
  final forum = FlarumForum.of(site);
  return Navigator.of(context).push(MaterialPageRoute<FlarumPost>(
    fullscreenDialog: true,
    builder: (context) => ComposePage(
      site: site,
      title: kitL10n(context).reply,
      topicTitle: discussion.title,
      initialContent: initialContent,
      onSubmit: (_, content) => forum.api.reply(discussion.id, content),
    ),
  ));
}

/// Opens the composer on [post]'s source, to edit it. The post as saved, or null. Flarum sends
/// the source only to readers who may edit, so a post read without it is fetched again.
Future<FlarumPost?> composeEdit(BuildContext context, SiteContext site, FlarumPost post) async {
  final forum = FlarumForum.of(site);
  var source = post.source;
  if (source == null) {
    try {
      source = (await forum.api.post(post.id)).source;
    } catch (_) {
      source = null;
    }
    if (!context.mounted) return null;
    if (source == null) {
      SnackbarHelper.showError(context, flarumL10n(context).editLoadFailed);
      return null;
    }
  }
  return Navigator.of(context).push(MaterialPageRoute<FlarumPost>(
    fullscreenDialog: true,
    builder: (context) => ComposePage(
      site: site,
      title: flarumL10n(context).editPost,
      initialContent: source,
      isEdit: true,
      onSubmit: (_, content) => forum.api.editPost(post.id, content),
    ),
  ));
}

/// Opens the composer for a new discussion, in [tag] when given. The discussion once started,
/// or null.
Future<FlarumDiscussion?> composeDiscussion(BuildContext context, SiteContext site, {FlarumTag? tag}) =>
    Navigator.of(context).push(MaterialPageRoute<FlarumDiscussion>(
      fullscreenDialog: true,
      builder: (_) => _NewDiscussionPage(site: site, tag: tag),
    ));

/// A reply to [post], as the web's Reply button on a post starts one.
String replyTo(FlarumPost post, FlarumLocalizations l10n) =>
    '${FlarumMarkup.postMention(post.author?.displayName ?? l10n.someone, post.id)} ';

/// A quote of [post], as the web's Quote button writes it: from its source when the reader has
/// it, else its words, leaving out what it quotes itself.
String quoteOf(FlarumPost post, FlarumLocalizations l10n) {
  final text = post.source ??
      plainText((post.contentHtml ?? '').replaceAll(RegExp(r'<blockquote[\s\S]*?</blockquote>', caseSensitive: false), ''));
  return FlarumMarkup.quote(post.author?.displayName ?? l10n.someone, post.id, text);
}

/// The new-discussion composer: the title, the text, and the tags the forum's rules ask for.
class _NewDiscussionPage extends StatefulWidget {
  const _NewDiscussionPage({required this.site, this.tag});

  final SiteContext site;
  final FlarumTag? tag;

  @override
  State<_NewDiscussionPage> createState() => _NewDiscussionPageState();
}

class _NewDiscussionPageState extends State<_NewDiscussionPage> {
  late final FlarumForum _forum = FlarumForum.of(widget.site);
  List<FlarumTag>? _tags;
  late List<FlarumTag> _chosen = [
    if (widget.tag case final tag?) tag,
  ];

  /// Without flarum/tags the forum has no tags to choose.
  bool get _usesTags => _forum.info?.tagRules != null;

  @override
  void initState() {
    super.initState();
    if (_usesTags) {
      _forum.tags().then((tags) {
        if (!mounted) return;
        setState(() {
          _tags = tags;
          // A child tag goes with its parent.
          final parent = widget.tag?.parentId;
          if (parent != null) _chosen = [...tags.where((t) => t.id == parent), ..._chosen];
        });
      }, onError: (_) {});
    }
  }

  Future<void> _chooseTags() async {
    final tags = _tags;
    if (tags == null) return;
    final chosen = await TagPickerPage.open(context, tags: tags, rules: _forum.info?.tagRules, selected: _chosen);
    if (chosen != null && mounted) setState(() => _chosen = chosen);
  }

  Future<FlarumDiscussion> _start(String title, String content) async {
    final problem = _usesTags ? tagRuleProblem(_chosen, _forum.info?.tagRules, flarumL10n(context)) : null;
    if (problem != null) throw ComposeProblem(problem);
    return _forum.api.startDiscussion(title, content, tagIds: [for (final tag in _chosen) tag.id]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return ComposePage(
      site: widget.site,
      title: l10n.startDiscussion,
      showTitleField: true,
      header: _usesTags
          ? Wrap(
              spacing: DesignTokens.spacingS,
              runSpacing: DesignTokens.spacingXS,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final tag in tagsInWebOrder(_chosen)) TagLabel(tag: tag),
                ActionChip(
                  avatar: const Icon(Icons.sell_outlined, size: 18),
                  label: Text(l10n.chooseTags),
                  onPressed: _tags == null ? null : _chooseTags,
                ),
              ],
            )
          : null,
      onSubmit: _start,
    );
  }
}
