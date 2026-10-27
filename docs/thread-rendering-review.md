# Thread rendering review: the app against discuss.flarum.org

27 Oct 2026. Tung asked for a review of how threads render, against the web, on the official
community (discuss.flarum.org, Flarum 2.0). Three passes:

1. **Inventory.** A guest read of the first 20 posts of 375 discussions (4,706 posts), listing
   every HTML element, class, attribute and embed host in their `contentHtml`: 289 features.
2. **Side by side.** For each less common feature, the shortest post that has it (63 posts).
   Each was drawn by the app's renderer (flarum_ui's screenshot test, real fonts, 412 px wide) and
   by the web (Chrome at a phone's width, as a guest).
3. **On the phone.** Whole threads in Flapp on a Pixel 4a, against the same posts on the web:
   post headers and footers, the best answer, member cards, event posts.

The scripts are in `tool/render_compare/discuss/`. Rerun them to check fixes.

Most of a thread already matches the web: paragraphs, headings, lists, quotes with and without a
citation, user and post mentions, tag mentions, tables, task lists, block spoilers, coloured and
centred text, YouTube, pictures and uploads, code blocks with highlighting, event posts, likes,
replies and the best answer. What doesn't match is below, most visible first. "Posts" counts
how many of the 4,706 have it.

## Fixed

- **27 Oct, the text group (#1, #2, #3, #8):**
  - Inline code is text on a tint, which wraps with its sentence.
  - Discussion and GitHub links are pills (`LinkPillExtension`, `render/link_pills.dart`). Each keeps its whole width, and moves to the next line when it doesn't fit.
  - Mentions of deleted users and posts are muted pills that go nowhere.

  Checked against the web with the compare tools and on the Pixel 4a.

## In the post's text

| # | What | Posts | App | Web | Fix |
| --- | --- | --- | --- | --- | --- |
| 1 | Inline code | 639 | Each `code` is a chip that can't break. One that doesn't fit jumps to its own line and leaves a gap; a long one becomes a block; a "." or ")" after it can start a line on its own. | Wraps with the sentence. | Draw inline code as styled text (monospace on a tinted background) inside the paragraph's own text, not as a widget. |
| 2 | Discussion links with a favicon (`a.UrlLink--discussion`) | 118 | The favicon is drawn as a full-size picture, and a linked post's number runs into the discussion's ("#4011" + "13" → "#401113"). | A small pill: favicon, "#4011", then a comment icon and the post's number. | Draw `UrlLink--discussion` and `UrlLink-post` as a pill: the favicon at text size, the discussion, the post. |
| 3 | GitHub links (`a.Github-embed`: repo, path, PR, issue, release, commit, compare) | 180 | Plain link text, parts run together: "anti-spam4", "azerbaijanitree/2.x", "velvet-rope1.0.0 1.0.1". | A pill: GitHub icon, repo in bold, then the path, PR or issue number, tag or commit, or "1.0.0 → 1.0.1", with their icons. | Draw `Github-embed` as a pill, with a space or icon between its parts (the Font Awesome icons mapped to Material ones). |
| 4 | SVG pictures (shields.io badges, SVG logos, the forum's own SVG emoji) | 184 | On the phone a badge is drawn garbled, or as a full-width "broken picture" box with its alt text. Badges stack, one per line. | Small badges side by side, in the line. | Ask shields.io for PNG (raster.shields.io). Lay out small pictures inline, at their own size. A badge that fails shows its alt text inline, not a full-width box. |
| 5 | Uploaded videos (`video`) | 4 | A black box with a play button. | The first frame and the player's controls. | Show the first frame (a thumbnail from the video, or `poster`). |
| 6 | Code blocks | 680 | The copy button sits over the first line, and the line's text runs under it. | No button; the text is clear. | Keep the button out of the text: a header row, or padding on the right of the first line. |
| 7 | Numbered lists in two parts (`ol start`) | 4 | The second part starts again at 1. | It continues at 2. | Honour `start`. |
| 8 | Mentions of deleted users or posts (`span.UserMention--deleted`, `PostMention--deleted`) | 30 | Plain text "@[deleted]", "[unknown]". | A muted pill. | Draw them as mention pills, muted, not tappable. |
| 9 | A spoiler with its own title (`details.spoiler` with a `summary`) | 7 | Always titled "Spoiler". | Its title ("Details"). | Use the `summary` when there is one. |
| 10 | fof/upload text-file previews (`figure.FofUpload-TextPreview`) | 1 | Loose pieces: a narrow code box under the copy button, a hidden "Error previewing file…" message shown, a "Download file" link. | A card with the file's name, its first lines and Download. | Turn it into the attachment card, with the snippet. |
| 11 | Giphy, Streamable, Spotify and Pastebin embeds | 34 s9e embeds, few of these | A plain link card. | The GIF, the video's frame, a player, the paste. | Giphy: show the GIF (`media.giphy.com/media/{id}/giphy.gif`). Streamable: its thumbnail, with a play button that opens it. The rest can stay cards. |
| 12 | Pictures that fail to load | – | An SVG that fails shows nothing; other pictures show a box. Neither shows the alt text. | The browser's broken-picture icon and the alt text. | One fallback for both: the alt text, muted, where it has one. |
| 13 | Attachments for guests (`canDownloadFiles` false) | – | Offers Download, which the forum refuses. | "Permission required". | Read the discussion's `canDownloadFiles`. Without it, show the card without Download, with the web's words. |
| 14 | Tag mentions of tags with an icon (`a.TagMention`) | 8 | Some lack the tag's icon ("Bounty"). | Icon and name. | Take the icon from the forum's tags when the mention's HTML has none. |

## Around the post

| # | What | App | Web | Fix |
| --- | --- | --- | --- | --- |
| 15 | Group badges on posts | Only on the member card. | Each author's group badges (Flarum Team, Moderator, Translator) beside their avatar or name, on every post. | Include `user.groups` with the posts and show the badges in the post header, small, as ABDA shows flair. |
| 16 | Country flags (fof/geoip) | None. | A flag beside the author's name. | Read the post's `ipInfo` where the forum sends it, and show the flag after the name. |
| 17 | Member bios (fof/user-bio) | Not on the card or the profile. | On the card and the profile. | Show `bioHtml` on the member card (a few lines) and on the profile. |
| 18 | The best answer | A preview of a few lines under the first post. | The whole answer under the first post. | A matter of choice. The preview opens the answer; it can stay. |

Not compared: post votes (fof/gamification), which a guest can't see, and polls, which no recent
discussion on discuss.flarum.org has.

## Order of work

1. **Text:** inline code (#1), and the pills for discussion links (#2), GitHub links (#3) and
   deleted mentions (#8). Together that's about 900 of the 4,706 posts, and they're all in the
   renderer's inline layout, so one change covers them.
2. **Pictures:** SVG badges and small pictures inline (#4), fallbacks (#12), video frames (#5).
3. **Code blocks:** the copy button (#6) and text previews (#10).
4. **Around the post:** group badges (#15), flags (#16), bios (#17). They need the posts' API
   request to include more, and fixtures recorded for it.
5. **The rest:** list `start` (#7), spoiler titles (#9), Giphy and Streamable (#11), guests'
   downloads (#13), tag icons (#14).
