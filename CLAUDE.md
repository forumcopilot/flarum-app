# CLAUDE.md

Guidance for Claude Code sessions working in this repository.

## Project

flarum-app is a Flutter client for Flarum forums, the Flarum counterpart of discourse-app. The plan
(phases, decisions, scope) is the "Flarum App Plan": https://claude.ai/artifact/W61kE9VGWeUbHWxMycWedL.
Current phase: **0 (spike)**. Only `packages/flarum_core` exists.

Flarum 1.8 and 2.0 are both fully supported. Design for 2.0 and keep 1.x differences in clearly
marked places so 1.x can be dropped later. The app needs no plugin on the forum.

## Rules (from the plan, set by Tung)

- Get explicit approval before creating repos, deploying, uploading to stores or publishing.
- Pushing to this repo needs no approval (decided 8 Oct 2026). Push when work is tested; CI must stay green.
- `git add` with explicit paths only. Never commit credentials or a config pointing at a local forum.
- SDK interface and model changes go into the canonical forumcopilot_sdk first, not a local copy.

## Commands

```bash
cd packages/flarum_core && dart pub get && dart analyze && dart test
```

Tests replay fixtures recorded from both versions (`test/fixtures/v1`, `v2`); every API test runs
against both. Live tests and re-recording: `test/live_test.dart`, `tool/test_forums/README.md`.

## Flarum API facts the client depends on

Checked against 1.8.20 and 2.0.0-rc.8:

- Version: only 2.0's `GET /api` forum attributes include `colorScheme` and `jsChunksBaseUrl`.
- Auth: `Authorization: Token <token>`; it skips CSRF. `POST /api/token` fails on CAPTCHA forums.
- 2.0 rejects unknown query parameters with HTTP 400; 1.x ignores them. Send only known ones.
- Paging: `page[offset]` and `page[limit]`, capped at 50. Never follow `links.next`: on 2.0 it
  drops the `/api` prefix. Posts: `/api/posts?filter[discussion]=…` on both versions.
- `page[near]` can't be combined with `sort` on 1.x; 1.x places the post by `created_at`, so the
  page contains it but not necessarily centred.
- Attribute types vary: 2.0 sends some booleans as `"1"`/`""`; tag limits are strings on both.
  Read attributes through `FlarumAttributes`.
- Validation (422): 1.x reports the first failed rule, 2.0 every invalid field.
- Listing `/api/notifications` resets the reader's "new" badge on the website.
- byobu private discussions are invisible to admins who aren't recipients.
- Revoking the current token is unsolved: 1.8's `/api/access-tokens` marks no header token as
  current, and 2.0 rc.8 returns HTTP 500 on that list for header tokens.
