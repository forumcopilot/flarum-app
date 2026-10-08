# Phase 0 notes

Findings from the Phase 0 spike, checked on local Flarum 1.8.20 and 2.0.0-rc.8 forums with the
plan's Must-tier extensions. Last updated 8 October 2026.

So far nothing found blocks the plan. Sign-out, polling and rendering all work on both versions,
with the changes listed below. Web-view sign-in works in a mobile browser on every setup tried;
it still needs a run on a real phone.

## Status

| Item (plan §9, Phase 0) | Result |
| --- | --- |
| Local test forums, Must-tier extensions, demo content | Done: `tool/test_forums/` |
| Minimal Dart client with version detection | Done: `packages/flarum_core`, tested against both versions |
| Token revoke on both versions | Done: `FlarumApi.logOut` (below) |
| Notification listing and last-seen side effects | Measured (below) |
| Run `contentHtml` from both forums through the existing renderer | Done (below) |
| Web-view sign-in capturing `flarum_remember`, incl. a Turnstile forum | Passes in headless mobile Chromium; spike app `tool/spikes/signin_app` ready for the Pixel |

## Sign-in

The plan's flow works: open the forum, click its own "Log In" button, tick "Remember me",
let the reader log in, then read `<prefix>_remember` from the web view's cookie store. The cookie
is HttpOnly, so it must come from the native store (`flutter_inappwebview`'s `CookieManager`),
not page JavaScript. Its value works as `Authorization: Token`.

| Forum | Native `POST /api/token` | Web sign-in in headless mobile Chromium |
| --- | --- | --- |
| 1.8, no CAPTCHA | Works | Works (cookie in ~2.5 s) |
| 1.8, blomstra/turnstile on sign-in | **Still works** | Works, after the widget passes (~5.6 s) |
| 2.0, no CAPTCHA | Works | Works |
| 2.0, flectar/flarum-turnstile on sign-in | 422, pointer `/data/attributes/turnstileToken` | Works (~8.3 s) |

Correction to the plan (§6): a CAPTCHA doesn't always block `POST /api/token`. The common 1.x
extensions (blomstra/turnstile, fof/recaptcha) hook `LogInValidator`, which only the website's
`POST /login` runs. The 2.0 Turnstile fork (flectar/flarum-turnstile, also published as
blazite/flarum-turnstile) adds middleware on the token route. So the web view stays the only
path that works everywhere; a native form is possible on more forums than the plan assumed, and
a 422 on the token's `turnstileToken` (or similar) field is the signal to fall back.

Tested with Cloudflare's always-passing test keys, which work on any domain. Still to do on
the Pixel: the real Android WebView, and Google via fof/oauth on a real forum.

## Sign-out

Flarum has no "revoke this token" call, and `/api/access-tokens` never marks a token sent in the
`Authorization` header as current. 2.0 rc.8 even fails with HTTP 500 listing tokens for one.

What works on both versions:

1. `GET /api/access-tokens` with the token sent as the `<prefix>_remember` cookie and no header.
   Flarum puts the token in a session and marks it `isCurrent`.
2. `DELETE /api/access-tokens/{id}` with the header. The token is refused afterwards (401).

The cookie prefix is `cookie.name` in the forum's config (default `flarum`). If it differs, the
401 sets a `<prefix>_session` cookie, which reveals it. The web-view sign-in sees it directly.

## Polling side effects (for push, plan §7)

| Effect | 1.8 | 2.0 |
| --- | --- | --- |
| Any signed-in request updates `last_seen_at` (at most every 180 s) | Yes | Yes |
| `GET /api` resets the website's "new notifications" badge | No | No |
| `GET /api/notifications` resets it (`read_notifications_at`) | Yes | Yes |
| `newNotificationCount` rises on a new notification | Yes, at once | Yes, at once |
| `unreadNotificationCount` | Cached 5 min; rises at once, lags on deletions | Same |
| A flarum/messages message creates a notification | n/a | No (email only); `messageCount` on the actor rises |

The plan's poll design holds: read the actor's counts from `GET /api`, list only when they rise.

New option: the user preference `discloseOnline`. Set to false (`PATCH /api/users/{id}`,
`preferences.discloseOnline`), other members no longer see the reader's last-seen time, on both
versions. The push consent page can offer it, which removes the "looks online" side effect for
everyone but staff.

## Rendering

`tool/spikes/render_flarum_html_test.dart` renders 14 samples per version
(`tool/test_forums/formatting_samples.php`: Markdown, BBCode, mentions, spoilers, code, tables,
task lists, YouTube, images, uploads, attachments) with discourse-app's `CookedContent` and
`RichTextContent`. Nothing threw on either version.

Works as is: text formatting from Markdown and BBCode, headings, lists, quotes with a cite,
colours and sizes, smart typography, tables, inline spoilers (blurred), YouTube (`iframe` → native
preview card), auto-video (`<video>`), images, and 1.8 upload previews.

Needs Flarum handling in the renderer profile (plan §5.2):

| Markup | Problem | Fix |
| --- | --- | --- |
| Code blocks: `<pre><code>…</code><script>…</script></pre>` (s9e highlight loader) | The loader's JavaScript prints inside every code block | Remove `script` elements |
| `a.UserMention` (`/u/{username}`), `a.PostMention` (`data-id` = post id, `/d/{id}-{slug}/{number}`) | Plain links; post mentions open the browser. 2.0 adds an FA reply icon inside | Route in-app; style as mentions; draw the reply glyph on both versions |
| Task lists: `li[data-task-state] > input[type=checkbox]` | Checkbox state is lost; shows as bullets | Draw the checked or empty box |
| 2.0 upload previews: `a.FoFUpload--Upl-Image-Preview-Link[href=full] > img[src=…-thumb.webp]` | The gallery gets the thumbnail | Take the full size from the anchor, as with Discourse's lightbox |
| Attachments: `div.ButtonGroup[data-fof-upload-download-uuid]` | Shows "notes.txt 25B" with no action | Attachment card; download `GET /api/fof/download/{uuid}` with the header. Needs the `fof-upload.download` permission (forum attribute `fof-upload.canDownload`); members lack it by default |
| Block spoilers: `details.spoiler` with no `summary` | Collapsible with an empty title | Supply a "Spoiler" label |

Also: emoji shortcodes stay as text in stored HTML (the website converts them while typing), so
the composer must insert Unicode. BBCode `[spoiler]` isn't part of core and stays literal.

## Other API facts

See CLAUDE.md, "Flarum API facts the client depends on".

## Notes for later phases

- The rendering spike peaked at 1.4 GB building discourse_ui on the 1.8 GB dev server. Phase 1
  (extracting `forum_kit` and running all of discourse-app's suites) needs more memory than this
  server has, or should run on the Mac.
- Group mentions (`@"Mods"#g4`) render as text unless the author may mention groups.
