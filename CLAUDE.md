# CLAUDE.md

Guidance for Claude Code sessions working in this repository.

## Project

flarum-app is a Flutter client for Flarum forums, the Flarum counterpart of discourse-app. The plan
(phases, decisions, scope) is the "Flarum App Plan": https://claude.ai/artifact/W61kE9VGWeUbHWxMycWedL.
Current phase: **4** (Flapp, the multi-forum app, which hosts flarum_ui as ABDA hosts discourse_ui),
on branch `phase-4`; Phase 3 (the write path; plan: the "flarum-app Phase 3 Plan" doc,
https://claude.ai/code/artifact/8995648c-50ff-42a2-ab6d-41388a98cbce) is on `phase-3`, its exit run
still to do, and Phase 2 on `phase-2`. Notes: docs/phase-0-notes.md, docs/phase-2-notes.md,
docs/phase-3-notes.md, docs/phase-4-notes.md. What still needs a real iPhone, to run together at the
end: docs/iphone-tests.md.

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

A multi-forum app (Flapp) hosts flarum_ui through `FlarumHost` (start-up, localizations),
`FlarumForumPage` (one forum, pushed over the host's screens) and `FlarumForumTheme` (the open
forum's colours, which the host's `MaterialApp` follows); `FlarumApp` uses the same pieces for its
one forum. Keep per-forum state keyed by the forum's address, never global: a host has several
forums in one run (docs/phase-4-notes.md).

Each package needs `pubspec_overrides.yaml` (copy the `.example`) to build against the local
discourse-app checkout; without it, forum_kit and the SDK come from the pinned commit. CI has no
overrides, and the analyzer can report things against the pinned commit that it doesn't with the
override (an unused import did once): before pushing a change to imports, analyze once with the
override moved aside.

flarum_core's tests replay fixtures recorded from both versions (`test/fixtures/v1`, `v2`); every
API test runs against both. Fixtures recorded with a `state` (such as `ignoring`) are served only to
a `FixtureForum(states: {...})`, in place of the same request's plain fixture. `FixtureForum` lives in `package:flarum_core/testing.dart`, so flarum_ui's
tests replay the same fixtures (`root: '../flarum_core/test/fixtures'`). Live tests and re-recording: `test/live_test.dart`,
`tool/test_forums/README.md`.

The test forums are public at https://flarum18.betterdiscourse.app and https://flarum20.betterdiscourse.app
(phones use these), behind Cloudflare, which challenges the dev server's own network: tools on the
server use 127.0.0.1:8081 and 8082.

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
- byobu private discussions are invisible to admins who aren't recipients (the write recorder
  deletes its own with `tool/test_forums/delete_discussions.php`). One is started with
  `relationships.recipientUsers` and no tags; members may have one other person in it and may not
  change who's in it. Listing: 1.x only the `is:private` gambit, 2.0 `filter[private]`.
- Moderation: PATCH a discussion's `title`, `isLocked`, `isSticky`, `isHidden`, a post's `isHidden` or
  `isApproved` (flarum/approval), a user's `suspendedUntil`/`suspendReason`/`suspendMessage`
  (flarum/suspend; the web's "indefinitely" is 2038-01-01). 2.0 rc.8 sends `isHidden` as null on a
  hidden post or discussion: read `hiddenAt` too.
- flarum/messages (2.0): `/api/dialogs` and `/api/dialog-messages` (newest first); a first message
  carries `attributes.users` (and lands in the direct dialog the two already have, if any), later
  ones `relationships.dialog`; read with `PATCH /api/dialogs/{id}` `lastReadMessageId`. Dialogs
  can't be filtered by person (only `unread`): `FlarumApi.dialogWith` reads the list. A new
  message notifies with `messageReceived` (subject a `dialog-messages` resource, its dialog as
  linkage) by email only: its blueprint isn't `AlertableInterface`, so 2.0's alert driver registers
  no alert preference for it (the website greys the column out) and it never reaches the
  notification list. New messages show as the actor's `messageCount` (the app's badges); the app
  still opens a `messageReceived` notification's conversation, should a forum make it alertable. Dialogs can't be deleted through the API (the
  recorder uses `tool/test_forums/delete_dialogs.php`).
- Writing: `POST /api/posts` and `POST /api/discussions` answer 201, `PATCH /api/posts/{id}` 200. A post's
  source (`content`) comes only to readers who may edit it, so a quote of someone else's post is made
  from its HTML. A second post within the posting throttle (10 s by default) is 429 `too_many_requests`,
  checked before validation. Editing someone else's post: 1.x 403 `permission_denied`, 2.0 403
  `validation_error` ("Field [content] is not writable"). Flarum stops a member editing a post once
  someone has replied after it (the default `allow_post_editing`).
- Actions: like = PATCH the post's `isLiked`; a reaction = its `reaction` (an id; the same id again
  takes it back; 1.x fails with 500 on null); bookmark = `bookmarked` on the post or discussion;
  follow = the discussion's `subscription`. Best answer: 1.x the discussion's `bestAnswerPostId` (0
  for none), 2.0 `relationships.bestAnswerPost` with empty attributes. Who liked a post comes only
  with the `likes` include (up to 4, the reader first). 1.x lists bookmarked discussions only by the
  `is:bookmarked` gambit.
- Users are found by slug (`GET /api/users/{slug}?bySlug=true`, as `/u/{slug}` links name them):
  the username by default, the id on forums with the ID slug driver, where a username 404s. Their
  posts and discussions: `filter[author]` (and 1.x's `author:` gambit) takes the username on 1.x
  but resolves a slug on 2.0 (`FlarumApi.authorKey`).
- Includes from an extension the forum doesn't run (flarum/tags' `tags`, flarum/mentions'
  `mentionedBy…`) make the whole request fail with 400 invalid_parameter; `FlarumApi` retries
  without them. Without flarum/tags, `/api/tags` is a 404.
- fof/upload: `fof-upload.canDownload` (forum attribute) is the reader's download permission;
  without it `/api/fof/download/…` answers 403. Members don't have it by default.
  `fof-upload.canUpload` is the upload permission. `POST /api/fof/upload` (multipart `files[]`)
  answers with each file's `bbcode`; 1.x leaves an image's alt as `{TEXT?}`. Only moderators may
  delete uploads by default (`canDelete`). The size limit isn't published: refusals name it (a 422
  or 400 saying "… 2048 kb"), or are a 413 from PHP or nginx (docs/phase-3-notes.md, Milestone 3).
  It re-encodes the images it stores (JPEG at quality 90), so a stored copy can be bigger than the
  file sent.
- fof/polls: a poll belongs to a post (a new discussion's is its first post's); a thread's posts
  bring theirs only when the request names `polls,polls.options,polls.myVotes,polls.myVotes.option`
  (fof/polls' defaults apply only to a request naming no includes). Routes: 1.x `/api/fof/polls`,
  2.0 `/api/polls`; voting is `PATCH …/{id}/votes` `{"data":{"optionIds":[…]}}`, the whole choice
  (`[]` takes it back; a repeated id is counted twice). A new discussion's poll is its `poll`
  attribute. `voteCount` is absent (2.0) or null (1.x) while the reader may not see the results.
  1.x stores `maxVotes` as 0 whatever is sent.
- fof/drafts: `GET/POST /api/drafts`, `PATCH`/`DELETE /api/drafts/{id}`. What a draft is for
  (discussion, tags, recipientUsers) is JSON:API's `relationships` on 1.x but an attribute named
  `relationships` on 2.0 (required on create). 2.0 pages and sorts (`-updatedAt`), 1.x sends all,
  unsorted. Nothing on the forum deletes a posted draft: the client does.
- A forum without an extension refuses its includes with 400 and names none (1.x) or only the first
  (2.0): `FlarumApi` tries each extension's includes alone, once per forum.
- Reports (flarum/flags): `POST /api/flags` with `reason` (`off_topic`, `inappropriate`, `spam`, or
  null for "Other") and always `reasonDetail` (1.x takes neither as no reason at all). Ignoring
  (fof/ignore-users): `PATCH /api/users/{id}` with `ignored`; users carry `ignored` and
  `canBeIgnored`, and `GET /api` includes `actor.ignoredUsers`. fof/terms gives a member with a
  policy to accept a guest's permissions; accepting is `POST /api/fof/terms/policies/{id}/accept`
  (1.x) or `/api/fof-terms-policies/{id}/accept` (2.0).
- The unread notification count (`GET /api` actor) is cached for 5 minutes and not cleared when a
  notification is deleted (a like withdrawn), so it can exceed what the list shows until then.
- Following: a discussion's `subscription` is `follow`, `ignore` or null (an ignored one leaves the
  reader's lists). fof/follow-tags puts `lurk`, `follow`, `ignore` or `hide` on each tag; 1.x sets it
  with `POST /api/tags/{id}/subscription {"data":{"subscription":…}}`, 2.0 by PATCHing the attribute.
- Sign-out (`FlarumApi.logOut`): Flarum has no "revoke this token" call, and `/api/access-tokens`
  never marks a header token `isCurrent` (2.0 rc.8 even fails with 500 listing for one). Listing
  with the token sent as the `<prefix>_remember` cookie marks it current; then
  `DELETE /api/access-tokens/{id}` with the header. The list is paged oldest first (20 by
  default), so a reader with many sessions has the current token on a later page. The prefix
  (`cookie.name`, default `flarum`) shows in any response's `<prefix>_session` Set-Cookie.
