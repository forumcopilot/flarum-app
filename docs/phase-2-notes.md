# Phase 2 notes

Phase 2 is the read path: flarum_core on the SDK, then flarum_ui. Plan §9; Phase 0 findings in
`phase-0-notes.md`, SDK coverage in `sdk-coverage.md`.

## flarum_core proxies

Built, with fixture tests on 1.8 and 2.0: config, forum (tags as the forum tree), topic, post,
user (web-view sign-in, sign-out), social (notifications as alerts, own posts as activity), search
(discussions by relevance with an excerpt; posts on 2.0, best post per discussion on 1.8),
subscription (read side) and tag. Writes (reply, like, follow…) are Phase 3 and answer
"Not available yet".

## Post renderer

`flarum_ui`'s `FlarumContent` renders `contentHtml`. All six Phase 0 findings are handled:

| Flarum markup | Handling |
| --- | --- |
| `script` in every code block | Removed by `FlarumHtml` |
| `a.UserMention`, `a.PostMention` | Mention pills; a post mention has a reply glyph (2.0's FA icon removed). User mentions go to `onMentionTap`, post mentions to `onUrlTap` |
| Task lists | Check boxes; a list of tasks becomes `div`s, since flutter_html ignores `list-style-type: none` |
| 2.0 upload previews | The anchor becomes a lightbox: the viewer gets the full size |
| fof/upload files | A file card on `GET /api/fof/download/{uuid}`, with the reader's token (only to that path on the forum) |
| `details.spoiler` with no summary | Labelled "Spoiler"; inline `span.spoiler` blurred until tapped |

Also: s9e media embeds (YouTube and the rest) are unwrapped to their iframe, which the renderer
draws as a preview card; the wrappers' percentage padding collapsed it to nothing.

Compared with the web on both test forums (14 samples each, `tool/render_compare/compare.mjs`,
412 px wide): the same content, structure and order everywhere. Differences left on purpose or
outside the renderer:

- Headings use the app's type scale (24/22/20…), smaller than the web's.
- Tables draw row rules; the web's default theme draws none.
- A picture the forum can't load (a 404) shows nothing; the web shows its alt text.
- Emoji are text in Flarum's HTML; the screenshot harness has no emoji font, a device has.
- Shortcodes such as `:smile:` stay text, as on the web (it converts them while typing).

The screenshot harness (`test/render/screenshots_test.dart`, tag `render`) precaches pictures in a
real zone: in a widget test's fake-async zone an HTTPS picture never arrives.

Still for a device: real fonts and scrolling, video playback, the download-and-share flow.
