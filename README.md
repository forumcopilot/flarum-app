# Flapp

Push notifications for [Flapp](https://flapp.forumcopilot.com), the app for Flarum forums on Android and iPhone.

With this extension, members who use Flapp get your forum's notifications on their phones within seconds, in their
own language, for the notification types they choose in a new Flapp column of their notification settings. Every type
can be pushed, including private discussions and Flarum 2.0's messages.

Flapp is an independent app. It is not made by, or affiliated with, the makers of Flarum.

> **Status:** in development, not yet released. The forum side is in place; sending arrives with the relay's push
> endpoint.

## How it works

1. An admin opens the extension's page and clicks **Connect**. The forum makes a signing key and enrols with the Flapp
   relay, which needs no account or email address.
2. A member signed in to the forum in Flapp registers the phone with the forum.
3. For each notification the member has ticked under Flapp, the forum writes the push, in Flarum's own words and the
   member's language, and hands it to the relay, which sends it through Google and Apple.

The relay never receives anyone's sign-in. Disconnecting, or disabling the extension, tells it to forget the forum.
[Flapp's privacy policy](https://flapp.forumcopilot.com/privacy/) covers what it keeps.

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
