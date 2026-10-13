# Phase 3 notes

Phase 3 is the write path, in five milestones (the plan: the "flarum-app Phase 3 Plan" doc). Work
is on branch `phase-3`, started 13 October 2026 from `phase-2` at 39fbc95.

## Milestone 1: composer and posting

- **flarum_core:** `FlarumApi.reply`, `startDiscussion` and `editPost`, and the SDK's
  `replyPostAsync`, `newTopic` (its forum is a primary tag) and `saveRawPostAsync` on them.
  `FlarumApiException.reasons` lists every reason a refusal gives (2.0 names each field, 1.x the
  first rule); `isThrottled` is the posting throttle (429).
- **Composer (flarum_ui `src/compose`):** `ComposePage`, copied from discourse_ui's
  MessageComposePage and adapted (uploads come in milestone 3): Flarum's markup
  (`FlarumMarkup`: Markdown, `[u]`, `>!` and `||` spoilers), @-mentions as `@"Name"#id`: offered
  while typing `@` and two letters, as the web's autocomplete does, or found with the mention
  button (`MentionPickerPage`), when the forum lets the reader search members; the
  throttle and the forum's reasons shown as they come.
- **Where it opens:** Reply on a thread, and Reply and Quote in each post's menu (a reply to a
  post starts `@"Name"#p<id>`, a quote `> @"Name"#p<id> …` from its source or else its words);
  Edit on posts the reader may edit (the source fetched when the post was read without it);
  Start a discussion on Home and on a tag's page (that tag chosen), with `TagPickerPage` keeping
  to the forum's tag rules. After a reply or an edit the thread opens again at that post.
- **Tests:** write fixtures from `tool/record_write_fixtures.dart` (carol and bob, the discussion
  deleted after); the flows replayed on both versions.

## Milestone 2: actions on posts and discussions

- **flarum_core:** `likePost`, `reactToPost` and `unreactToPost`, `setBestAnswer`,
  `setSubscription`, `setTagSubscription`, `bookmarkPost`, `bookmarkDiscussion`,
  `bookmarkedPosts` and `discussions(bookmarked:)`. Posts carry who liked them (the `likes`
  include: up to four, the reader first if they did), their reaction counts and the reader's
  reaction; the forum info carries its reactions. The SDK's like, reaction, best-answer and
  subscription methods, and a bookmark proxy, sit on these.
- **Screens:** under each post, Like with its count, the reactions people chose (a tap adds or
  takes back the reader's) and React (a sheet of the forum's reactions); in the post's menu,
  Bookmark and, for whoever asked in a Q&A tag, Choose as best answer. On the thread's bar, the
  follow menu (Not following, Following, Ignoring, as the web words them) and the bookmark. On a
  tag's page, fof/follow-tags' levels. Bookmarks on the Account tab: discussions and posts. Each
  change shows at once and goes back, with the forum's reason, if it's refused.
- **Found on 1.x:** fof/reactions fails with 500 on a null reaction, so a reaction is taken back
  by sending it again (which 2.0 does too). The discussions' bookmarked filter works only as the
  `is:bookmarked` gambit; the posts' filter works as a key.
- **Tests:** the write recorder adds a Q&A discussion (carol asks, bob answers) and every action
  on it; `FixtureForum` matches 2.0's best answer and 1.x's tag level on their whole `data`, and
  serves a request recorded twice (a reaction, then the same to take it back) in order.


## Milestone 3: uploads

- **flarum_core:** `FlarumApi.upload` (fof/upload's `POST /api/fof/upload`, multipart `files[]`)
  gives each file with the BBCode that puts it in a post: an image preview, or a download card for
  anything else. 1.x leaves the image's alt text as its template's `{TEXT?}`; the app fills in the
  file's name, as 2.0 does. `deleteUpload` is for moderators: fof/upload refuses members by default
  (`canDelete` false even for their own). The SDK's attachment proxy uploads too, and a reply or a
  new discussion given its ids gets their BBCode at the end.
- **Composer:** on forums where the reader may upload (`fof-upload.canUpload`), Upload image (several
  from the gallery), Take photo, and Attach file. Each goes into the text at the cursor as the web's
  `[Uploading: name…]()` and becomes its BBCode when it lands, with a tile above the toolbar (a
  thumbnail or the file's kind, a spinner, Remove). Send waits for uploads still on their way.
  Removing a tile takes its BBCode out; the file stays on the forum unless the reader may delete it.
- **Size:** Flarum doesn't tell the app its upload limit. A file goes as picked; refused as too big,
  a photo is shrunk to the limit the refusal names (forum_kit's `shrinkImageToFit`) and sent once
  more, and the limit is remembered, so the next file over it is shrunk (or refused) before it goes.
  The refusals: fof/upload's own rule (2048 kB by default) is a 422 naming it; past PHP's
  `post_max_size` the files never arrive, a 400 that names fof/upload's limit; past PHP's
  `upload_max_filesize` (2 MB by default) a 413 `max_upload_file_size_ini`; past nginx's
  `client_max_body_size` (1 MB by default) a 413 page of HTML.
- **Tests:** the write recorder uploads a 1×1 PNG and a text file as bob, tries to delete one (403),
  and has the admin delete both; `FixtureForum` matches an upload by its files' names. The shrink
  and retry is tested with scripted refusals.

## Milestone 4: safety and private discussions

Drafts and polls (Milestone 3) wait for Tung's answer on member permissions: members on the test
forums have no fof/polls permission at all (not even to vote) and only moderators may save drafts.
Milestone 4 needs none: members may already flag posts, start private discussions and (2.0) send
messages.

- **Report (flarum/flags):** Flag in a post's menu (where the post's `canFlag`) opens the web's
  reasons: off-topic, inappropriate (with the forum's community guidelines when it sets them),
  spam, or the reporter's own words. `POST /api/flags` always carries `reasonDetail`: 1.x checks for
  an empty one, and would take a flag with neither as having no reason. A second flag from the same
  reader replaces the first. `reportPostAsync` sends a known reason as itself and anything else as
  "Other".
- **Ignore (fof/ignore-users):** Ignore in a post's menu and on a profile (where the author's
  `canBeIgnored`: not the reader, not moderators by default), after asking. Their posts fold to a
  line with Show, as the web folds them; Account lists everyone ignored, each with Stop ignoring.
  `PATCH /api/users/{id}` with `ignored`; each post's author carries `ignored` and `canBeIgnored`,
  and the forum's `GET /api` includes `actor.ignoredUsers`. On a forum without the extension, or
  for a guest, the app keeps the list on the phone (App Store guideline 1.2 asks for a way to block).
- **Terms (fof/terms):** while the reader has a policy to accept (not optional, and updated since
  they last accepted it), the forum gives them a guest's permissions, so a write isn't where to
  catch it: a strip above the tabs says so, and its page lists the policies (each with its link) and
  accepts them. Accepting reloads the tabs with the reader's permissions back. The forum's info
  includes `fofTermsPolicies`; the reader's account carries `fofTermsPoliciesState` (per policy:
  `must_accept`, `has_update`, `accepted_at`, `is_accepted`). Accepting is
  `POST /api/fof/terms/policies/{id}/accept` on 1.x and `/api/fof-terms-policies/{id}/accept` on 2.0;
  1.x sends a policy's columns (`update_message`), 2.0 camelCase. A post meanwhile is refused as a
  guest's would be (403), after the posting throttle (429).
- **Private discussions (fof/byobu):** Account has Private discussions (1.x lists them only by the
  `is:private` gambit, 2.0 by `filter[private]`), with Start a private discussion; a profile's menu
  starts one with that person (not with someone whose `blocksPd` is set). The composer picks the
  people; a member may have only one other person in one (byobu counts the reader:
  `canAddMoreThanTwoUserRecipients`), so a second asks for a permission they lack. It takes no tags
  (2.0's byobu drops them). The thread names who it's with, from `include=recipientUsers` read once
  it's known to be private (the thread's own request stays as it was, so its fixtures do too).
  Members may not change who's in one (`canEditUserRecipients` false; a PATCH is 403), so the app
  doesn't offer it yet. The SDK's conversation proxy sits on the same calls.
- **Messages (flarum/messages, 2.0):** Account has Messages, with the number of conversations with
  something unread (the actor's `messageCount`); each conversation reads newest at the bottom, with a
  field to answer in, and New message (or Send a message on a profile) writes to someone. The API
  is its own: `GET /api/dialogs` (`include=users,lastMessage,lastMessageUser`, `sort=-lastMessageAt`),
  `GET /api/dialog-messages?filter[dialog]=` (the newest first), `POST /api/dialog-messages` with
  `attributes.users` for a first message (the forum finds the dialog it has with them, or starts
  one) or `relationships.dialog` after, and `PATCH /api/dialogs/{id}` `lastReadMessageId`
  (`POST /api/dialogs/read` reads them all). The answer to a send names its author without
  including them. Dialogs can't be deleted, nor (by default) a member's messages, so the recorder's
  is deleted on the server (`tool/test_forums/delete_dialogs.php`). The SDK's conversation proxy
  covers byobu only so far.
- **Cleaning up after byobu:** byobu hides a private discussion even from an admin who isn't in it,
  so the API can't delete the recorder's. `tool/test_forums/delete_discussions.php` deletes them on
  the server through Flarum's models; the recorder runs it when given `FLARUM_DIR`.
- **Tests:** the write recorder has carol flag bob's answer (and once without a reason, 422) and
  ignore him (and herself, 403). The admin then adds a policy for as long as it takes carol to be
  refused a reply and accept it, and deletes it. The fixtures recorded while she ignores him carry a state,
  `ignoring`, that `FixtureForum(states:)` serves in place of the same requests' plain fixtures.
