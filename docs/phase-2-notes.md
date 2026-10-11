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

## Thread page

`ThreadPage` (flarum_ui) shows a discussion's posts with `PostTile`: avatar, name and time, the
body through `FlarumContent`, likes and replies counts; event posts (renamed, locked, stickied,
tagged) as one-line notices. `ThreadModel` holds a window of posts: `FlarumApi.discussion(withPostIds)`
gives every post's place (1.x lists the ids only with `include=posts`, which 2.0 refuses), so a
thread opens at a post with `page[near]` and pages both ways by offset. Reading is reported once it
pauses, only forward, and only for a signed-in reader. Links to the forum's discussions open in the
app (the same discussion scrolls to the post); users and tags go to the host's callbacks, the web
until those screens exist. Pictures open in a full-screen gallery.

fof/best-answer, read side: the discussion's `hasBestAnswer` attribute is the answer's post id (or
`false`) on both versions, so no include is needed. Lists mark answered discussions with a check;
the answer carries a "Best answer" label, and the question a "Go to best answer" button (it scrolls
there, or opens the thread at the answer's number from `GET /api/posts/{id}`). The SDK's
`FCPost.isSolution` is set the same way. Choosing an answer is Phase 3.

Tests run on both versions' fixtures through `package:flarum_core/testing.dart` (`FixtureForum`,
with `root` pointing at flarum_core's fixtures); the screenshot harness also renders the page.

## Real forums (census check)

`packages/flarum_ui/test/census/census_test.dart` (tag `census`, skipped by default) reads 20 active,
guest-readable forums from the plan's census, plus discuss.flarum.org: 12 on 1.x and 9 on 2.0, in
13 languages (Arabic and Chinese among them), two installed in a subfolder. For each: the forum's
info and version, 10 discussions, the tags, one thread with its post ids, and its first 20 posts
rendered with `PostTile`. A few GET requests per forum, as a guest, with the app's User-Agent.

First run (9 October 2026): all 21 answered, parsed and were detected as the right version; 172
posts rendered with no error. The phones still have to confirm what this can't: real fonts,
scrolling, and the web-view sign-in.

## SDK conformance

`packages/flarum_core/test/conformance_test.dart` (tag `live`) runs the SDK's shared proxy suites
(forumcopilot_sdk `lib/test`) against a test forum, signed in as carol, for the proxies Flarum
implements. They expect `result: true` from every method, so Phase 3's methods fail by design;
the summary is the report.

9 October 2026, both versions: 36 of 59 pass. The 18 that don't, all expected:

- Writes, Phase 3: `newTopic`, `replyPostAsync`, `reportPostAsync`, `getRawPostAsync` and
  `saveRawPostAsync` (editing), `ignoreUserAsync`/`getIgnoredUsersAsync` (fof/ignore-users), and
  following discussions and tags (`subscribe`/`unsubscribe…`).
- Private messages, Phase 3: `getInboxStatAsync`.
- Not on Flarum: `loginForum` (no password-protected tags), `getBoardStatAsync` (admin-only),
  `loginTwoStepAsync`, `getOnlineUsersAsync`, `getRecommendedUsersAsync`.
- The test data: `getAvatarAsync` (the seed users have no avatar).

11 October 2026, both versions: 42 of 60 pass, the tag proxy's suite now included; the 18 that
don't are the same ones.

It found one real bug, now fixed: "mark all read" sent `markedAllAsReadAt: true`, which 1.8 takes
and 2.0 refuses (422); it now sends the time.

## Phone run (11 October 2026)

On a Pixel 4a (Android 13, WebView 153), debug builds of `8fc0378`, over home Wi-Fi; the iPhone
wasn't set up for signing yet. Passed on both test forums and six census forums (discuss.flarum.org,
the Arabic foro.arsoporte.com, Flarum 2x, discuss.flarum.org.cn, mondedie.fr, linuxmint.com.ua):
web-view sign-in (1.8 with Turnstile, 2.0), session restore and sign-out, Following, notifications,
home, tags, the long thread (opens at post 21, keeps its place loading earlier posts), profiles,
search, the formatting samples beside Chrome, light, dark and the forums' colours. Cloudflare didn't
challenge the app or its web view.

Fixed after it:

- The debug forum switcher left Home and Account on the previous forum: `runApp` reused the element
  tree. `FlarumApp` keys its `MaterialApp` by the forum.
- Profiles failed on forums with the ID slug driver (Flarum 2x): users are found by slug
  (`FlarumApi.userBySlug`, `/u/{slug}`, the author's `slug`), and their lists filtered by the
  username the forum returns.
- Right-to-left posts had their list bullets on the left: a post is laid out in its own direction,
  from most of its letters (code stays left to right), and list indents are on the marker's side.
- File cards offered Download where members lack fof/upload's download permission, then failed
  with 403: the card shows a lock and "Permission required" (`fof-upload.canDownload`), as 2.0's
  web does.
- Smaller: the badge reloads once a notification is read; byobu's recipients event has its own
  line; tag mentions (2.0) are chips in the tag's colour; nested bullets are hollow, then square;
  letter avatars take Flarum's colour from the display name (`stringToColor`).
- The benchmark measures one fixed thread (26838 on discuss.flarum.org): the second discussion in
  Latest varied with its pictures (5 against 29 slow frames between two runs).

Left as they are: a block spoiler is labelled "Spoiler" (the web's "Details" is Chrome's default
label for a `<details>` without a summary); a video shows a play card, not its first frame; long
code lines scroll sideways, as on the web. The badge can also overcount for up to five minutes
after a like is withdrawn: Flarum caches the count and doesn't clear it when a notification is
deleted (the web's badge shows the same).

Scroll benchmark, profile mode, the Pixel 4a, discuss.flarum.org (two runs): the home list at
0.5–0.6 ms build p50, 4.9 ms raster p50, 0–1 frames over 16.7 ms; the thread at 0.7 ms build p50,
3.0 ms raster p50.

