# What ABDA can learn from the Flarum app

Written 26 Oct 2026, from the UI review that compared flarum_ui (flarum-app `phase-4`, 35d93dc)
with discourse_ui (discourse-app `main`, cb1e368) and ABDA on a Pixel. Most of that review went the
other way (the Flarum app adopting ABDA's Material 3 layout); these are the places where the Flarum
app already does better. Each was checked against discourse_ui's code, and ABDA lacks it there.

Hand this to a discourse-app session. The Flarum code is a reference to copy from and adapt, as
the 9 Oct 2026 decision says: screens are each app's own; only generic pieces go into forum_kit.

## 1. @ offers the discussion's people inline

- **Flarum app:** typing `@` in the composer shows a strip of chips just above the toolbar, with
  the discussion's people first (its latest posters, the reader left out) before anything is
  typed, then members matching what's typed. One tap puts the mention in.
  `packages/flarum_ui/lib/src/compose/compose_page.dart` (`_suggestionStrip`, the `@name` query
  before the cursor, `participants`), fed by `thread_page.dart` (the discussion's people).
- **ABDA:** the @ button opens a full `UserSearchPage` and inserts `@user` at the cursor;
  typing `@` offers nothing (`views/widgets/message_compose_page.dart`, around 943–967).
- **Why:** replying to someone in the thread is the common case; a search page is three steps for it.

## 2. Problems show under the field, not in a snackbar

- **Flarum app:** an empty title or body shows its error under that field
  (`InputDecoration.errorText`), and clears as soon as the reader types; the forum's reasons for a
  refused post are kept with the page. `compose_page.dart` (`_titleMissing`, `_contentMissing`).
- **ABDA:** empty title, empty content and uploads still running are plain SnackBars
  (`message_compose_page.dart`, around 969–986), which disappear and point at nothing.

## 3. A poll builder in the composer

- **Flarum app:** "Add Poll" is a chip above the title; it opens a full-screen editor (question,
  answers, end date, multiple choice, change vote), and the poll shows as a removable chip.
  `packages/flarum_ui/lib/src/polls/poll_editor_page.dart`, `compose/composers.dart`.
- **ABDA:** renders Discourse polls but can't make one; a member has to type `[poll]` markup.
  A builder that writes Discourse's `[poll type=regular results=always]` block would do it.

## 4. Long-press and swipe on topic rows

- **Flarum app:** long-press a discussion row for Mark as Read, Follow, Bookmark and Share;
  swipe an unread row to mark it read (it stays in the list).
  `home/discussion_list_view.dart` (`Dismissible`, `onLongPress`), `home/discussion_actions.dart`.
- **ABDA:** topic rows respond to a tap only (`views/listitems/topic_list_item.dart`).
  ABDA already swipes in Messages, Bookmarks and Drafts, so the gesture is familiar.

## 5. Each category's latest topic on its card

- **Flarum app:** the Tags page shows each tag's latest discussion under its description
  ("Show us your bakes this week · 23 days ago"); tapping it opens that discussion at its last
  post. `tags/tags_page.dart` (`TagCard`), `FlarumApi.tagsLatestDiscussions`.
- **ABDA:** category cards say "N new this week" or the topic count, but not what is happening
  (`views/listitems/category_card.dart`). Discourse's own categories page can show latest topics
  per category, so the data is there (`/categories.json?include_subcategories…` /
  the `latest` topic list per category).

## Not lessons (ABDA already has them)

The thread slider, recent searches, the solution summary card and the "N days later" gaps are in
both apps. ABDA's server drafts (saved while typing) are better than the Flarum app's
save-on-close; the Flarum app keeps save-on-close for now (fof/drafts is optional on Flarum).
