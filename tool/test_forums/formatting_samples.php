<?php
/*
 * Posts a "Formatting samples" discussion on a seeded test forum: one post per kind of
 * markup Flarum can produce (Markdown, BBCode, mentions, emoji, spoilers, code, tables,
 * media embeds, uploads), so their contentHtml can be recorded and rendered by the app.
 * Turns on fof/formatting's optional TextFormatter plugins first, since many forums use them.
 *
 * Usage: php tool/test_forums/formatting_samples.php <forum url> <credentials file> <seed ids file> <output ids file>
 * The credentials file is the one seed.php reads; the seed ids file is what seed.php wrote.
 * Refuses to run twice on the same forum.
 */

[, $base, $credentialsFile, $seedFile, $idsFile] = $argv + [null, '', '', '', ''];
$base = rtrim($base, '/');
if ($base === '' || $credentialsFile === '' || $seedFile === '' || $idsFile === '') {
    fwrite(STDERR, "usage: php formatting_samples.php <forum url> <credentials file> <seed ids file> <output ids file>\n");
    exit(1);
}

$creds = [];
foreach (file($credentialsFile, FILE_IGNORE_NEW_LINES) as $line) {
    if (preg_match('/^([A-Z_0-9]+)=(.*)$/', $line, $m)) {
        $creds[$m[1]] = $m[2];
    }
}
$seed = json_decode(file_get_contents($seedFile), true);

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
    curl_setopt_array($ch, [CURLOPT_CUSTOMREQUEST => $method, CURLOPT_RETURNTRANSFER => true, CURLOPT_HTTPHEADER => $headers]);
    $raw = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);
    if ($code >= 400) {
        throw new RuntimeException("$method $path -> HTTP $code: ".substr((string) $raw, 0, 400));
    }

    return json_decode((string) $raw, true) ?? [];
}

function login(string $identification, string $password): string
{
    return api('POST', '/api/token', ['identification' => $identification, 'password' => $password])['token'];
}

$admin = login($creds['ADMIN_USER'], $creds['ADMIN_PASS']);
$alice = login('alice', $creds['TEST_USER_PASS']);

$existing = api('GET', '/api/discussions?filter[q]='.urlencode('"Formatting samples"'), null, $alice)['data'] ?? [];
foreach ($existing as $discussion) {
    if ($discussion['attributes']['title'] === 'Formatting samples') {
        fwrite(STDERR, "This forum already has the formatting samples. Nothing done.\n");
        exit(1);
    }
}

$settings = [];
foreach (['autoimage', 'autovideo', 'fancypants', 'htmlentities', 'mediaembed', 'pipetables', 'tasklists'] as $plugin) {
    $settings["fof-formatting.plugin.$plugin"] = '1';
}
api('POST', '/api/settings', $settings, $admin);
// fof/upload accepts only images by default; allow text and PDF attachments, as many forums do.
api('POST', '/api/settings', ['fof-upload.mimeTypes' => json_encode([
    '^image\/(jpeg|png|apng|gif|webp|avif|bmp|tiff|svg\+xml)$' => ['adapter' => 'local', 'template' => 'image-preview'],
    '^(text\/plain|application\/pdf)$' => ['adapter' => 'local', 'template' => 'file'],
])], $admin);
api('POST', '/api/permission', ['permission' => 'postWithoutThrottle', 'groupIds' => [3]], $admin);
echo "fof/formatting plugins and attachments on\n";

// Uploads first: their markup goes into a sample.
$uploads = [];
$png = tempnam(sys_get_temp_dir(), 'sample').'.png';
$img = imagecreatetruecolor(240, 160);
imagefill($img, 0, 0, imagecolorallocate($img, 39, 174, 96));
imagepng($img, $png);
$txt = tempnam(sys_get_temp_dir(), 'sample').'.txt';
file_put_contents($txt, "A plain text attachment.\n");
foreach (['image' => [$png, 'image/png', 'green.png'], 'file' => [$txt, 'text/plain', 'notes.txt']] as $kind => [$path, $mime, $name]) {
    $uploads[$kind] = api('POST', '/api/fof/upload', null, $alice, ['files[]' => new CURLFile($path, $mime, $name)])['data'][0]['attributes']['bbcode'];
}
unlink($png);
unlink($txt);

$bob = $seed['users']['bob'];
$welcomeReply = $seed['posts']['welcome'][1];

$samples = [
    'markdown_inline' => "**Bold**, *italic*, ~~struck~~, `inline code`, a [link](https://flarum.org), <https://example.com>, and a bare URL https://discuss.flarum.org.\nA line break above, then a second paragraph.\n\nSecond paragraph.",
    'markdown_blocks' => "# Heading one\n\n## Heading two\n\n- one\n- two\n  - nested\n\n1. first\n2. second\n\n> A quote\n> over two lines\n\n---\n\nAfter the rule.",
    'code' => "```php\n<?php echo 'hello';\n```\n\n```\nplain block\n  indented\n```",
    'bbcode' => "[b]bold[/b] [i]italic[/i] [u]underlined[/u] [s]struck[/s] [del]deleted[/del] [color=red]red[/color] [color=#3366cc]blue[/color] [size=20]big[/size] [url=https://flarum.org]BBCode link[/url] [email]someone@example.com[/email]\n\n[center]Centred[/center]\n\n[quote=bob]A BBCode quote.[/quote]\n\n[list][*]BBCode one[*]BBCode two[/list]\n\n[code]BBCode code[/code]",
    'spoilers' => ">! A block spoiler.\n\nAn inline ||spoiler|| in a sentence, and a [spoiler]BBCode spoiler[/spoiler].",
    'mentions' => "Hello @\"bob\"#$bob, and the @\"Mods\"#g4 group. Replying to @\"alice\"#p$welcomeReply.",
    'quote_reply' => "> @\"alice\"#p$welcomeReply Hi all! Looking forward to testing\n\nQuoting the welcome reply, as the web's Quote button does.",
    'emoji' => "Shortcodes :smile: :+1: :heart: and Unicode 😀 🎉.",
    'tables_tasks' => "| Feature | 1.8 | 2.0 |\n| --- | :---: | ---: |\n| Mentions | yes | yes |\n| Messages | no | yes |\n\n- [x] Done task\n- [ ] Open task",
    'media' => "A YouTube link:\n\nhttps://www.youtube.com/watch?v=aqz-KE-bpKQ\n\nAn image URL:\n\nhttps://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg\n\nA video URL:\n\nhttps://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4",
    'images' => "A Markdown image: ![Flarum logo](https://flarum.org/img/logo.png)\n\nA BBCode image: [img]https://upload.wikimedia.org/wikipedia/commons/a/a9/Example.jpg[/img]",
    'uploads' => "Uploaded files:\n\n".$uploads['image'],
    'typography' => "Straight \"quotes\" and 'apostrophes', dashes -- and --- and an ellipsis... (c) (tm) &copy; &hearts; &lt;b&gt; not bold &lt;/b&gt;",
    'attachment' => "An attached file:\n\n".$uploads['file'],
];

$general = $seed['tags']['general'];
$created = api('POST', '/api/discussions', ['data' => [
    'type' => 'discussions',
    'attributes' => ['title' => 'Formatting samples', 'content' => 'One reply per kind of markup, for rendering tests.'],
    'relationships' => ['tags' => ['data' => [['type' => 'tags', 'id' => $general]]]],
]], $alice)['data'];
$ids = ['discussion' => $created['id'], 'posts' => []];
foreach ($samples as $name => $content) {
    $ids['posts'][$name] = api('POST', '/api/posts', ['data' => [
        'type' => 'posts',
        'attributes' => ['content' => $content],
        'relationships' => ['discussion' => ['data' => ['type' => 'discussions', 'id' => $created['id']]]],
    ]], $alice)['data']['id'];
}
api('POST', '/api/permission', ['permission' => 'postWithoutThrottle', 'groupIds' => []], $admin);

file_put_contents($idsFile, json_encode($ids, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)."\n");
echo 'Posted '.count($samples)." samples; ids written to $idsFile\n";
