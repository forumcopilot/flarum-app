# SDK coverage on Flarum

How each `IFC*Proxy` method in forumcopilot_sdk can be served by Flarum 1.8 and 2.0. Checked on
9 October 2026 against the source of 1.8.20 and 2.0.0-rc.8 with the plan's Must-tier extensions,
and with read-only calls to the test forums. Extensions that aren't installed were checked from
their published source only, and are marked as such.

Of the 181 methods, 20 don't apply to Flarum. Of the other 161, Flarum fully serves 105 on 1.8
and 115 on 2.0, through core or an extension; 33 and 32 work with limits; 23 and 14 are not
possible (8 of 1.8's are chat).

| Status | 1.8 | 2.0 |
| --- | --- | --- |
| Core | 48 | 49 |
| Ext | 57 | 66 |
| Partial | 33 | 32 |
| No | 23 | 14 |
| n/a | 20 | 20 |

Legend: **Core** core endpoint · **Ext** an extension (named) · **Partial** works with limits or
client-side assembly · **No** not possible · **n/a** the concept doesn't exist on Flarum.

## Gaps that matter for v1

- **Search is built differently per version.** 1.8 takes conditions as gambits inside `filter[q]`
  (`tag:`, `author:`, `is:unread`, `is:private`, `is:hidden`) and ignores other `filter[...]` keys
  once `q` is present. 2.0 takes separate keys (`filter[tag]`, `filter[unread]`, `filter[private]`)
  and treats gambits in `q` as plain words. `FlarumApi.discussions` already branches for tag and
  following; the search proxy needs the same.
- **1.8 has no post search.** `/api/posts?filter[q]` returns every post, unfiltered. Post results on
  1.8 must come from the discussion search's `mostRelevantPost` (one per discussion).
- **2.0 direct messages (flarum/messages) create no notification**, only email. Push must also
  watch the actor's `messageCount`. Dialogs are 1:1 only, with no edit, likes, flags or leaving.
- **Sign-up, password reset and password change stay on the web.** CAPTCHA and CSRF guard
  `POST /api/users` and `POST /api/forgot`, and members can't change their password through the API.
- **Several SDK models don't fit:** notification preferences are per-type alert/email toggles
  (`notify_<type>_alert|email`), not Discourse-shaped levels; bookmarks can be on discussions too;
  attachments are BBCode in the post, not ids; topic lists are by tag slug, not forum id. These
  need SDK changes (in the canonical SDK first) or adapters.
- **Permissions vary by forum and are often off for members:** server drafts (`canSaveDrafts`),
  the user list and search (`searchUsers`), online users (`viewLastSeenAt`), more than two PM
  recipients, editing recipients, attachment downloads. Read the forum's `can*` flags and hide
  what isn't allowed.
- **Not available:** mark unread, archive, post votes, board statistics (admin-only), joining
  groups, reporting a user, a deleted-posts list. Chat on 1.8; on 2.0 only ramon/chat (new, untested).

## 1.8 and 2.0 differences beyond search

| What | 1.8 | 2.0 |
| --- | --- | --- |
| List totals | None (only `links.next`) | `meta.page.total` |
| Unknown query parameter | Ignored | HTTP 400 (unknown `filter[...]` keys are ignored on both) |
| Private discussions list | `filter[q]=is:private` | `filter[private]=1`, plus `/api/dialogs` |
| Tag follow (fof/follow-tags) | `POST /api/tags/{id}/subscription` | `PATCH /api/tags/{id}` `subscription` |
| Poll vote (fof/polls) | `PATCH /api/fof/polls/{id}/votes` | `PATCH /api/polls/{id}/votes` |
| Best answer (fof/best-answer) | attribute `bestAnswerPostId` (0 clears) | relationship `bestAnswerPost` (null clears) |
| Reader's reaction (fof/reactions) | `userReactionIdentifier` | `userReaction` |
| Primary tag | No `isPrimary`; primary when `position` is set | `isPrimary` |
| Drafts (fof/drafts) | Unpaged | Paged, `-updatedAt` |
| Direct messages | byobu only | byobu, and flarum/messages dialogs |

## Config, account and users

### IFCConfigProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| getConfig | Core | Core | `GET /api` forum attributes and `can*` flags | No version string; 2.0 detected by `colorScheme`. |

### IFCAccountProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| signinRegister | n/a | n/a | — | Tapatalk-ID flow; Flarum signs in by web view. |
| signinLoginWithEmail | n/a | n/a | — | Same; `POST /api/token` accepts an email as `identification`. |
| signinLoginWithUsername | n/a | n/a | — | Same. |
| signinLogin | n/a | n/a | — | Same. |
| forgetPassword | Partial | Partial | `POST /api/forgot {email}` | CAPTCHA (when installed) and CSRF for guests; send to the web. |
| updatePassword | Partial | Partial | `password` needs `user.editCredentials`; else the reset email | Members can't change their own password via the API. |
| updateProfile | Partial | Partial | `PATCH /api/users/{id} {nickname}` (flarum/nicknames) | No bio or custom fields installed; username needs editCredentials. |
| updatePasswordSSO | n/a | n/a | — | fof/oauth runs only through forum web routes. |
| updateEmail | Core | Core | `PATCH /api/users/{id} {email}` with `meta.password` | Applies after the confirmation link. |
| register | Partial | Partial | `POST /api/users` | CAPTCHA and CSRF; the API bypasses fof/terms. Keep sign-up on the web. |
| prefetchAccount | Core | Core | `GET /api`: `allowSignUp`, `passwordlessSignUp`, CAPTCHA and terms flags | Tells the app to send sign-up to the web. |
| getUserSettingsCategories | Partial | Partial | Grouped client-side over `preferences` keys | No server categories. |
| getUserSettings | Partial | Partial | `GET /api/users/{id}` `preferences` | Values only; labels live in the forum's JS translations. |
| updateUserSettings | Core | Core | `PATCH /api/users/{id} {preferences}` | Own account only. |
| getNotificationPrefsAsync | Partial | Partial | `preferences.notify_<type>_{alert,email}`, `followAfterReply` | SDK model is Discourse-shaped; needs a change. |
| updateNotificationPrefsAsync | Partial | Partial | `PATCH /api/users/{id} {preferences}` | Same model mismatch. |

### IFCUserProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| getAvatarAsync | Core | Core | `GET /api/users/{id}` `avatarUrl` | Null when none uploaded. |
| loginAsync | Core | Core | `POST /api/token {identification, password, remember}` | Blocked where a CAPTCHA guards the token route (2.0 Turnstile fork). |
| getPasskeyChallengeAsync | No | No | — | No passkey support found. |
| loginWithPasskeyAsync | No | No | — | Same. |
| loginTwoStepAsync | Ext | Ext | `POST /api/token` plus `twoFactorToken` (ianm/twofactor, not installed) | One call, not two steps. Unverified. |
| getInboxStatAsync | Partial | Ext | 1.8: byobu `q=is:private is:unread`, counted client-side. 2.0: `messageCount` plus `filter[private]&filter[unread]` | 1.8 has no totals. |
| logoutUserAsync | Core | Core | `FlarumApi.logOut`: find the token via `/api/access-tokens` with the remember cookie, then delete it | Solved in Phase 0; see phase-0-notes.md. |
| getOnlineUsersAsync | Partial | Partial | `GET /api/users?sort=-lastSeenAt` | Needs `viewLastSeenAt` (400 for members on both). |
| getUserInfoAsync | Core | Core | `GET /api/users/{id}`, or `/api/users/{username}?bySlug=true` | Without `bySlug` a username 404s. |
| getUserTopicAsync | Core | Core | `GET /api/discussions?filter[author]={name}` | Includes private discussions the reader can see. |
| getUserReplyPostAsync | Core | Core | `GET /api/posts?filter[author]={name}&filter[type]=comment&sort=-createdAt` | 2.0 adds a total. |
| getRecommendedUsersAsync | No | No | — | No such concept. |
| searchUserAsync | Core | Core | `GET /api/users?filter[q]=…` | Needs `searchUsers`; guests get 403. |
| ignoreUserAsync | Ext | Ext | `PATCH /api/users/{id} {ignored}` (fof/ignore-users) | Check `canBeIgnored`. |
| getIgnoredUsersAsync | Ext | Ext | 1.8 `filter[q]=is:ignored`; 2.0 `filter[ignored]=1` | |
| reportUserAsync | No | No | — | flarum/flags flags posts only. |
| getDirectoryItemsAsync | Partial | Partial | `GET /api/users?sort=-commentCount` (or discussions, joined) | No periods or like stats. |
| getAllBadgesAsync | Ext | Ext | `GET /api/badges` (fof/badges, not installed) | Unverified. |
| getUserBadgesAsync | Ext | Ext | `GET /api/user-badges` (fof/badges, not installed) | Unverified; 1.x filter unclear. |

## Reading and writing

### IFCForumProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| getForumAsync | Ext | Ext | `GET /api/tags` (flarum/tags) | 1.8: primary from `position`. |
| getParticipatedForumAsync | Partial | Partial | fof/follow-tags `subscription` on tags | Followed tags, as Discourse approximated it. |
| markAllAsRead | Core | Core | `PATCH /api/users/{id} {markedAllAsReadAt: true}` | Whole forum only. |
| loginForum | n/a | n/a | — | No password-protected tags. |
| getIdByUrl | Core | Core | Parse `/d/{id}-{slug}[/{n}]`, `/t/{slug}`, `/u/{username}` | Post number → id via `filter[discussion]`+`filter[number]`. |
| getUrlById | Core | Core | `/d/{id}/{number}`, `/t/{slug}` | A post id needs `GET /api/posts/{id}`. |
| getBoardStatAsync | No | Partial | `/api/statistics` is admin-only; 2.0 list totals | Counts only what the reader sees. |
| getForumStatusAsync | Ext | Ext | `GET /api/tags`, filtered client-side | No unread state per tag. |

### IFCTopicProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| markTopicReadAsync | Core | Core | `PATCH /api/discussions/{id} {lastReadPostNumber}` | One request per discussion. |
| getTopicStatusAsync | Core | Core | `GET /api/discussions/{id}` per id | No id filter on lists. |
| newTopic | Core | Core | `POST /api/discussions` with title, content, `tags` relationship | Tag limits from forum attributes. |
| getTopTopicAsync | Ext | Ext | `filter[tag]={slug}&filter[sticky]=1` (flarum/sticky) | Popular: `sort=-commentCount`. |
| getAnnTopicAsync | Partial | Partial | `filter[sticky]=1` without a tag | No announcements; forum-wide stickies are closest. |
| getTopicAsync | Ext | Ext | `GET /api/discussions?filter[tag]={slug}` | Needs the slug; an id returns nothing. |
| getUnreadTopicAsync | Core | Core | 1.8 `filter[unread]` or `q=is:unread`; 2.0 `filter[unread]` | `q=is:unread` returns nothing on 2.0. |
| getParticipatedTopicAsync | Partial | Partial | Started: `filter[author]`; replied: `/api/posts?filter[author]` | No participated filter. |
| getLatestTopicAsync | Core | Core | `GET /api/discussions` | Default `-lastPostedAt`. |
| getNewTopicAsync | Core | Core | `sort=-createdAt` | "New since visit" ≈ `filter[unread]`. |
| getTopicByIds | Core | Core | `GET /api/discussions/{id}` per id | 2.0's show still includes posts. |
| markPostsReadAsync | Core | Core | `PATCH /api/discussions/{id} {lastReadPostNumber: max}` | High-water mark only. |

### IFCPostProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| reportPostAsync | Ext | Ext | `POST /api/flags` (flarum/flags) | Check `canFlag`. |
| replyPostAsync | Core | Core | `POST /api/posts` with content and `discussion` | Attachments as fof/upload BBCode; approval may hold posts. |
| getQuotePostAsync | Partial | Partial | Built client-side: `> @"Name"#p{id} text` | Raw `content` goes only to editors. |
| getRawPostAsync | Core | Core | `GET /api/posts/{id}` `content` | Only if the reader can edit. |
| saveRawPostAsync | Core | Core | `PATCH /api/posts/{id} {content}`; title via the discussion | No edit reason; title needs `canRename`. |
| getThreadAsync | Core | Core | Discussion plus `/api/posts?filter[discussion]`, offset paging | 50 per page. |
| getThreadByUnreadAsync | Core | Core | `lastReadPostNumber`+1 → `page[near]` | |
| getThreadByPostAsync | Core | Core | `GET /api/posts/{id}` → `page[near]` | 1.8 doesn't centre the post. |
| votePollAsync | Ext | Ext | fof/polls (paths differ, see above), body `{optionIds}` | Unverified live: no polls on the test forums. |
| acceptAnswerAsync | Ext | Ext | fof/best-answer (fields differ, see above) | Check `canSelectAsBestAnswer`. Unverified live. |
| unacceptAnswerAsync | Ext | Ext | Same | Unverified live. |
| toggleReactionAsync | Ext | Ext | `PATCH /api/posts/{id} {reaction: id}` (fof/reactions) | Same id again removes it. |
| getAvailableReactionsAsync | Ext | Ext | `GET /api/reactions` | 6 by default. |
| castPostVoteAsync | No | No | — | Would need fof/gamification. |
| removePostVoteAsync | No | No | — | Same. |

### IFCSearchProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| searchTopicAsync | Core | Core | `GET /api/discussions?filter[q]=…&include=mostRelevantPost` | Totals on 2.0 only. |
| searchPostAsync | Partial | Core | 1.8: `mostRelevantPost`; 2.0: `GET /api/posts?filter[q]=…` | 1.8 `/posts` ignores `q`. |
| advanceSearchPostAsync | Partial | Partial | 1.8 gambits; 2.0 `filter[author]`, `[discussion]`, `[tag]` (numeric ids) | No title-only search. |
| advanceSearchTopicAsync | Partial | Partial | 1.8 gambits `author:`, `tag:`, `-tag:`, `created:`; 2.0 the same as filter keys | No title-only search. |

### IFCTagProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| getAllTagsAsync | Ext | Ext | `GET /api/tags` | Primary, secondary and child tags. |
| searchTagsAsync | Ext | Ext | `GET /api/tags?filter[q]={prefix}` | Prefix match. |
| getTopicsByTagAsync | Ext | Ext | `filter[tag]={slug}`; with a search on 1.8, `tag:` inside `q` | |

### IFCSubscriptionProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| getSubscribedForumAsync | Ext | Ext | `GET /api/tags`, tags with a `subscription` (fof/follow-tags) | |
| subscribeForumAsync | Ext | Ext | fof/follow-tags (routes differ, see above) | `follow` or `lurk`. |
| unsubscribeForumAsync | Ext | Ext | Same with `subscription=null` | |
| getSubscribedTopicAsync | Ext | Ext | `filter[subscription]=following` (flarum/subscriptions) | |
| subscribeTopicAsync | Ext | Ext | `PATCH /api/discussions/{id} {subscription: 'follow'}` | |
| unsubscribeTopicAsync | Ext | Ext | `subscription=null` | |
| setTopicNotificationLevelAsync | Partial | Partial | follow = watching, ignore = muted, null = normal | No "tracking". |
| getTopicNotificationLevelAsync | Ext | Ext | Discussion `subscription` | Three states. |
| setCategoryNotificationLevelAsync | Partial | Partial | lurk = watching, follow = first post, ignore = muted | Flarum's `hide` has no SDK level. |
| getCategoryNotificationLevelAsync | Ext | Ext | Tag `subscription` | |

### IFCSocialProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| thankPostAsync | n/a | n/a | — | Likes cover it. |
| followAsync | Ext | Ext | `PATCH /api/users/{id} {followUsers: 'follow'}` (ianm/follow-users, not installed) | Unverified. |
| unfollowAsync | Ext | Ext | Same with `null` | Unverified. |
| likePostAsync | Ext | Ext | `isLiked` (flarum/likes) or `reaction` (fof/reactions) | |
| unlikePostAsync | Ext | Ext | `isLiked=false` or `reaction=null` | |
| likeConversationMessageAsync | Ext | Ext | byobu posts: `isLiked` | Dialog messages have no likes. |
| unlikeConversationMessageAsync | Ext | Ext | Same | |
| getAlertAsync | Core | Core | `GET /api/notifications?include=fromUser,subject,subject.discussion` | Resets the website's "new" badge. A mention opens at `content.replyNumber`. |
| getActivityAsync | Partial | Partial | `GET /api/posts?filter[author]={name}&sort=-createdAt` | Own posts only. |
| markAllAlertsReadAsync | Core | Core | `POST /api/notifications/read` | |

### IFCBookmarkProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| addPostBookmarkAsync | Ext | Ext | `PATCH /api/posts/{id} {bookmarked: true}` (fof/bookmarks) | Unverified write. |
| removePostBookmarkAsync | Ext | Ext | `{bookmarked: false}` | Unverified write. |
| removeBookmarkByIdAsync | Partial | Partial | Use the post id | No bookmark ids. |
| getBookmarksAsync | Ext | Ext | `GET /api/posts?filter[bookmarked]=1` | Can't sort by bookmark time. |

### IFCDraftProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| saveDraftAsync | Ext | Ext | `POST`/`PATCH /api/drafts` (fof/drafts) | Needs `user.saveDrafts` (members lack it by default). |
| loadDraftAsync | Partial | Partial | `GET /api/drafts`, match the key client-side | No fetch by key. |
| deleteDraftAsync | Ext | Ext | `DELETE /api/drafts/{id}` | |
| getMyDraftsAsync | Ext | Ext | `GET /api/drafts` | |

### IFCAttachmentProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| uploadAttachmentAsync | Ext | Ext | `POST /api/fof/upload`, multipart `files[]` (fof/upload) | Returns BBCode for the post. |
| uploadAvatarAsync | Core | Core | `POST /api/users/{id}/avatar` | |
| removeAttachmentAsync | Partial | Partial | Remove the BBCode from the post | Deleting the file is moderator-only. |

## Private messages

### IFCPrivateConversationProxy
A conversation is a fof/byobu private discussion (both versions) or, on 2.0, a flarum/messages dialog.

| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| newConversationAsync | Ext | Ext | byobu `POST /api/discussions` with `recipientUsers`; 2.0 dialogs `POST /api/dialog-messages` `users` | More than 2 recipients needs a permission. |
| replyConversationAsync | Core | Core | `POST /api/posts`; dialogs `POST /api/dialog-messages` with `dialog` | |
| inviteParticipantAsync | Partial | Partial | `PATCH` the discussion's full `recipientUsers` | Needs `editUserRecipients` (no default grant). |
| getInboxStatAsync | Partial | Ext | 1.8 `q=is:private is:unread`; 2.0 `filter[private]&filter[unread]`, `messageCount` | |
| getConversationsAsync | Ext | Ext | 1.8 `q=is:private`; 2.0 `filter[private]=1` and `/api/dialogs` | 2.0 merges two sources. |
| getConversationAsync | Core | Core | Discussion and posts; dialogs `/api/dialog-messages?filter[dialog]=` | byobu event posts are mixed in. |
| getConversationByMessageAsync | Core | Core | `page[near]` | |
| getQuoteConversationAsync | Partial | Partial | Built client-side from `contentHtml` | No quote endpoint. |
| leaveConversationAsync | Ext | Ext | `PATCH` `recipientUsers` without self | Dialogs can't be left. |
| markConversationUnreadAsync | No | No | — | Read state only moves forward. |
| markConversationReadAsync | Core | Core | `lastReadPostNumber`; dialogs `lastReadMessageId` | |
| closeConversationAsync | Partial | Partial | `isLocked=true` (flarum/lock) | Moderators only by default. |
| uncloseConversationAsync | Partial | Partial | `isLocked=false` | Same. |
| archiveConversationAsync | No | No | — | No archive. |
| unarchiveConversationAsync | No | No | — | No archive. |
| getRawConversationAsync | Core | Core | `GET /api/discussions/{id}` | `canEditUserRecipients` stands in for open invite. |
| saveRawConversationAsync | Partial | Partial | `PATCH` `title` and `isLocked` | Rename: author only, 10 minutes by default. |
| getRawMessageAsync | Core | Core | `GET /api/posts/{id}` `content` | Dialog message content is hidden. |
| saveRawMessageAsync | Core | Core | `PATCH /api/posts/{id} {content}` | Dialog messages can't be edited. |

### IFCPrivateMessageProxy
XenForo-style inbox and sent boxes don't exist; as in discourse_core, these fail fast and point to
the conversation proxy.

| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| reportPmAsync | Ext | Ext | `POST /api/flags` (flarum/flags) | byobu posts only; dialog messages can't be flagged. |
| createMessageAsync | n/a | n/a | Fail-fast shim | |
| getBoxInfoAsync | n/a | n/a | Shim | |
| getBoxAsync | n/a | n/a | Shim | |
| getMessageAsync | n/a | n/a | Shim | |
| getQuotePmAsync | n/a | n/a | Shim | |
| deleteMessageAsync | n/a | n/a | Shim | 2.0 dialogs: `DELETE /api/dialog-messages/{id}`, if allowed. |
| markPmUnreadAsync | No | No | — | |
| markPmReadAsync | n/a | n/a | Shim | |

## Moderation and groups

### IFCModerationProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| doLoginModAsync | n/a | n/a | — | The token carries the permissions. |
| stickTopicAsync | Ext | Ext | `PATCH` discussion `isSticky` (flarum/sticky) | |
| unstickTopicAsync | Ext | Ext | Same | |
| closeTopicAsync | Ext | Ext | `isLocked` (flarum/lock) | |
| uncloseTopicAsync | Ext | Ext | Same | |
| deleteTopicAsync | Core | Core | Soft: `isHidden`; hard: `DELETE /api/discussions/{id}` | No reason field. |
| deletePostAsync | Core | Core | Soft: `isHidden`; hard: `DELETE /api/posts/{id}` | No reason field. |
| undeleteTopicAsync | Core | Core | `isHidden=false` | Hard deletes are final. |
| undeletePostAsync | Core | Core | `isHidden=false` | Also approves the post. |
| moveTopicAsync | Ext | Ext | `PATCH` discussion `tags` | Tag rules apply. |
| renameTopicAsync | Core | Core | `PATCH` discussion `title` | Adds an event post. |
| movePostAsync | Partial | Partial | `POST /api/split` (fof/split, not installed) | New discussion only. Unverified. |
| mergeTopicAsync | Ext | Ext | `POST /api/discussions/{id}/merge` (fof/merge-discussions, not installed) | Unverified. |
| getModerateTopicAsync | Ext | Ext | `GET /api/flags`, approval flags on first posts | Client-side filter; needs `viewFlags`. |
| getModeratePostAsync | Ext | Ext | `GET /api/flags`, approval flags on replies | Same. |
| getDeletedTopicAsync | Core | Core | 1.8 `q=is:hidden`; 2.0 `filter[hidden]=1` | |
| getDeletedPostAsync | No | No | — | No post filter for it. |
| getReportedPostAsync | Ext | Ext | `GET /api/flags`, user flags | 1.8 unpaged; listing marks flags read. |
| approveTopicAsync | Ext | Ext | `PATCH` first post `isApproved` (flarum/approval) | |
| approvePostAsync | Ext | Ext | `PATCH /api/posts/{id} {isApproved: true}` | |
| banUserAsync | Ext | Ext | `PATCH /api/users/{id}` `suspendedUntil`, reason, message (flarum/suspend) | |
| unbanUserAsync | Ext | Ext | `suspendedUntil=null` | |
| markAsSpamAsync | Ext | Partial | 1.8 fof/spamblock (not installed); 2.0 suspend only | No spamblock for 2.0. |
| spamCleanUserAsync | Partial | Partial | flarum/gdpr deletion | No IP block. |
| archiveTopicAsync | n/a | n/a | — | Lock is the nearest. |
| setTopicVisibilityAsync | n/a | n/a | — | No unlisted state. |
| deleteTopicExtendedAsync | Core | Core | Hard delete or `isHidden` | |

### IFCGroupProxy
| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| getGroupsAsync | Core | Core | `GET /api/groups` | |
| getGroupAsync | Partial | Partial | `GET /api/groups/{id}`; name matched client-side | No bio or member count. |
| getGroupMembersAsync | Core | Core | `GET /api/users?filter[group]=…` | Needs `searchUsers`. |
| joinGroupAsync | No | No | — | Groups are permission roles. |
| leaveGroupAsync | No | No | — | |
| requestMembershipAsync | No | No | — | |

## Chat and devices

### IFCChatProxy
Nothing on 1.8. On 2.0, ramon/chat (new; read from source, not installed) or flarum/messages
dialogs as a fallback. Out of scope for v1, as the plan says.

| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| getMyChannelsAsync | No | Ext | ramon/chat `GET /api/chat-channels` | Unverified. |
| getChannelAsync | No | Ext | `GET /api/chat-channels/{id}` | Unverified. |
| getMessagesAsync | No | Ext | `GET /api/chat-messages?filter[channel]=…` | Unverified. |
| pollNewerAsync | No | Ext | `filter[greaterThan]=lastId` | Unverified. |
| sendMessageAsync | No | Ext | `POST /api/chat-messages` | Unverified. |
| editMessageAsync | No | Ext | `PATCH /api/chat-messages/{id}` | Unverified. |
| deleteMessageAsync | No | Ext | `POST /api/chat-messages/{id}/delete` | Unverified. |
| markChannelReadAsync | No | Ext | `POST /api/chat-channels/{id}/read` | Unverified. |

### IFCDeviceProxy
The forum has no device or push endpoint; push goes through our own server (plan §7).

| Method | 1.8 | 2.0 | How | Notes |
|---|---|---|---|---|
| registerDeviceAsync | n/a | n/a | No-op; the app registers with our push server | |
| updateDeviceTokenAsync | n/a | n/a | No-op | |
| unregisterDeviceAsync | n/a | n/a | No-op; the server stops polling at sign-out | |
