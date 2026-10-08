# Test forums

flarum_core's fixtures and live tests come from two local forums, one per Flarum major version,
seeded with the same content by `seed.php`.

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

Then record fixtures from `packages/flarum_core`:

```bash
FLARUM_TEST_PASSWORD=… dart run tool/record_fixtures.dart http://127.0.0.1:8081 seed-v1.json
```

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
