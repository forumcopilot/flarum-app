<?php
/*
 * Fills a seeded test forum (seed.php) with a community: the members, tags and discussions in
 * community.json, posted through the REST API as the members themselves, then dated in the
 * database between late August and 6 October 2026, before the test seed's own content.
 *
 * Usage: php community_seed.php <forum url> <credentials file> <images dir> <ids output file>
 *
 * The credentials file is seed.php's (ADMIN_USER, ADMIN_PASS, DB_USER, DB_PASS, DB_V1, DB_V2).
 * <images dir> holds the pictures community.json names, as <key>.jpg; any that's missing is
 * downloaded from Wikimedia Commons (1280 px wide). Each post credits its picture. The members get random passwords, appended as MEMBER_<NAME>=…
 * lines to the credentials file, which is kept out of the repository.
 *
 * Nothing here touches alice, bob or carol, the tags alice follows (support, feedback), or the
 * words the fixture tests search for, and everything is dated before the test seed: the
 * fixtures' data (alice's notifications and read state, the latest list's first page) stays as
 * recorded. Refuses to run twice on the same forum (it checks for the member "maya").
 */

require __DIR__.'/api.php';

[, $base, $credentialsFile, $imagesDir, $idsFile] = $argv + [null, '', '', '', ''];
$base = rtrim($base, '/');
if ($base === '' || $credentialsFile === '' || $imagesDir === '' || $idsFile === '') {
    fwrite(STDERR, "usage: php community_seed.php <forum url> <credentials file> <images dir> <ids output file>\n");
    exit(1);
}

$creds = [];
foreach (file($credentialsFile, FILE_IGNORE_NEW_LINES) as $line) {
    if (preg_match('/^([A-Z0-9_]+)=(.*)$/', $line, $m)) {
        $creds[$m[1]] = $m[2];
    }
}
$content = json_decode(file_get_contents(__DIR__.'/community.json'), true, flags: JSON_THROW_ON_ERROR);
$step = fn (string $msg) => print("  $msg\n");

$v = isset(api('GET', '/api')['data']['attributes']['jsChunksBaseUrl']) ? 2 : 1;
echo "Adding the community to $base (Flarum $v.x)\n";
[$admin, $adminId] = login($creds['ADMIN_USER'], $creds['ADMIN_PASS']);

if (api('GET', '/api/users?filter%5Bq%5D=maya', null, $admin)['data'] ?? []) {
    fwrite(STDERR, "The member maya exists: this forum has its community already. Nothing done.\n");
    exit(1);
}

// Plan every post's time first, and refuse anything that would land on or after the test seed.
$testSeed = new DateTimeImmutable('2026-10-08 00:00:00', new DateTimeZone('UTC'));
foreach ($content['discussions'] as $d => $discussion) {
    $time = new DateTimeImmutable($discussion['start'], new DateTimeZone('UTC'));
    foreach ($discussion['posts'] as $p => $post) {
        $time = $time->modify('+'.(int) round(($post['after'] ?? ($p === 0 ? 0 : 3)) * 60).' minutes');
        if ($time >= $testSeed) {
            fwrite(STDERR, "\"{$discussion['title']}\" post ".($p + 1)." would be dated {$time->format('c')}, after the test seed.\n");
            exit(1);
        }
        $content['discussions'][$d]['posts'][$p]['at'] = $time;
    }
}

// Every public discussion needs exactly one top-level primary tag (the forum's rule), and a child
// tag its parent: checked before anything is written.
$tags = [];
foreach (api('GET', '/api/tags?include=parent', null, $admin)['data'] ?? [] as $t) {
    $tags[$t['attributes']['slug']] = $t;
}
$kind = [];
foreach ($tags as $slug => $t) {
    $parent = $t['relationships']['parent']['data']['id'] ?? null;
    $kind[$slug] = ($t['attributes']['position'] ?? null) === null ? 'secondary'
        : ($parent === null ? 'primary' : 'child:'.array_search($parent, array_map(fn ($x) => $x['id'], $tags)));
}
foreach ($content['tags'] as $tag) {
    $kind[$tag['slug']] = !$tag['primary'] ? 'secondary' : (isset($tag['parent']) ? 'child:'.$tag['parent'] : 'primary');
}
foreach ($content['discussions'] as $discussion) {
    if (isset($discussion['private_with'])) {
        continue;
    }
    foreach (array_filter([$discussion['tags'], $discussion['tags_before'] ?? null]) as $set) {
        $primary = count(array_filter($set, fn ($s) => ($kind[$s] ?? null) === 'primary'));
        $orphans = array_filter($set, fn ($s) => str_starts_with($kind[$s] ?? '', 'child:') && !in_array(substr($kind[$s], 6), $set, true));
        $unknown = array_diff($set, array_keys($kind));
        if ($unknown) {
            fwrite(STDERR, "\"{$discussion['title']}\": unknown tag ".implode(', ', $unknown).".\n");
            exit(1);
        }
        if ($primary !== 1 || $orphans) {
            fwrite(STDERR, "\"{$discussion['title']}\": needs one primary tag, and each child tag with its parent.\n");
            exit(1);
        }
    }
}

const MEMBERS = 3;
setPermission($admin, 'postWithoutThrottle', [MEMBERS]);
// Members' full names, through flarum/nicknames.
api('POST', '/api/settings', ['display_name_driver' => 'nickname'], $admin);
$step('nicknames on, posting throttle lifted');

// Tags, appended after the forum's own in the tag order.
$ids = ['tags' => [], 'users' => [], 'discussions' => []];
foreach ($content['tags'] as $tag) {
    $attributes = ['name' => $tag['name'], 'slug' => $tag['slug'], 'color' => $tag['color'],
        'icon' => $tag['icon'], 'description' => $tag['description']];
    if ($tag['primary']) {
        $attributes[$v === 2 ? 'isPrimary' : 'primary'] = true;
    }
    $ids['tags'][$tag['slug']] = api('POST', '/api/tags', ['data' => ['type' => 'tags', 'attributes' => $attributes]], $admin)['data']['id'];
}
$tagId = fn (string $slug) => $ids['tags'][$slug] ?? $tags[$slug]['id'] ?? throw new RuntimeException("no tag $slug");
$order = [];
$existingPrimary = array_filter($tags, fn ($t) => ($t['attributes']['position'] ?? null) !== null && !($t['attributes']['isChild'] ?? false));
uasort($existingPrimary, fn ($a, $b) => $a['attributes']['position'] <=> $b['attributes']['position']);
foreach ($existingPrimary as $t) {
    $children = array_values(array_map(fn ($c) => $c['id'], array_filter($tags,
        fn ($c) => ($c['relationships']['parent']['data']['id'] ?? null) === $t['id'])));
    $order[] = ['id' => $t['id'], 'children' => $children];
}
foreach ($content['tags'] as $tag) {
    if ($tag['primary'] && !isset($tag['parent'])) {
        $children = array_values(array_map(fn ($c) => $ids['tags'][$c['slug']],
            array_filter($content['tags'], fn ($c) => ($c['parent'] ?? null) === $tag['slug'])));
        $order[] = ['id' => $ids['tags'][$tag['slug']], 'children' => $children];
    }
}
api('POST', '/api/tags/order', ['order' => $order], $admin);
$db = new PDO('mysql:host=localhost;dbname='.$creds["DB_V$v"], $creds['DB_USER'], $creds['DB_PASS']);
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
foreach ($content['tags'] as $tag) {
    if (!empty($tag['qna'])) {
        // fof/best-answer's per-tag switch; 1.x sets it from the admin settings page only.
        $db->prepare('UPDATE tags SET is_qna = 1 WHERE id = ?')->execute([$ids['tags'][$tag['slug']]]);
    }
}
$step('tags: '.implode(', ', array_keys($ids['tags'])));

// Members, with random passwords kept in the credentials file.
$members = ['admin' => ['token' => $admin, 'id' => $adminId, 'name' => $creds['ADMIN_USER']]];
$saved = '';
foreach ($content['users'] as [$username, $name]) {
    $password = bin2hex(random_bytes(12));
    api('POST', '/api/users', ['data' => ['type' => 'users', 'attributes' => [
        'username' => $username,
        'email' => "$username@flarumapp.local",
        'password' => $password,
        'isEmailConfirmed' => true,
    ]]], $admin);
    [$token, $id] = login($username, $password);
    patch($admin, 'users', $id, ['nickname' => $name]);
    $members[$username] = ['token' => $token, 'id' => $id, 'name' => $name];
    $ids['users'][$username] = $id;
    $saved .= 'MEMBER_V'.$v.'_'.strtoupper($username)."=$password\n";
}
file_put_contents($credentialsFile, $saved, FILE_APPEND);
$step(count($content['users']).' members (passwords appended to the credentials file)');

// Pictures, uploaded through fof/upload by whoever first posts them.
$pictures = [];
$picture = function (string $key, string $as) use (&$pictures, $content, $imagesDir, $members): string {
    if (!isset($pictures[$key])) {
        $image = $content['images'][$key];
        if (!is_file("$imagesDir/$key.jpg")) {
            @mkdir($imagesDir, 0755, true);
            $ch = curl_init('https://commons.wikimedia.org/wiki/Special:FilePath/'.rawurlencode($image['file']).'?width=1280');
            curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_USERAGENT => 'flarum-app test forum seed (+https://github.com/forumcopilot/flarum-app)']);
            $bytes = curl_exec($ch);
            if (curl_getinfo($ch, CURLINFO_RESPONSE_CODE) !== 200 || !str_starts_with((string) curl_getinfo($ch, CURLINFO_CONTENT_TYPE), 'image/jpeg')) {
                throw new RuntimeException("couldn't download {$image['file']} from Wikimedia Commons");
            }
            file_put_contents("$imagesDir/$key.jpg", $bytes);
        }
        $upload = api('POST', '/api/fof/upload', null, $members[$as]['token'],
            ['files[]' => new CURLFile("$imagesDir/$key.jpg", 'image/jpeg', "$key.jpg")]);
        $file = $upload['data'][0]['attributes'] ?? [];
        $markup = $file['bbcode'] ?? "![$key]({$file['url']})";
        $page = 'https://commons.wikimedia.org/wiki/File:'.rawurlencode($image['file']);
        $pictures[$key] = "$markup\n\n*Photo: {$image['by']}, {$image['license']}, via [Wikimedia Commons]($page)*";
    }

    return $pictures[$key];
};

// Discussions: posted, liked, then renamed, retagged, answered, locked and pinned as written.
foreach ($content['discussions'] as $discussion) {
    $postIds = [];
    $authors = [];
    $resolve = function (string $text, string $author) use (&$postIds, &$authors, $members, $picture): string {
        $text = preg_replace_callback('/\{\{p:(\d+)\}\}/', fn ($m) =>
            '@"'.$members[$authors[$m[1] - 1]]['name'].'"#p'.$postIds[$m[1] - 1], $text);
        $text = preg_replace_callback('/\{\{u:(\w+)\}\}/', fn ($m) =>
            '@"'.$members[$m[1]]['name'].'"#'.$members[$m[1]]['id'], $text);

        return preg_replace_callback('/\{\{img:(\w+)\}\}/', fn ($m) => $picture($m[1], $author), $text);
    };
    $first = $discussion['posts'][0];
    [$discussionId, $firstPostId] = startDiscussion(
        $members[$first['by']]['token'],
        $discussion['renamed_from'] ?? $discussion['title'],
        $resolve($first['text'], $first['by']),
        array_map($tagId, $discussion['tags_before'] ?? $discussion['tags']),
        array_map(fn ($u) => $members[$u]['id'], $discussion['private_with'] ?? []),
    );
    $postIds[] = $firstPostId;
    $authors[] = $first['by'];
    foreach (array_slice($discussion['posts'], 1) as $post) {
        $postIds[] = reply($members[$post['by']]['token'], $discussionId, $resolve($post['text'], $post['by']));
        $authors[] = $post['by'];
    }
    foreach ($discussion['posts'] as $i => $post) {
        foreach ($post['likes'] ?? [] as $liker) {
            patch($members[$liker]['token'], 'posts', $postIds[$i], ['isLiked' => true]);
        }
    }
    if (isset($discussion['renamed_from'])) {
        patch($admin, 'discussions', $discussionId, ['title' => $discussion['title']]);
    }
    if (isset($discussion['tags_before'])) {
        // `attributes`, even empty: 2.0 rc.8's flarum/subscriptions fails (500) on an update without it.
        api('PATCH', "/api/discussions/$discussionId", ['data' => ['type' => 'discussions', 'id' => $discussionId,
            'attributes' => new stdClass(),
            'relationships' => ['tags' => ['data' => array_map(fn ($s) => ref('tags', $tagId($s)), $discussion['tags'])]]]], $admin);
    }
    if (isset($discussion['best'])) {
        $best = $postIds[$discussion['best'] - 1];
        $data = ['type' => 'discussions', 'id' => $discussionId, 'attributes' => new stdClass()];
        if ($v === 2) {
            $data['relationships'] = ['bestAnswerPost' => ['data' => ref('posts', $best)]];
        } else {
            $data['attributes'] = ['bestAnswerPostId' => $best];
        }
        api('PATCH', "/api/discussions/$discussionId", ['data' => $data], $admin);
    }
    if (!empty($discussion['locked'])) {
        patch($admin, 'discussions', $discussionId, ['isLocked' => true]);
    }
    if (!empty($discussion['sticky'])) {
        patch($admin, 'discussions', $discussionId, ['isSticky' => true]);
    }

    // Dates: each comment as planned, each event post a quarter of an hour after the post before it.
    $times = [];
    $planned = array_map(fn ($p) => $p['at'], $discussion['posts']);
    $rows = $db->prepare('SELECT id, type FROM posts WHERE discussion_id = ? ORDER BY number');
    $rows->execute([$discussionId]);
    $previous = $planned[0];
    foreach ($rows->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $at = $row['type'] === 'comment' ? array_shift($planned) : $previous->modify('+15 minutes');
        $times[$row['id']] = $previous = $at;
    }
    $update = $db->prepare('UPDATE posts SET created_at = ? WHERE id = ?');
    foreach ($times as $id => $at) {
        $update->execute([$at->format('Y-m-d H:i:s'), $id]);
    }
    $last = end($discussion['posts'])['at'];
    $db->prepare('UPDATE discussions SET created_at = ?, last_posted_at = ? WHERE id = ?')
        ->execute([$discussion['posts'][0]['at']->format('Y-m-d H:i:s'), $last->format('Y-m-d H:i:s'), $discussionId]);
    $ids['discussions'][$discussion['title']] = $discussionId;
    $step("\"{$discussion['title']}\": ".count($postIds).' posts');
}

// Members joined a few days before their first post, and were last seen after their last one.
foreach ($ids['users'] as $username => $id) {
    $posts = $db->prepare('SELECT MIN(created_at), MAX(created_at) FROM posts WHERE user_id = ?');
    $posts->execute([$id]);
    [$firstAt, $lastAt] = $posts->fetch(PDO::FETCH_NUM);
    if ($firstAt === null) {
        continue;
    }
    $db->prepare('UPDATE users SET joined_at = DATE_SUB(?, INTERVAL ? DAY), last_seen_at = DATE_ADD(?, INTERVAL ? HOUR) WHERE id = ?')
        ->execute([$firstAt, random_int(2, 9), $lastAt, random_int(1, 20), $id]);
}
// Each new tag's latest activity, which the API set to now.
foreach ($ids['tags'] as $id) {
    $db->prepare('UPDATE tags SET last_posted_at = (SELECT MAX(d.last_posted_at) FROM discussions d
        JOIN discussion_tag dt ON dt.discussion_id = d.id WHERE dt.tag_id = ?) WHERE id = ?')->execute([$id, $id]);
}

setPermission($admin, 'postWithoutThrottle', []);
file_put_contents($idsFile, json_encode($ids, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."\n");
echo "Done. Ids written to $idsFile\n";
