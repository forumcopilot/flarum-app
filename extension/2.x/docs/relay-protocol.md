# The relay protocol

How a forum running this extension talks to flapp-push, the relay that hands its pushes to Firebase (Android) and
Apple (iPhone). Protocol version 1. The forum only ever calls the relay; the relay never calls the forum.

The relay's address is `RelayClient::DEFAULT_URL` unless the forum's `forumcopilot-flapp.relay_url` setting names
another one (staging, for example). A forum keeps using the relay it connected to.

## Signing

Every call is signed with the forum's ECDSA P-256 key. The forum makes the key when it connects and keeps the private
half; the relay keeps only the public half, so a copy of the relay's database can't forge a call.

The signed message is four lines joined by `\n`:

```text
<METHOD>
<path>
<time>
<sha256 of the body, lowercase hex>
```

- `METHOD` is upper case.
- `path` is the URL's path as the relay receives it, including any prefix in the relay's address, without the query.
- `time` is the Unix time in seconds, the same value as the `X-Flapp-Time` header.
- The body's hash is of the exact bytes sent; an empty body hashes the empty string.

The signature is the DER-encoded ECDSA signature over the message's SHA-256 (PHP's `openssl_sign()` with
`OPENSSL_ALGO_SHA256`), in base64url without padding.

| Header | Value |
| --- | --- |
| `X-Flapp-Forum` | The forum's id on the relay. Absent on enrolment, which has no id yet |
| `X-Flapp-Time` | The Unix time the call was signed |
| `X-Flapp-Signature` | The signature |

The relay refuses a call signed more than 5 minutes from its own clock (401), and a call it has already seen (409).
It recognises a call by the key and the signed message, not the signature, since an ECDSA signature has a second
valid form. A forum that gets 409 for a push it sent again can count it as delivered.

`tests/fixtures/signed-samples.json` holds calls signed this way, with the public key, for the relay's tests.

## Calls

Bodies are JSON. A refusal is any status outside 2xx, ideally with `{"error": "<words an admin can read>"}`; the
extension shows those words on its admin page.

### Enrol: `POST /v1/forums`

```json
{"url": "https://forum.example", "title": "Example Forum", "publicKey": "-----BEGIN PUBLIC KEY-----\n…"}
```

Signed with the new key, whose public half is in the body, so the relay knows the caller holds it. The relay doesn't
check that the caller owns the address: a forum can push only to handles that phones made for its own id, so a fake
enrolment reaches nobody.

Answer: `201 {"forumId": "<1 to 64 of A-Z a-z 0-9 _ ->"}`.

### Forget: `DELETE /v1/forums/{forumId}`

No body. The relay forgets the forum and its handles. `404` or `410` counts as done. Sent on Disconnect and when the
extension is disabled; if the relay can't be reached, the forum disconnects anyway and throws its key away.

### Push: `POST /v1/push`

```json
{"forumId": "…", "pushes": [{"handle": "…", "payload": {"v": 1, "id": 42, "type": "postMentioned", "title": "…", "body": "…"}}]}
```

At most 500 pushes a call. A payload is `{v, id?, type, title, body, excerpt?, open?, unread?}` under 3 KB, `id` being
the notification's (Flarum 2.0's private messages have none), `open` being
`{discussion, post}`, `{dialog}` or `{user}`. Answer: `200 {"sent": 1, "gone": ["<handle>", …]}`. `gone` lists handles the
relay doesn't know for this forum, whose devices the forum deletes; a phone that is only out of reach keeps its
handle. The extension sends these from milestone 3; flapp-push's README has the relay's side, including the limits.

### Unread: `POST /v1/unread`

```json
{"forumId": "…", "counts": [{"handle": "…", "unread": 3}]}
```

Sent when a reader reads a notification, all of them or (Flarum 2.0) a conversation, or deletes them all, on the web
or in the app, for each of their devices: `unread` is what a push's payload would carry now. The relay keeps it for the
iPhone badge and sends each iPhone whose badge changes a badge-only update. At most 500 counts a call. Answer: as for
a push, `200 {"sent": 1, "gone": […]}`.

## What the forum announces

`GET /api` carries, once connected:

```json
"flappPush": {"relay": "https://…", "forumId": "…", "version": 1}
```

The app then asks the relay for a handle for that forum id, signed as its installation, and registers it with the
forum:

```http
POST /api/flapp-push/devices
Authorization: Token <the reader's token>

{"handle": "…", "platform": "android", "app": "flapp", "locale": "de"}
```

- `handle`: 16 to 128 of `A-Z a-z 0-9 _ -`. Registering a handle again moves it to the caller.
- `platform`: `android` or `ios`.
- `app`: 1 to 40 of `a-z 0-9 . -`, starting with a letter or digit.
- `locale`: optional, such as `pt-BR`.

The token must be in the `Authorization` header: the device hangs on that access token and goes when it does. A reader
has at most 10 devices; registering an eleventh drops the oldest. Answer: `201`, a JSON:API document of type
`flappDevices`. `DELETE /api/flapp-push/devices/{id}` removes one of the reader's own devices.

The reader's own user record carries `flappDeviceCount`, and their preferences a `notify_<type>_flapp` per
notification type.
