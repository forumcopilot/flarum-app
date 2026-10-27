# Push check

The phone check for push through the Flapp extension (forumcopilot/flarum-flapp), from milestone 5 of
the Flapp Push Extension Design. It runs on both test forums, with Flapp on the Pixel 4a and the
iPhone 17, bob signed in on both forums on both phones, and the extension's Flapp column at its
defaults.

## Making the pushes

On the server, for each forum (1.8 on 8081, 2.0 on 8082):

```bash
ssh … 'php -- http://127.0.0.1:8082' < tool/test_forums/push_types.php
```

It prints each push as it causes it, a few seconds apart, then the ids it made. Delete those
afterwards, as www-data:

```bash
ssh … 'sudo -u www-data php -- /var/www/flarumapp/flarum2 <discussion ids>' < tool/test_forums/delete_discussions.php
ssh … 'sudo -u www-data php -- /var/www/flarumapp/flarum2 <dialog ids>' < tool/test_forums/delete_dialogs.php
```

## What each phone should show

Every push comes within seconds, in bob's language (English on the test forums), with the forum's
name: beside the app's on Android, as the subtitle on the iPhone.

| Type | Title | Line | A tap opens |
|---|---|---|---|
| postMentioned | Push check | carol replied to your post | carol's reply |
| userMentioned | Push check | carol mentioned you | carol's post |
| postLiked | Push check | carol liked your post | bob's post |
| postReacted | Push check | carol reacted with ❤️ to your post | bob's post |
| newPost | Push check | carol posted | carol's post |
| discussionRenamed | Push check, renamed | admin changed the title | the discussion |
| discussionLocked | Push check, renamed | admin locked | the discussion |
| byobuPrivateDiscussionCreated | Push check, private | carol's line from fof/byobu | the private discussion |
| messageReceived (2.0) | the forum's title | carol sent you a message | the conversation |
| userSuspended | the forum's title | You have been suspended for 1 day | the forum |
| userUnsuspended | the forum's title | You have been unsuspended | the forum |

On Android each push is its own notification, grouped by forum; on the iPhone, grouped by forum.

## The badge (iPhone)

1. After both forums' pushes, Flapp's badge is bob's unread notifications on both forums together
   (plus his unread conversations on 2.0).
2. Open one of the pushes: the badge drops by one within a few seconds, without a push.
3. In Flapp's Notifications on one forum, mark all as read: the badge drops to the other forum's count.

## Cleaning up

Delete what the script made (above). bob stays registered on both forums on both phones.
