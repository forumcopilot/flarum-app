<?php
/*
 * Seeds a local Flarum 1.8 or 2.0 test forum with demo content through its REST API,
 * so flarum-app has realistic data (tags, users, mentions, uploads, PMs, a long thread)
 * on both versions.
 *
 * Usage: php tool/test_forums/seed.php <forum url> <credentials file> <ids output file>
 *
 * The credentials file holds KEY=value lines: ADMIN_USER, ADMIN_PASS, TEST_USER_PASS
 * (the password given to alice, bob and carol), and DB_USER, DB_PASS, DB_V1, DB_V2
 * (MySQL on localhost, used only to space out post times). Keep it out of the repo.
 * The ids of everything created are written to the output file, which
 * packages/flarum_core/tool/record_fixtures.dart reads.
 * Refuses to run twice on the same forum (it checks for the user "alice").
 */

[, $base, $credentialsFile, $idsFile] = $argv + [null, '', '', ''];
$base = rtrim($base, '/');
if ($base === '' || $credentialsFile === '' || $idsFile === '') {
    fwrite(STDERR, "usage: php seed.php <forum url> <credentials file> <ids output file>\n");
    exit(1);
}

$creds = [];
foreach (file($credentialsFile, FILE_IGNORE_NEW_LINES) as $line) {
    if (preg_match('/^([A-Z_]+)=(.*)$/', $line, $m)) {
        $creds[$m[1]] = $m[2];
    }
}

function api(string $method, string $path, ?array $body = null, ?string $token = null, ?array $multipart = null): array
{
    global $base;
    $headers = ['Accept: application/vnd.api+json'];
    if ($token) {
        $headers[] = "Authorization: Token $token";
    }
    $ch = curl_init($base.$path);
    if ($multipart !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, $multipart);
    } elseif ($body !== null) {
        $headers[] = 'Content-Type: application/vnd.api+json';
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
    }
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
    ]);
    $raw = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);
    if ($code >= 400) {
        throw new RuntimeException("$method $path -> HTTP $code: ".substr((string) $raw, 0, 400));
    }

    return json_decode((string) $raw, true) ?? [];
}

function login(string $identification, string $password): array
{
    $r = api('POST', '/api/token', ['identification' => $identification, 'password' => $password]);

    return [$r['token'], (string) $r['userId']];
}

function ref(string $type, string $id): array
{
    return ['type' => $type, 'id' => $id];
}

function startDiscussion(string $token, string $title, string $content, array $tagIds = [], array $recipientIds = []): array
{
    $relationships = [];
    if ($tagIds) {
        $relationships['tags'] = ['data' => array_map(fn ($id) => ref('tags', $id), $tagIds)];
    }
    if ($recipientIds) {
        $relationships['recipientUsers'] = ['data' => array_map(fn ($id) => ref('users', $id), $recipientIds)];
    }
    $data = ['type' => 'discussions', 'attributes' => ['title' => $title, 'content' => $content]];
    if ($relationships) {
        $data['relationships'] = $relationships;
    }
    $r = api('POST', '/api/discussions', ['data' => $data], $token);
    $firstPostId = $r['data']['relationships']['firstPost']['data']['id']
        ?? $r['data']['relationships']['posts']['data'][0]['id'] ?? null;

    return [$r['data']['id'], $firstPostId];
}

function reply(string $token, string $discussionId, string $content): string
{
    $r = api('POST', '/api/posts', ['data' => [
        'type' => 'posts',
        'attributes' => ['content' => $content],
        'relationships' => ['discussion' => ['data' => ref('discussions', $discussionId)]],
    ]], $token);

    return $r['data']['id'];
}

function patch(string $token, string $type, string $id, array $attributes): void
{
    api('PATCH', "/api/$type/$id", ['data' => ['type' => $type, 'id' => $id, 'attributes' => $attributes]], $token);
}

function setPermission(string $token, string $permission, array $groupIds): void
{
    api('POST', '/api/permission', ['permission' => $permission, 'groupIds' => $groupIds], $token);
}

$step = fn (string $msg) => print("  $msg\n");

$forum = api('GET', '/api')['data']['attributes'];
$v = isset($forum['jsChunksBaseUrl']) ? 2 : 1;
echo "Seeding $base (Flarum $v.x)\n";

[$admin, $adminId] = login($creds['ADMIN_USER'], $creds['ADMIN_PASS']);

try {
    login('alice', $creds['TEST_USER_PASS']);
    fwrite(STDERR, "alice already exists: this forum looks seeded already. Nothing done.\n");
    exit(1);
} catch (RuntimeException $e) {
    // Not seeded yet.
}

// This server can't send mail; write emails (notifications, PM alerts) to storage/logs instead.
api('POST', '/api/settings', ['mail_driver' => 'log'], $admin);

const MEMBERS = 3;
// Lift the 10-second posting throttle while seeding; restored at the end.
setPermission($admin, 'postWithoutThrottle', [MEMBERS]);
// Members can upload and start private discussions, as on forums that run these extensions.
setPermission($admin, 'fof-upload.upload', [MEMBERS]);
setPermission($admin, 'discussion.startPrivateDiscussionWithUsers', [MEMBERS]);
$step('permissions set');

// Tags: three primary tags, one child tag, two secondary tags.
$tags = [];
$makeTag = function (string $name, string $slug, string $color, string $icon, bool $primary) use ($admin, $v, &$tags) {
    $attributes = ['name' => $name, 'slug' => $slug, 'color' => $color, 'icon' => $icon, 'description' => "$name discussions"];
    if ($primary) {
        $attributes[$v === 2 ? 'isPrimary' : 'primary'] = true;
    }
    $tags[$slug] = api('POST', '/api/tags', ['data' => ['type' => 'tags', 'attributes' => $attributes]], $admin)['data']['id'];
};
$existing = api('GET', '/api/tags', null, $admin)['data'] ?? [];
foreach ($existing as $t) {
    $tags[$t['attributes']['slug']] = $t['id'];
}
$makeTag('Support', 'support', '#e67e22', 'fas fa-life-ring', true);
$makeTag('iOS', 'ios', '#7f8c8d', 'fab fa-apple', true);
$makeTag('Feedback', 'feedback', '#27ae60', 'fas fa-lightbulb', true);
$makeTag('Announcements', 'announcements', '#c0392b', 'fas fa-bullhorn', true);
$makeTag('question', 'question', '#8e44ad', '', false);
$makeTag('bug', 'bug', '#d35400', '', false);
$general = $tags['general'] ?? reset($tags);
// Nest iOS under Support through the ordering endpoint the admin UI uses. Setting a parent on
// create doesn't work on 2.0 rc.8: TagResource looks for attributes.isPrimary outside `data`.
api('POST', '/api/tags/order', ['order' => [
    ['id' => $general, 'children' => []],
    ['id' => $tags['support'], 'children' => [$tags['ios']]],
    ['id' => $tags['feedback'], 'children' => []],
    ['id' => $tags['announcements'], 'children' => []],
]], $admin);
$step('tags: '.implode(', ', array_keys($tags)));

// Users.
$users = [];
foreach (['alice', 'bob', 'carol'] as $name) {
    api('POST', '/api/users', ['data' => ['type' => 'users', 'attributes' => [
        'username' => $name,
        'email' => "$name@flarumapp.local",
        'password' => $creds['TEST_USER_PASS'],
        'isEmailConfirmed' => true,
    ]]], $admin);
    $users[$name] = login($name, $creds['TEST_USER_PASS']);
}
[$alice, $aliceId] = $users['alice'];
[$bob, $bobId] = $users['bob'];
[$carol, $carolId] = $users['carol'];
$step('users: alice, bob, carol');

// An image upload through fof/upload.
$png = tempnam(sys_get_temp_dir(), 'seed').'.png';
$img = imagecreatetruecolor(320, 200);
imagefill($img, 0, 0, imagecolorallocate($img, 59, 90, 133));
imagestring($img, 5, 90, 90, 'flarum-app test', imagecolorallocate($img, 255, 255, 255));
imagepng($img, $png);
$upload = api('POST', '/api/fof/upload', null, $alice, ['files[]' => new CURLFile($png, 'image/png', 'screenshot.png')]);
unlink($png);
$file = $upload['data'][0]['attributes'] ?? [];
$imageMarkup = $file['bbcode'] ?? (isset($file['url']) ? "![screenshot]({$file['url']})" : '');
$step('upload: '.($file['url'] ?? 'no url in response'));

$ids = ['version' => $v, 'base' => $base, 'tags' => $tags, 'users' => ['admin' => $adminId, 'alice' => $aliceId, 'bob' => $bobId, 'carol' => $carolId]];

// 1. Pinned, locked announcement.
[$d, $p] = startDiscussion($admin, 'Forum rules', "Be kind. Stay on topic.\n\nThis discussion is **sticky** and **locked**.", [$tags['announcements']]);
patch($admin, 'discussions', $d, ['isSticky' => true]);
patch($admin, 'discussions', $d, ['isLocked' => true]);
$ids['discussions']['rules'] = $d;

// 2. Welcome thread: user mentions, a post mention (quote), likes.
[$d, $p1] = startDiscussion($admin, 'Welcome to the test forum', "Introduce yourself here. Markdown works: *italic*, `code`, [a link](https://flarum.org).", [$general]);
$p2 = reply($alice, $d, "Hi all! Looking forward to testing with @\"bob\"#$bobId and @\"carol\"#$carolId.");
$p3 = reply($bob, $d, "@\"alice\"#p$p2 Welcome! I'll take the iOS side.");
$p4 = reply($carol, $d, "> Quoted text keeps working too.\n\nHello from carol. Thanks @\"admin\"#$adminId.");
patch($bob, 'posts', $p2, ['isLiked' => true]);
patch($carol, 'posts', $p2, ['isLiked' => true]);
patch($alice, 'posts', $p3, ['isLiked' => true]);
$ids['discussions']['welcome'] = $d;
$ids['posts']['welcome'] = [$p1, $p2, $p3, $p4];

// 3. Support thread with the upload, a child tag and a secondary tag.
[$d, $p1] = startDiscussion($alice, 'App crashes when opening a long thread', "Steps: open any thread with 50+ replies.\n\n$imageMarkup", [$tags['support'], $tags['ios'], $tags['bug']]);
$p2 = reply($carol, $d, "@\"alice\"#p$p1 Same here on iOS 26. Does it happen on Android?");
$ids['discussions']['support'] = $d;
$ids['posts']['support'] = [$p1, $p2];

// 4. Feedback thread that alice follows.
[$d, $p1] = startDiscussion($bob, 'Feature request: dark mode', "Would love a dark theme in the app.", [$tags['feedback'], $tags['question']]);
reply($carol, $d, '+1, especially for reading at night.');
patch($alice, 'posts', $p1, ['isLiked' => true]);
patch($alice, 'discussions', $d, ['subscription' => 'follow']);
$ids['discussions']['feedback'] = $d;
// fof/follow-tags: alice lurks in support (every reply) and follows feedback (new discussions).
// 1.x has its own route for it; 2.0 takes the tag's attribute.
foreach (['support' => 'lurk', 'feedback' => 'follow'] as $slug => $level) {
    if ($v === 1) {
        api('POST', "/api/tags/{$tags[$slug]}/subscription", ['data' => ['subscription' => $level]], $alice);
    } else {
        patch($alice, 'tags', $tags[$slug], ['subscription' => $level]);
    }
}

// 5. A long thread (60 posts) to test paging past page[limit]=50; alice has read up to post 20.
// alice doesn't post here: replying marks the thread read, and read state only moves forward.
[$d] = startDiscussion($bob, 'Long thread for paging tests', 'Post 1 of 60.', [$general]);
$writers = [$bob, $carol];
for ($n = 2; $n <= 60; $n++) {
    reply($writers[$n % 2], $d, "Post $n of 60.");
}
patch($alice, 'discussions', $d, ['lastReadPostNumber' => 20]);
$ids['discussions']['long'] = $d;
// The posts above share a few seconds, and 1.x places page[near] by created_at, so space them
// a minute apart as on a real forum. The API can't set timestamps; write them in the database.
$db = new PDO('mysql:host=localhost;dbname='.$creds["DB_V$v"], $creds['DB_USER'], $creds['DB_PASS']);
$db->prepare('UPDATE posts SET created_at = NOW() - INTERVAL (61 - number) MINUTE WHERE discussion_id = ?')->execute([$d]);
$db->prepare('UPDATE discussions SET created_at = NOW() - INTERVAL 60 MINUTE, last_posted_at = NOW() - INTERVAL 1 MINUTE WHERE id = ?')->execute([$d]);
$step('discussions: rules, welcome, support, feedback, long (60 posts)');

// 6. Private discussion through fof/byobu.
try {
    [$d] = startDiscussion($alice, 'Private: test plan', "@\"bob\"#$bobId can you run the iOS checks?", [], [$bobId]);
    reply($bob, $d, 'Sure, tomorrow.');
    $ids['discussions']['private'] = $d;
    $step('private discussion (byobu)');
} catch (RuntimeException $e) {
    $step('private discussion FAILED: '.$e->getMessage());
}

setPermission($admin, 'postWithoutThrottle', []);
$step('posting throttle restored');

file_put_contents($idsFile, json_encode($ids, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)."\n");
echo "Done. Ids written to $idsFile\n";
