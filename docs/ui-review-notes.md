# The UI review: the Discourse app's layout for flarum_ui

26 Oct 2026, branch `ui-review` (off `phase-4` at 35d93dc). Tung found the app's layout behind the
Discourse app's (ABDA): not Material 3 in places, tag labels hard to read, likes and reactions unlike
ABDA's, rough tag (subforum) navigation. The review compared flarum_ui with discourse_ui screen by
screen and on a Pixel; Tung agreed to all of it. The direction: keep Flarum's concepts (tags, the
thumbs-up, best answers, the scrubber) and take the Discourse app's layout and forum_kit's shared
pieces. Screens stay flarum_ui's own copies (the 9 Oct decision); only generic widgets come from
forum_kit (`FilterChipBar`, `PostActionButton`, `UnreadBadge`, `SectionHeader`, `SheetTitle`,
`DrawerIntroduction`, `readableOn`, `contrastRatio`).

What ABDA can learn from this app went the other way: `abda-lessons-from-flarum.md`.

## Done

**Navigation.** Tabs: Home, Messages (flarum/messages or byobu; chips when a forum has both),
Notifications, Profile. Tags left the bar for Home's chips and the drawer. The forum's drawer
(`app/forum_drawer.dart`), as ABDA's: the reader's card, Community (All Discussions, Following,
Bookmarks, My Posts), the tags with each child folded under its parent, All Tags; sections fold and
stay folded. The tabs' bars find it through `ForumDrawerScope` (each tab has its own Scaffold).
Hosted (Flapp) the edge stays Back, the drawer opens from ☰ and introduces itself once
(forum_kit's `DrawerIntroduction`, key `forum_drawer_introduced`), as in ABDA; hosted forums have ☰
where the tabs had a back arrow. Back closes the drawer first, then goes to Home, then out: on the
app's first route Android left the app with the drawer open until the shell took Back itself.

**Home.** `ForumMasthead` (the forum's logo or icon and name, its description, a search field, the
accent line) collapsing into the bar; chips Latest · Tags · Top · Newest · Oldest (· by title on 2.0)
pinned under it; Tags shows the tags' cards in place. Start a Discussion folds to its icon on scroll.

**Tags.** `TagLabel` is the Discourse app's category badge: a primary tag is a mark of its colour
(split with its parent's for a child) and its name in the page's quiet text colour; a secondary tag a
neutral chip with a dot of its colour; tappable (32dp). Before, 10 of the test forum's 17 tag colours
left white text under 4.5:1 (orange 2.85, green 2.87). `textOn` picks white or black by WCAG contrast
wherever text still sits on a colour (tiles, group badges). Tags page: `TagCard`s (colour band, count,
latest discussion, child tags as chips), then Other Tags. A tag's page: `TagMasthead` (a tint of its
colour, the line, a breadcrumb to the parent, the follow button), its child tags and the sorts as
chips; its rows leave its own tag off.

**Discussion rows.** As `TopicListItem`: title (stepped back only once a signed-in reader has read it
all), `UnreadBadge`, the sticky excerpt, the tags (secondary ones "+N"), then the last activity, the
replies and one state in a word (`discussionStatuses`). Inset dividers.

**A discussion.** Its head is the title, tags and states on the page (no band of the tag's colour).
Under a post (`PostActionsRow`): N replies on the left; the likes and reactions in one count that
opens who (the likers the post carries, "and N others", each reaction's count), Like (a long press
offers the reactions), the reader's reaction, Bookmark (out of ⋮) and Reply, as 48dp icons. An
avatar opens the member's card (`showUserCard`) before the profile.

**Who liked and reacted** (`WhoReactedSheet`, 27 Oct), as ABDA's sheet: chips for All, the likes
and each reaction, a row per person with what they gave, the reader first, React at the foot. The
likers the post carries show at once; everyone loads for a reader who may search users
(`FlarumApi.likers`), and who reacted where the discussion's `canSeeReactions` allows
(`postReactions`; no group may by default, so most readers get the reactions' counts). Fixtures:
`post_likers*` and `post_reactions*`, recorded on the community's welcome post.

**Edit Profile** (`EditProfilePage`, 27 Oct), as ABDA's: the picture with a camera button (take a
photo, choose one, remove it), then a row per thing the forum lets the reader change, saved as it's
changed: the display name (flarum/nicknames, in a dialog whose field shows the forum's refusal, with
Undo after), the username with a lock (admins' alone). Email, password and the rest stay on the
forum's settings page, linked at the foot. Fixtures: `profile_*`, alice's, put back as they were.

**Profile.** The Profile tab is ABDA's hub: avatar and name, View Profile / Edit Profile, the stats,
Your Stuff (My Posts, Drafts, Bookmarks, Flagged Posts), Settings (Notification Settings, the colour
scheme in a sheet, Account and Privacy, Log Out in red); a guest gets Join and Log In. A member's
profile: a band of their colour with the avatar over its edge, Message (or Edit Profile on one's
own), the stats; ⋮ items have icons.

**Composer and messages.** Short send labels (Post, Reply, Send, Save; Flarum's long ones cut the
title to "Start a Discu…"). The bar is ABDA's: attachments, then every format under Formatting, then
@. A conversation's ⋮ has View Profile. Notifications and conversations mark unread with the shared
`UnreadBadge` instead of a tinted row and a red badge.

## Not done, and why

- **Email and password in the app**: Flarum asks for the reader's password to change either (and
  mails a confirmation), so they stay on the forum's settings page, as ABDA keeps them in Account.
- **Composer drafts saved while typing** (ABDA saves server drafts as you type): fof/drafts is
  optional on Flarum and saving silently creates drafts on the forum; left as save-on-close.
- **Emoji picker** in the composer: ABDA's composer has none either; left out for consistency.
- **Flapp.** Nothing in Flapp changed. When its pin moves to this work, `test/app_test.dart`'s
  "Back returns to the list" taps a `BackButton` the hosted forum no longer has (use
  `tester.binding.handlePopRoute()`), and its tests should seed `forum_drawer_introduced: true` so the
  drawer doesn't introduce itself over them.

## For Tung to look at

- iOS has no system Back button: in Flapp a forum is left with the edge swipe, as in ABDA. If that's
  too hidden, the drawer's header could offer "Your forums".
- The chips' order on Home (Latest, Tags, then the other sorts) puts Tags where a thumb finds it;
  the web keeps tags in its sidebar.

Checked on a Pixel 10a (Android, dark) as a guest on the 2.0 test forum: Home, the drawer, Home's
Tags, a tag's page, a discussion, Messages and Profile. Signed-in screens (Like, the Profile hub, a
conversation) are covered by the widget tests only: signing in needs a test account's password.
