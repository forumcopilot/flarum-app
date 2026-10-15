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

### Drafts and polls (14 October 2026)

Tung approved the two member permissions on 14 October; on both test forums members may now start
polls (`discussion.polls.start`), vote (`discussion.polls.vote`), change their vote
(`polls.changeVote`) and save drafts (`user.saveDrafts`, which moderators had).

- **Polls (fof/polls 2.3.5 on 1.8, 3.0.0-rc.4 on 2.0).** A poll belongs to a post: a new
  discussion's is on its first post (the web lets a reply have one too). A thread's posts bring
  theirs (`polls,polls.options,polls.myVotes,polls.myVotes.option`: fof/polls adds them by default,
  but only to a request that names no includes). The card under the post shows the question and
  the answers; the results (bars and percentages) show once the reader may see them: after voting,
  for members, who don't have "view results without voting". Voting is the web's: in a
  single-choice poll a tap votes, a tap on another answer changes it, on the reader's own takes it
  back; in a multiple-choice one each tap counts at once where votes can be changed, otherwise the
  reader chooses and then taps Vote. A public poll lists who voted for what. Voting is `PATCH
  …/polls/{id}/votes` (`/api/fof/polls` on 1.x, `/api/polls` on 2.0) with the reader's whole
  choice as `optionIds` (none takes the vote back), each id once: the forum would count one sent
  twice.
- **Starting one.** Start a discussion offers Add a poll where the reader may (`canStartPolls`): the
  question, two answers or more (up to the forum's `pollMaxOptions`), multiple choice (with how
  many on 2.0: 1.x keeps "any number" whatever it's sent), public votes, changing votes, a closing
  time and hiding the results until then. It goes with the discussion as its `poll` attribute; a
  poll fof/polls refuses (a closing time past) refuses the discussion with a 422 naming the field.
  The forum doesn't check the number of answers: the app does, as the web's form.
- **Drafts (fof/drafts 1.2.14, 2.0.0).** Closing a composer with something written offers Save draft
  (forum_kit's prompt) where the reader may (`canSaveDrafts`): a reply keeps its discussion, a new
  discussion its title and tags, a private one its people. Account → Drafts lists them, the latest
  first (with a count), and opens each in its composer; posting it deletes the draft, as the web
  does (nothing on the forum does). Drafts aren't autosaved: the web saves them only on request too
  unless the writer turns autosave on. A draft has no place for a poll (2.0 refuses an unknown
  `poll`, 1.x keeps it in a 255-character column): a new discussion's poll isn't kept, and saving
  says so.
- **Version differences in drafts:** 1.x takes what a draft is for as JSON:API's own
  `relationships`, 2.0 as an attribute named `relationships` (and needs one on create, `{}` if
  nothing); 2.0 pages and sorts the list, 1.x sends all of it unsorted; on 1.x a saved draft's
  title and text can't be emptied, only changed. 2.0 refuses a draft without text (the app asks
  for some first).
- **Includes:** a forum without fof/polls refuses a request naming `polls…` (400, without saying
  which include: 1.x names none, 2.0 the first). The API now tries each extension's includes alone,
  once per forum, and gives up only those refused, so a forum without polls keeps its mentions and
  likes.
- **SDK:** `votePollAsync` votes in the discussion's poll that has the options given; `FCPost.polls`
  and the thread's `poll` (its first post's) carry them. `FlarumDraftProxy` maps fof/drafts to the
  SDK's keys: `topic_<id>` for a reply, `new_topic`, `new_private_message`, each the latest of its
  kind.
- **Tests:** the write recorder has carol start a discussion with a poll (after one refused for
  closing in the past) and a multiple-choice one; bob votes, changes his vote, sees who voted and
  takes it back. carol saves three drafts, lists them, changes one and deletes them. The read
  recorder now records only the fixtures named by `ONLY` when it's set: the thread's posts were
  re-recorded with the poll includes (`ONLY='^posts_'`), keeping alice's other fixtures as they were.

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

## Milestone 5: moderation basics

- **Discussion:** a menu on the thread's bar for whoever may do something there: a shield for a
  moderator, a plain ⋮ for an author who may rename it or delete it before anyone replies: Rename, Lock/Unlock (flarum/lock), Sticky/Unsticky
  (flarum/sticky), Delete/Restore (Flarum's soft delete, `isHidden`) and Delete forever once
  deleted. Each is a PATCH of the discussion (`title`, `isLocked`, `isSticky`, `isHidden`) or a
  DELETE; the thread is read again after, where it was opened (a rename, a lock or a pin leaves an
  event post; Flarum drops a lock and an unlock in a row).
- **Post:** Delete/Restore (`canHide`: moderators, and the author until someone replies), Delete
  forever for a deleted one, Approve for one held for approval (flarum/approval), which shows
  "Awaiting approval". Approval isn't recorded: every member on the test forums posts without it.
- **Suspension (flarum/suspend):** a moderator's profile menu has Suspend User (forum_kit's page;
  "forever" is the web's until 2038-01-01) and Unsuspend; the reason chosen is both
  `suspendReason` (moderators) and `suspendMessage` (them). Profiles show "Suspended until" to
  moderators and to the person; a suspended reader gets a strip above the tabs with the message.
- **Found on 2.0 rc.8:** a hidden post's or discussion's `isHidden` comes back null; only
  `hiddenAt` says it's hidden, so the models read either.
- **Event posts:** fof/merge-discussions' `discussionMerged` ({count, titles}) and fof/split's
  `discussionSplit` ({title, count, url, toNew}) are described from their published source; neither
  runs on the test forums.
- **SDK:** the moderation proxy sits on these (close is lock, ban is suspend, delete mode 1 hides
  and 2 deletes); the moderation lists, moving and merging, and spam tools answer `result: false`.
- **Tests:** the write recorder signs in a recorded admin for the actions, records the thread and
  bob's profile as the moderator sees them (state `moderator`), deletes a reply bob writes for it,
  and suspends bob indefinitely and lifts it (lifted again in a `finally`); bob's forum while
  suspended is state `suspended`.

## Phone check (13 October 2026)

The Pixel 4a check of aea1b6e, as bob on both forums, passed uploads, flags, ignoring, private
discussions, messages (2.0) and the Phase 2 re-check fixes (tag chips open in the app; the badge
equals the unread rows). Taking a photo and moderation weren't tried. Fixed after it:

- **Send a message from a profile opened an empty conversation** where the reader already had one
  with that person. flarum/messages can't list dialogs by person, so the page now looks for it in
  the reader's list (`FlarumApi.dialogWith`, five pages at most) before showing anything; a first
  message to someone found nowhere still lands in an older conversation, since the forum looks
  for one too.
- **Errors showed the exception** ("No response: DioException [connection error] … Failed host
  lookup") offline. Every message to the reader now goes through `describeError`, discourse_ui's
  wording in the reader's language: no connection, no answer in time, the forum's firewall (a 403
  without Flarum's JSON errors), no permission (1.x's `permission_denied` has no words of its own),
  not found, too many requests, the forum down; otherwise the forum's own message.
- **Send on an empty title or text seemed to do nothing:** it said so in a snackbar for four
  seconds, which the run didn't see. The empty field now says it underneath until written in.
- **A photo from the gallery was called "1000000057.jpg"**, Android's photo picker naming it by its
  media id, and that was its file name in the post and 1.x's alt text. Such photos are now named as
  the camera names one just taken (`IMG_20261013_221203.jpg`, `_2` and on for the others picked with
  it); files with names of their own keep them.
- **bob saw the moderator's shield on his own discussions:** he may rename them, and delete one
  nobody has replied to, as the web's discussion controls offer an author. It's a ⋮ now; the shield
  is for whoever may lock, pin or delete for good.
- **The "Add someone" search offered saved passwords** (Android's autofill): it's out of autofill.
- **The resize notice was right:** the app sent 1,898,739 bytes ("1.8 MB"); fof/upload re-encodes
  every JPEG it stores (quality 90), which made the stored copies 2,249,138 bytes. On 2.0, deleting
  an upload leaves its `-thumb.webp` behind.

Benchmark (thread 26838, profile): build max 70–71 ms (105–110 before the Phase 2 fix), build p99
17.5–17.6 ms, but still 12–13 frames a run with build over 16.7 ms: each the first build of a post,
not rebuilds any more. Profiling those builds (all of the thread's posts, in a test) found two
costs of our own as large as each other: the post's text direction, worked out with a Unicode regex
over every letter, and our 22 style selectors, which flutter_html matches through `package:html`,
parsing each selector again for every element. The direction is now a scan of the text (the same
answer on all 650 posts tried, 68 times faster), and the selectors are read once and applied by an
extension before flutter_html's styling (`_SelectorStyles`; every post renders to the same tree as
before, in light and dark). Each page of posts is also prepared on a worker isolate as it arrives
(`FlarumHtml.warm`, which nothing called). What remains is flutter_html's own work, mostly its
layout. To be measured on the phone again.

## Phone re-check (14 October 2026)

The Pixel 4a re-check of 366df93 passed the conversation from a profile, the empty fields, the
autofill chip, the photo names (fof/upload stores `IMG_…_2.jpg` as `img-…-2.jpg`), the author's ⋮
and rendering (Formatting samples, a long thread, Arabic still right to left), on both forums.
Offline, a discussion and Notifications said "Couldn't reach the forum…", but pulling Home to
refresh kept the list it had and said nothing: the lists show an error only when they have nothing
else to show. Home, Tags, Notifications and Messages now say why a refresh failed over the list
they keep, and the Retry at the end of the Home list works (it called a method that does nothing
after a failure). Notifications nobody sent (a suspension, an export) showed a "?" avatar; they show
an icon for their kind.

Benchmark, thread 26838: build over 16.7 ms in 10 and 6 frames (12–13 before), build max 45 and 54 ms
(70–71), build p99 15.7 and 13.5 ms (17.5–17.6).

```
PERF thread frames=1055 build p50=0.8 p90=2.0 p99=15.7 max=45 | raster p50=3.5 p90=4.2 p99=8.4 max=57 | total>16.7ms=34 total>33ms=15 build>16.7ms=10 raster>16.7ms=4
PERF thread frames=1064 build p50=0.9 p90=2.0 p99=13.5 max=54 | raster p50=3.4 p90=4.2 p99=9.5 max=53 | total>16.7ms=36 total>33ms=13 build>16.7ms=6 raster>16.7ms=6
```

## Census and SDK conformance (15 October 2026)

**Census**, after this week's changes to the posts request (the poll includes) and the renderer:
all 204 guest-readable census forums on 1.0 or later; 199 read (144 on 1.x, 55 on 2.0), 5
unreachable as before (firewalls, a 526, a dropped connection); 1,575 posts rendered, 193 profiles
found by slug, no parse or render errors. One thread failed: forum.osticket.com doesn't run fof/polls
and limits bursts of requests (503), so the includes it refused, and the tries that find which
extension to leave out, ended in a refusal. A forum whose info has no `canStartPolls` doesn't run
fof/polls (or, on 2.0, has discussion polls off, which drops their includes too): the app now leaves
the poll includes off for it from the start.

**Conformance** (`test/conformance_test.dart`, the SDK's shared suites signed in as carol): 48 of 59
on both versions, from 42 of 60 before Phase 3's writes. The harness now names a post to like
(bob's in the welcome thread: carol already likes alice's) and waits out the posting throttle
between the topic suite's new discussion and the post suite's reply. What's left:

- Flarum has no such thing (5): password-protected tags, forum statistics for members (admins
  only), two-step sign-in in the app, who's online for members, recommended users.
- Not supported (3): thanks, and following users (ianm/follow-users, Should tier).
- Test data (1): the seed's users have no avatars.
- The suite's own choice (2): `getRawPostAsync` and `saveRawPostAsync` take the first post of the
  first discussion, someone else's, whose source Flarum gives only to those who may edit it. Only
  a change to the shared suite (the canonical SDK) would pick one of the reader's own.

The plan's target of 54 counted thanks and following users among Phase 3's writes; 50 of 59 is the
most these forums can give the suite as it stands. The runs' writes as carol (two discussions and a
reply each, a flag, an ignore, a tag's follow state, likes, read marks, sign-in tokens) were
removed on the server, checked against a snapshot of every row naming her taken before.

## Phone check of Milestone 2 (15 October 2026)

The Pixel 4a run at c88b927 (2.0, as bob, carol for one reply) passed likes, reactions, best answer
(chosen and removed, with the thread's and Home's marks), bookmarks, the discussion's bell (an
ignored discussion leaves Home) and tags' levels. The offline refresh fix passed on Home, Tags and
Notifications, and the suspension notices show their icons. Benchmark, thread 26838: build over
16.7 ms in 9 and 6 frames, build max 57 and 47 ms, p99 14.5 and 15.1 ms (as at 366df93). Drafts and
polls weren't part of this run. Fixed after it:

- **The Bookmarks page kept a bookmark taken off in the thread** until it was opened again. It reads
  both tabs again when the reader comes back to it, and a discussion read again on the way back
  from it leaves a list it no longer belongs to (an ignored discussion from any list; one no longer
  bookmarked or followed from those lists). Both empty tabs say "No bookmarks yet."
- **A tag's bell showed the ringing bell for Lurking**, where the menu shows an eye: the bar now
  shows the menu's icon for each level (the eye for Lurking, the crossed eye for Hidden).
- **fof/reactions keeps a "reacted" notification** after the reaction is taken back (and an empty
  reaction row): carol had three from bob's tries. A forum's behaviour, not the app's; removed on the
  server with the run's discussion.

