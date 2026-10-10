<?php
/*
 * REST helpers shared by the test-forum seed scripts (seed.php, community_seed.php).
 * api() calls the forum named by the global $base, as a guest or with a token.
 */

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
