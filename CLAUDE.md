# CLAUDE.md

Guidance for Claude Code sessions working in this repository.

## Project

flarum-app is a Flutter client for Flarum forums, the Flarum counterpart of discourse-app. The plan
(phases, decisions, scope) is the "Flarum App Plan": https://claude.ai/artifact/W61kE9VGWeUbHWxMycWedL.
Current phase: **2** (flarum_core on the SDK, flarum_ui). Phase 0 findings: docs/phase-0-notes.md.

UI building blocks come from `forum_kit` (theme, shared widgets, caches, emoji, its own strings),
which lives in discourse-app's `packages/forum_kit` and is shared with it. Only generic code goes
there. The post renderer, composer and screens are flarum-app's own: copy them from discourse_ui
and adapt them in `flarum_ui`, rather than sharing them through hooks (decided 9 Oct 2026;
docs/phase-1-notes.md).

Flarum 1.8 and 2.0 are both fully supported. Design for 2.0 and keep 1.x differences in clearly
marked places so 1.x can be dropped later. The app needs no plugin on the forum.

## Rules (from the plan, set by Tung)

- Get explicit approval before creating repos, deploying, uploading to stores or publishing.
- Pushing to this repo needs no approval (decided 8 Oct 2026). Push when work is tested; CI must stay green.
- `git add` with explicit paths only. Never commit credentials or a config pointing at a local forum.
- SDK interface and model changes go into the canonical forumcopilot_sdk first, not a local copy.

## Commands

```bash
flutter pub get && flutter analyze && flutter test          # the app (lib/main.dart, test/)
cd packages/flarum_core && flutter pub get && flutter analyze && flutter test
cd packages/flarum_ui && flutter pub get && flutter analyze && flutter test
```

The root is the app: a thin `lib/main.dart` over flarum_ui's `FlarumApp`. The forum is
`AppForumConfig` (flarum_ui `lib/config/`), chosen at build time; point a build at a test forum
with `--dart-define=FLARUM_URL=…` rather than editing it. Phone testing: `docs/device-testing.md`.

Each package needs `pubspec_overrides.yaml` (copy the `.example`) to build against the local
discourse-app checkout; without it, forum_kit and the SDK come from the pinned commit. CI has no
overrides, and the analyzer can report things against the pinned commit that it doesn't with the
override (an unused import did once): before pushing a change to imports, analyze once with the
override moved aside.

flarum_core's tests replay fixtures recorded from both versions (`test/fixtures/v1`, `v2`); every
API test runs against both. `FixtureForum` lives in `package:flarum_core/testing.dart`, so flarum_ui's
tests replay the same fixtures (`root: '../flarum_core/test/fixtures'`). Live tests and re-recording: `test/live_test.dart`,
`tool/test_forums/README.md`.

flarum_ui's post renderer is `FlarumContent` (copied from discourse_ui's RichTextContent) on HTML
prepared by `FlarumHtml`, which rewrites Flarum's own markup (code-block scripts, task lists,
fof/upload files and previews, s9e embeds, mention icons) into shapes the renderer draws. Its strings
are `FlarumLocalizations` (`flarumL10n(context)`; ARBs in `lib/l10n`, then `flutter gen-l10n`).
To compare its output with the web: `tool/render_compare/compare.mjs` (screenshots both sides at a
Pixel's width into `packages/flarum_ui/build/render/`).
`test/census/census_test.dart` (tag `census`) reads 20 real forums from the plan's census as a
guest and renders their posts: run it after changes to the API or the renderer.

## Flarum API facts the client depends on

Checked against 1.8.20 and 2.0.0-rc.8:

- Version: only 2.0's `GET /api` forum attributes include `colorScheme` and `jsChunksBaseUrl`.
- Auth: `Authorization: Token <token>`; it skips CSRF. Sign-in is the web view (the forum's page,
  "Remember me" ticked, the HttpOnly `<prefix>_remember` cookie read from the native store).
  `POST /api/token` works on 1.x even with blomstra/turnstile or fof/recaptcha (they guard only
  the website's `/login`), but the 2.0 Turnstile fork blocks it with a 422 on `turnstileToken`.
- 2.0 rejects unknown query parameters with HTTP 400; 1.x ignores them. Send only known ones.
  Unknown `filter[...]` keys are silently ignored on both.
- Search: 1.x takes conditions as gambits inside `filter[q]` (`tag:`, `is:following`, `is:unread`,
  `is:private`) and ignores other `filter[...]` keys once `q` is present; 2.0 takes separate keys
  and treats gambits in `q` as words. 1.x `/api/posts` ignores `filter[q]` (no post search).
  With no `sort`, results come by relevance; `include=mostRelevantPost,mostRelevantPost.user`
  brings the best post (1.x refuses `mostRelevantPost.discussion` with 400). 2.0 gives
  `meta.page.total`, 1.x no total. 2.0's post search takes `filter[tag]` as an id only (422 on a
  slug). One excluded tag per request: `filter[-tag]=a,b` excludes neither on 2.0.
  Method-by-method SDK coverage: `docs/sdk-coverage.md`.
- Paging: `page[offset]` and `page[limit]`, capped at 50. Never follow `links.next`: on 2.0 it
  drops the `/api` prefix. Posts: `/api/posts?filter[discussion]=…` on both versions.
- `page[near]` can't be combined with `sort` on 1.x; 1.x places the post by `created_at`, so the
  page contains it but not necessarily centred.
- Attribute types vary: 2.0 sends some booleans as `"1"`/`""`; tag limits are strings on both.
  Read attributes through `FlarumAttributes`.
- Validation (422): 1.x reports the first failed rule, 2.0 every invalid field.
- Mark all read: `PATCH /api/users/{id}` with `markedAllAsReadAt` as a date; 2.0 refuses `true` (422),
  1.x records the current time whatever the value.
- Stickied discussions are pinned to the top only when the list request sends no `sort` (the
  forum's default order, latest activity); with a tag filter, that tag's stickies. The web's Latest
  view sends none, so `DiscussionSort.latest` sends none either.
- 2.0 rc.8: a `PATCH /api/discussions/{id}` with only `relationships` (tags, `bestAnswerPost`) fails
  with 500 in flarum/subscriptions; send `"attributes": {}` with it. Best answer: 1.x
  `attributes.bestAnswerPostId`, 2.0 `relationships.bestAnswerPost`, in a tag with Q&A on.
- Listing `/api/notifications` resets the reader's "new" badge on the website.
- Notifications: include `subject.discussion`, or a post subject arrives without its discussion on
  1.x. Discussion-subject types carry the post to open in `content.postNumber`; `postMentioned`'s
  subject is the reader's own post, and the reply that mentions it is `content.replyNumber`.
  `POST /api/notifications/read` marks all read (204).
- byobu private discussions are invisible to admins who aren't recipients.
- Following: a discussion's `subscription` is `follow`, `ignore` or null (an ignored one leaves the
  reader's lists). fof/follow-tags puts `lurk`, `follow`, `ignore` or `hide` on each tag; 1.x sets it
  with `POST /api/tags/{id}/subscription {"data":{"subscription":…}}`, 2.0 by PATCHing the attribute.
- Sign-out (`FlarumApi.logOut`): Flarum has no "revoke this token" call, and `/api/access-tokens`
  never marks a header token `isCurrent` (2.0 rc.8 even fails with 500 listing for one). Listing
  with the token sent as the `<prefix>_remember` cookie marks it current; then
  `DELETE /api/access-tokens/{id}` with the header. The list is paged oldest first (20 by
  default), so a reader with many sessions has the current token on a later page. The prefix
  (`cookie.name`, default `flarum`) shows in any response's `<prefix>_session` Set-Cookie.
