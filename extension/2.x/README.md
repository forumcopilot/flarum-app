# Flapp

Push notifications and sign-in for [Flapp](https://flapp.forumcopilot.com), the app for Flarum forums on Android and
iPhone.

With this extension, members who use Flapp get your forum's notifications on their phones within seconds, in their
own language, for the notification types they choose in a new Flapp column of their notification settings. Every type
can be pushed, including private discussions and Flarum 2.0's messages. They also sign in to Flapp on your forum's own
page in their phone's browser, so Google's sign-in and your other log-in buttons work there as on the website.

Flapp is an independent app. It is not made by, or affiliated with, the makers of Flarum.

> **Status:** running on our test forums, not yet on Packagist.

> **Source:** developed in [forumcopilot/flarum-app](https://github.com/forumcopilot/flarum-app/tree/main/extension/2.x),
> alongside the app it pushes to. [forumcopilot/flarum-flapp](https://github.com/forumcopilot/flarum-flapp), which Composer
> installs from, is a copy of that folder.

## How it works

1. An admin opens the extension's page and clicks **Connect**. The forum makes a signing key and enrols with the Flapp
   relay, which needs no account or email address.
2. A member signed in to the forum in Flapp registers the phone with the forum.
3. For each notification the member has ticked under Flapp, the forum writes the push, in Flarum's own words and the
   member's language, and hands it to the relay, which sends it through Google and Apple.
4. When the member reads notifications, here or in the app, the forum tells the relay, so the iPhone's badge follows.

The relay never receives anyone's sign-in. Disconnecting, or disabling the extension, tells it to forget the forum.
[Flapp's privacy policy](https://flapp.forumcopilot.com/privacy/) covers what it keeps.

## What members see

A member who signs in to the forum in Flapp gets a **Flapp** column in their notification settings, on the forum and in
the app. The types that alert on the web by default start on, and so do Flarum 2.0's messages. Members who don't use
Flapp see no change.

A push says what the forum's own notification list says, from its language packs: "carol replied to your post" under
the discussion's title, with the start of the post. A tap opens the post, conversation or profile it is about, and
marks the notification read. The words come for:

- replies and mentions (flarum/mentions), likes (flarum/likes), new posts in followed discussions
  (flarum/subscriptions), renamed and locked discussions, suspensions (flarum/suspend) and Flarum 2.0's messages
  (flarum/messages);
- private discussions (fof/byobu), best answers (fof/best-answer), followed tags (fof/follow-tags) and reactions
  (fof/reactions).

Any other type gets its email subject, or "New notification".

The extension's own words (this page, the column, "New notification") are in English, German, Spanish, French,
Italian, Japanese, Korean, Dutch, Portuguese, Russian and Simplified Chinese.

## Signing in

Without the extension, Flapp signs in on the forum's page inside the app, where Google refuses to sign anyone in. With
it, Flapp opens the forum's **/flapp/authorize** page in the phone's browser instead:

1. A member who isn't logged in there logs in or signs up, with the forum's own Log In and Sign Up buttons, CAPTCHAs
   and sign-in providers. A new account comes back to the app at once; it gets a member's permissions when its email
   address is confirmed, as on the website.
2. The member taps **Authorize**. The forum gives Flapp a sign-in of the same kind "Remember me" makes, encrypted to a
   one-time key the app made for this request, so only that app can read it.

The member can sign Flapp out at any time, in the app or under Active Sessions on their Security page. Sign-in needs
no setting, and works whether or not the forum is connected to the relay. Our servers take no part in it.

## For extension developers

A notification type of yours gets its email subject as the push's line. To give it the web's line instead, name the
translation key, where `{username}` is whoever acted:

```php
(new \ForumCopilot\Flapp\Extend\PushLines())
    ->line('postBookmarked', 'acme-bookmarks.forum.notifications.post_bookmarked_text'),
```

The class is only there when this extension is installed, so check `class_exists()` first.

## Versions

| Flarum | Extension | Branch | PHP |
| --- | --- | --- | --- |
| 2.0 | 2.x | `2.x` | 8.3 or later |
| 1.8 | 1.x | `1.x` | 7.3 or later |

## Installation

Not on Packagist yet. Once it is:

```sh
composer require forumcopilot/flarum-flapp
php flarum migrate
php flarum cache:clear
```

Then enable **Flapp** in the admin panel and click **Connect** on its page.

## Development

```sh
composer install
composer test:unit
FLARUM_TEST_TMP_DIR_LOCAL=tests/integration/tmp composer test:setup
FLARUM_TEST_TMP_DIR_LOCAL=tests/integration/tmp composer test:integration
cd js && npm install && npm run build
```

The integration tests use SQLite unless `DB_DRIVER` and the other `DB_*` variables name another database. The relay
protocol is in [docs/relay-protocol.md](docs/relay-protocol.md).

## License

MIT. See [LICENSE](LICENSE).
