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
