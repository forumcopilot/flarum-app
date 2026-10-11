# Test forums

flarum_core's fixtures and live tests come from two forums on the dev server, one per Flarum major
version, seeded with the same content by `seed.php`. The tools reach them on the server's local
ports, 127.0.0.1:8081 (1.8) and 8082 (2.0). Phones reach them at https://flarum18.betterdiscourse.app
and https://flarum20.betterdiscourse.app (behind Cloudflare, which challenges cloud networks such as
the server's own; see docs/device-testing.md). Each forum's `url` is its public address, so the
links in API responses and fixtures use it.

| | Flarum 1 | Flarum 2 |
|---|---|---|
| Core | 1.8.20 | 2.0.0-rc.8 |
| Extensions | bundled + nicknames, gdpr | the same + messages |

Both also run the plan's 12 Must-tier extensions: fof/upload, best-answer, oauth, polls,
follow-tags, byobu, formatting, terms, drafts, reactions, ignore-users, bookmarks.
Debug mode is off, so error responses look as they do on live forums (status and code, no detail).

## Seeding

On a fresh install, with the extensions enabled:

```bash
php tool/test_forums/seed.php http://127.0.0.1:8081 /path/to/.credentials seed-v1.json
```

It creates, through the REST API: tags (Support with child iOS, secondary tags), users alice, bob
and carol, mentions, a post mention, likes, an image upload, a sticky locked announcement, a
60-post thread that alice has read to post 20, a byobu private discussion between alice and bob,
and unread notifications. It also sets the mail driver to `log` and lets members upload and start
private discussions. See the header of `seed.php` for the credentials file.

For rendering work, `formatting_samples.php` (same arguments plus the seed ids file) adds a
"Formatting samples" discussion with one post per kind of markup. It turns on fof/formatting's
optional plugins (Autoimage, Autovideo, FancyPants, HTMLEntities, MediaEmbed, PipeTables,
TaskLists) and lets fof/upload accept text and PDF attachments, since many forums do.

Then `community_seed.php` gives the forum a community, for the phones and for anyone looking at
it: 14 members with full names (flarum/nicknames), six sections (Photography, Cooking with Baking,
Gardening, Cycling, Books, Tech Help as best-answer Q&A) and three secondary tags, and 27
discussions with 123 posts written as conversations: replies quoting each other, likes, best
answers, a rename, a retag, a lock, a pinned welcome, two private discussions, and seven photos from
Wikimedia Commons (each credited). The content is `community.json`.

```bash
php tool/test_forums/community_seed.php http://127.0.0.1:8081 /path/to/.credentials /path/to/images community-v1.json
```

It leaves the test seed's data as the fixtures recorded it: nothing involves alice, bob or carol or
the tags alice follows, no text uses the words the fixture tests search for, and everything is dated
between 24 August and 6 October 2026, before the test seed, so its discussions stay on the latest
list's first page. The members get random passwords, appended to the credentials file. The images
directory caches the photos (downloaded when missing). It checks every discussion's tags against the
forum's tag rules before writing anything, and refuses to run twice.

Then record fixtures from `packages/flarum_core`:

```bash
FLARUM_TEST_PASSWORD=… dart run tool/record_fixtures.dart http://127.0.0.1:8081 seed-v1.json
```

## CAPTCHA

For sign-in tests, 1.8 runs blomstra/turnstile (on sign-in, sign-up and password reset) and
2.0 runs flectar/flarum-turnstile (on sign-up and reset; sign-in off, because it also blocks
`POST /api/token`, which the tests and tools use). Both use Cloudflare's test keys, which
always pass: site key `1x00000000000000000000AA`, secret `1x0000000000000000000000000000000AA`.

## Installation quirks

- **1.x installer:** `php flarum install -f <file>` enables no bundled extensions unless the file
  has an `extensions:` line. 2.0 enables the defaults.
- **2.0 rc.8 tags:** a parent can't be set when creating a tag through the API (the resource reads
  `attributes.isPrimary` outside `data`), so `seed.php` nests tags with `POST /api/tags/order`.
- **fof/oauth 2.0.0-rc.1** registers a JS folder its package doesn't ship; Flarum then tries to
  create it inside `vendor/` and fails. Create `vendor/fof/oauth/js/dist/forum` after each
  `composer install` or `update`.
- **Memory:** compiling the forum's LESS with this many extensions needs more than PHP's default 128 MB.
- **Mail:** a byobu private discussion emails its recipients; without a working mail driver the
  request fails with HTTP 500 after the discussion is created.
