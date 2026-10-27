# The Flapp extension

A Flarum extension that sends a forum's notifications to its members' phones as push
notifications, within seconds and in each member's language. The extension's own README covers
what members see and how it works: [2.x/README.md](2.x/README.md).

| Folder | For | PHP |
| --- | --- | --- |
| `2.x/` | Flarum 2.0 | 8.3 or later |
| `1.x/` | Flarum 1.8 | 7.3 or later |

Only push needs the extension. The app reads, posts and signs in without anything installed on
the forum: sign-in and sign-up use the forum's own pages.

## Installing it on a forum

Install it from [forumcopilot/flarum-flapp](https://github.com/forumcopilot/flarum-flapp), which
holds each version on its own branch. It is not on Packagist yet, so add the repository first:

```sh
composer config repositories.flapp vcs https://github.com/forumcopilot/flarum-flapp
composer require forumcopilot/flarum-flapp:2.x-dev   # Flarum 2.0; 1.x-dev for Flarum 1.8
php flarum migrate
php flarum cache:clear
```

Then enable **Flapp** in the admin panel and click **Connect** on its page.

The extension pushes to members who use [Flapp](https://flapp.forumcopilot.com), the multi-forum
app built on this repository. A branded app of your own needs its own push setup (a Firebase
project, and the relay sending for it). We do that as part of a custom build; see the main
[README](../README.md#need-it-built-for-you).

## Working on it

This folder is where the extension is developed, with its history. forumcopilot/flarum-flapp is
the copy that Composer installs from. It is updated from here with `git subtree`, which gives the
same commits each time, so its branches only ever move forward:

```sh
git subtree split --prefix=extension/2.x -b flapp-2.x
git subtree split --prefix=extension/1.x -b flapp-1.x
git push https://github.com/forumcopilot/flarum-flapp.git flapp-2.x:2.x flapp-1.x:1.x
```

Each folder is a complete extension with its own `composer.json`, tests and `js/` (whose `dist/`
build is committed, as Flarum extensions ship it). Its tests run inside its folder (`composer test`, after the database setup in the "Development"
section of its README). The `.github/` folders inside run on flarum-flapp. Here,
`.github/workflows/extension.yml` runs the same checks for both versions.
