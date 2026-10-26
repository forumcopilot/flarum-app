<?php
// Flapp push check (milestone 5 of the push design): makes one notification of each type for bob,
// so his phones get one push of each. carol acts, except where only a moderator may (renaming,
// locking and suspending), where the admin does. Run on the server, from stdin, as
// docs/push-check.md says:
//
//   ssh … 'php -- http://127.0.0.1:8082' < tool/test_forums/push_types.php
//
// It waits a few seconds between pushes, so they arrive in order, and prints what each push should
// say. Last it prints the ids to delete: the discussions with delete_discussions.php (byobu hides
// carol's private one even from the admin), 2.0's conversation with delete_dialogs.php. bob is
// unsuspended again even if a step fails. The credentials file stays on the server.

$base = $argv[1] ?? 'http://127.0.0.1:8082';
$pause = (int) ($argv[2] ?? 4);
$creds = [];
foreach (file('/var/www/flarumapp/.credentials', FILE_IGNORE_NEW_LINES) as $line) {
    if (preg_match('/^([A-Z0-9_]+)=(.*)$/', $line, $m)) {
        $creds[$m[1]] = $m[2];
    }
}

function call(string $method, string $path, ?array $body = null, ?string $token = null): array
{
    global $base;
    $ch = curl_init($base.$path);
    $headers = ['Content-Type: application/json', 'Accept: application/vnd.api+json'];
    if ($token) {
        $headers[] = "Authorization: Token $token";
    }
    curl_setopt_array($ch, [CURLOPT_CUSTOMREQUEST => $method, CURLOPT_RETURNTRANSFER => true, CURLOPT_HTTPHEADER => $headers]);
    if ($body !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
    }
    $out = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    if ($status >= 300) {
        throw new RuntimeException("$method $path: $status ".substr((string) $out, 0, 300));
    }

    return json_decode((string) $out, true) ?? [];
}

function token(string $user, string $password): string
{
    return call('POST', '/api/token', ['identification' => $user, 'password' => $password])['token'];
}

function step(string $expect): void
{
    global $pause;
    fwrite(STDERR, date('H:i:s')."  $expect\n");
    sleep($pause);
}

function post(string $token, string $discussionId, string $content): array
{
    return call('POST', '/api/posts', ['data' => [
        'type' => 'posts',
        'attributes' => ['content' => $content],
        'relationships' => ['discussion' => ['data' => ['type' => 'discussions', 'id' => $discussionId]]],
    ]], $token)['data'];
}

$bob = token('bob', $creds['TEST_USER_PASS']);
$carol = token('carol', $creds['TEST_USER_PASS']);
$admin = token($creds['ADMIN_USER'], $creds['ADMIN_PASS']);

$forum = call('GET', '/api', null, $carol);
$v2 = isset($forum['data']['attributes']['jsChunksBaseUrl']);
$general = null;
foreach (call('GET', '/api/tags', null, $bob)['data'] as $tag) {
    if ($tag['attributes']['slug'] === 'general') {
        $general = $tag['id'];
    }
}
$heart = null;
foreach ($forum['included'] ?? [] as $resource) {
    if ($resource['type'] === 'reactions' && ($resource['attributes']['identifier'] ?? '') === 'heart') {
        $heart = $resource['id'];
    }
}

$made = ['discussions' => [], 'dialogs' => []];
$bobId = null;
try {
    $discussion = call('POST', '/api/discussions', ['data' => [
        'type' => 'discussions',
        'attributes' => ['title' => 'Push check', 'content' => 'Does each kind of notification reach the phone? (A test; deleted after.)'],
        'relationships' => ['tags' => ['data' => [['type' => 'tags', 'id' => $general]]]],
    ]], $bob)['data'];
    $id = $discussion['id'];
    $made['discussions'][] = $id;
    $first = $discussion['relationships']['firstPost']['data']['id'] ?? $discussion['relationships']['posts']['data'][0]['id'];
    $bobId = $discussion['relationships']['user']['data']['id'];
    $bobName = call('GET', "/api/users/$bobId", null, $carol)['data']['attributes']['displayName'];

    post($carol, $id, "@\"$bobName\"#p$first It does: a reply to your post.");
    step('postMentioned: Push check / carol replied to your post');

    post($carol, $id, "And a mention of @\"$bobName\"#$bobId on its own.");
    step('userMentioned: Push check / carol mentioned you');

    call('PATCH', "/api/posts/$first", ['data' => ['type' => 'posts', 'id' => $first, 'attributes' => ['isLiked' => true]]], $carol);
    step('postLiked: Push check / carol liked your post');

    if ($heart !== null) {
        call('PATCH', "/api/posts/$first", ['data' => ['type' => 'posts', 'id' => $first, 'attributes' => ['reaction' => $heart]]], $carol);
        step('postReacted: Push check / carol reacted with ❤️ to your post');
    }

    call('PATCH', "/api/discussions/$id", ['data' => ['type' => 'discussions', 'id' => $id, 'attributes' => ['subscription' => 'follow']]], $bob);
    post($carol, $id, 'A post in a discussion you follow.');
    step('newPost: Push check / carol posted');

    call('PATCH', "/api/discussions/$id", ['data' => ['type' => 'discussions', 'id' => $id, 'attributes' => ['title' => 'Push check, renamed']]], $admin);
    step('discussionRenamed: Push check, renamed / admin changed the title');

    call('PATCH', "/api/discussions/$id", ['data' => ['type' => 'discussions', 'id' => $id, 'attributes' => ['isLocked' => true]]], $admin);
    step('discussionLocked: Push check, renamed / admin locked');

    $private = call('POST', '/api/discussions', ['data' => [
        'type' => 'discussions',
        'attributes' => ['title' => 'Push check, private', 'content' => 'A private discussion with you. (A test; deleted after.)'],
        'relationships' => ['recipientUsers' => ['data' => [['type' => 'users', 'id' => $bobId]]]],
    ]], $carol)['data'];
    $made['discussions'][] = $private['id'];
    step('byobuPrivateDiscussionCreated: Push check, private / carol started a private discussion');

    if ($v2) {
        $message = call('POST', '/api/dialog-messages', ['data' => [
            'type' => 'dialog-messages',
            'attributes' => ['content' => 'A message for the push check. (Deleted after.)', 'users' => [['id' => $bobId]]],
        ]], $carol)['data'];
        $made['dialogs'][] = $message['relationships']['dialog']['data']['id'];
        step('messageReceived: the forum\'s title / carol sent you a message');
    }

    call('PATCH', "/api/users/$bobId", ['data' => ['type' => 'users', 'id' => $bobId, 'attributes' => [
        'suspendedUntil' => gmdate('Y-m-d\TH:i:s\Z', time() + 86400),
    ]]], $admin);
    step('userSuspended: the forum\'s title / You have been suspended for 1 day');
} finally {
    if ($bobId !== null) {
        call('PATCH', "/api/users/$bobId", ['data' => ['type' => 'users', 'id' => $bobId, 'attributes' => ['suspendedUntil' => null]]], $admin);
        fwrite(STDERR, date('H:i:s')."  userUnsuspended: the forum's title / You have been unsuspended\n");
    }
    echo json_encode($made), "\n";
}
