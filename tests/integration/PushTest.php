<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Tests\integration;

use Carbon\Carbon;
use Flarum\Notification\Blueprint\DiscussionRenamedBlueprint;
use Flarum\Notification\Notification;
use Flarum\Notification\NotificationSyncer;
use Flarum\Post\Post;
use Flarum\Testing\integration\RetrievesAuthorizedUsers;
use Flarum\User\User;
use ForumCopilot\Flapp\Device;
use ForumCopilot\Flapp\Extend\PushLines;
use ForumCopilot\Flapp\Push\Signer;
use GuzzleHttp\Exception\ConnectException;
use GuzzleHttp\Psr7\Request;
use GuzzleHttp\Psr7\Response;

class PushTest extends FlappTestCase
{
    use RetrievesAuthorizedUsers;

    const HANDLE = 'aaaaaaaaaaaaaaaaaaaaaa';

    /**
     * @var string
     */
    protected $publicKey;

    protected function setUp(): void
    {
        parent::setUp();

        $this->extension('forumcopilot-flapp');

        list($privateKey, $this->publicKey) = Signer::generateKeyPair();
        $now = Carbon::now()->toDateTimeString();

        $this->prepareDatabase([
            'users' => [
                $this->normalUser(),
                ['id' => 3, 'username' => 'carol', 'password' => '$2y$10$LO59tiT7uggl6Oe23o/O6.utnF6ipngYjvMvaxo1TciKqBttDNKim', 'email' => 'carol@machine.local', 'is_email_confirmed' => 1],
            ],
            'discussions' => [
                ['id' => 1, 'title' => 'Welcome thread', 'slug' => 'welcome-thread', 'created_at' => $now, 'user_id' => 2, 'first_post_id' => 1, 'comment_count' => 1, 'last_post_number' => 2],
            ],
            'posts' => [
                ['id' => 1, 'discussion_id' => 1, 'number' => 1, 'created_at' => $now, 'user_id' => 2, 'type' => 'comment', 'content' => '<t><p>Hello there</p></t>'],
                ['id' => 2, 'discussion_id' => 1, 'number' => 2, 'created_at' => $now, 'user_id' => 3, 'type' => 'discussionRenamed', 'content' => '["Old title","Welcome thread"]'],
            ],
            'access_tokens' => [
                ['id' => 10, 'token' => 'normaltoken-remember-aaaaaaaaaaaaaaaaaaa', 'user_id' => 2, 'type' => 'session_remember', 'created_at' => $now, 'last_activity_at' => $now],
            ],
            'flapp_devices' => [
                ['id' => 1, 'user_id' => 2, 'access_token_id' => 10, 'handle' => self::HANDLE, 'platform' => 'android', 'app' => 'flapp', 'locale' => 'en', 'created_at' => $now],
            ],
            'flapp_keys' => [
                ['forum_id' => 'f_test', 'private_key' => $privateKey, 'created_at' => $now],
            ],
        ]);
    }

    protected function rename(): void
    {
        $this->app()->getContainer()->make(NotificationSyncer::class)->sync(
            new DiscussionRenamedBlueprint(Post::query()->findOrFail(2)),
            [User::query()->findOrFail(2)]
        );
    }

    public function test_a_renamed_discussion_is_pushed_to_the_readers_phone(): void
    {
        $this->connected();
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 1, 'gone' => []]))]);

        $this->rename();

        $this->assertCount(1, $this->relayCalls);

        $request = $this->relayCalls[0]['request'];
        $this->assertEquals('POST', $request->getMethod());
        $this->assertEquals('https://relay.test/v1/push', (string) $request->getUri());
        $this->assertEquals('f_test', $request->getHeaderLine('X-Flapp-Forum'));
        $this->assertTrue(Signer::verify(
            $this->publicKey,
            'POST',
            '/v1/push',
            (int) $request->getHeaderLine('X-Flapp-Time'),
            (string) $request->getBody(),
            $request->getHeaderLine('X-Flapp-Signature')
        ));

        $body = json_decode((string) $request->getBody(), true);
        $this->assertEquals('f_test', $body['forumId']);
        $this->assertCount(1, $body['pushes']);
        $this->assertEquals(self::HANDLE, $body['pushes'][0]['handle']);

        $this->assertEquals([
            'v' => 1,
            'id' => Notification::query()->where('user_id', 2)->value('id'),
            'type' => 'discussionRenamed',
            'title' => 'Welcome thread',
            'body' => 'carol changed the title',
            'open' => ['discussion' => 1, 'post' => 2],
            'unread' => 1,
        ], $body['pushes'][0]['payload']);

        $this->assertNotNull(Device::query()->findOrFail(1)->last_sent_at);
    }

    public function test_another_extension_can_give_a_type_its_words(): void
    {
        $this->extend((new PushLines())->line('discussionRenamed', 'core.lib.username.deleted_text'));
        $this->connected();
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 1, 'gone' => []]))]);

        $this->rename();

        $body = json_decode((string) $this->relayCalls[0]['request']->getBody(), true);
        $this->assertEquals('[deleted]', $body['pushes'][0]['payload']['body']);
    }

    public function test_nothing_is_pushed_for_a_type_the_reader_turned_off(): void
    {
        $this->connected();
        $this->fakeRelay([]);
        $this->database()->table('users')->where('id', 2)->update(['preferences' => json_encode(['notify_discussionRenamed_flapp' => false])]);

        $this->rename();

        $this->assertCount(0, $this->relayCalls);
    }

    public function test_a_reader_without_a_device_gets_nothing(): void
    {
        $this->connected();
        $this->fakeRelay([]);
        $this->database()->table('flapp_devices')->delete();

        $this->rename();

        $this->assertCount(0, $this->relayCalls);
    }

    public function test_a_sign_in_flarum_no_longer_counts_gets_nothing(): void
    {
        $this->connected();
        $this->fakeRelay([]);
        // A session token, idle for longer than Flarum's hour.
        $this->database()->table('access_tokens')->where('id', 10)->update([
            'type' => 'session',
            'last_activity_at' => Carbon::now()->subHours(2)->toDateTimeString(),
        ]);

        $this->rename();

        $this->assertCount(0, $this->relayCalls);
    }

    public function test_nothing_is_pushed_while_disconnected(): void
    {
        $this->fakeRelay([]);

        $this->rename();

        $this->assertCount(0, $this->relayCalls);
    }

    public function test_a_device_the_relay_no_longer_knows_is_deleted(): void
    {
        $this->connected();
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 0, 'gone' => [self::HANDLE]]))]);

        $this->rename();

        $this->assertCount(1, $this->relayCalls);
        $this->assertEquals(0, Device::query()->count());
    }

    public function test_a_relay_that_is_down_does_not_break_the_notification(): void
    {
        $this->connected();
        $this->fakeRelay([new ConnectException('Connection refused', new Request('POST', 'https://relay.test/v1/push'))]);

        $this->rename();

        $this->assertCount(1, $this->relayCalls);
        $this->assertEquals(1, Notification::query()->where('user_id', 2)->count(), 'the web alert is there');
        $this->assertEquals(1, Device::query()->count());
    }

    public function test_a_reply_opens_the_reply_and_quotes_it(): void
    {
        $this->extension('flarum-mentions');
        $this->connected();
        $this->prepareDatabase(['posts' => [
            ['id' => 3, 'discussion_id' => 1, 'number' => 3, 'created_at' => Carbon::now()->toDateTimeString(), 'user_id' => 3, 'type' => 'comment', 'content' => '<t><p>Thanks, that helped.</p><p>Second paragraph &amp; more.</p></t>'],
        ]]);
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 1, 'gone' => []]))]);

        $this->app()->getContainer()->make(NotificationSyncer::class)->sync(
            new \Flarum\Mentions\Notification\PostMentionedBlueprint(Post::query()->findOrFail(1), Post::query()->findOrFail(3)),
            [User::query()->findOrFail(2)]
        );

        $payload = json_decode((string) $this->relayCalls[0]['request']->getBody(), true)['pushes'][0]['payload'];

        // The words come from flarum/mentions' language pack, which the test
        // kit doesn't load; what a tap opens and what it quotes doesn't
        // depend on it.
        $this->assertEquals('postMentioned', $payload['type']);
        $this->assertEquals(['discussion' => 1, 'post' => 3], $payload['open']);
        $this->assertEquals('Thanks, that helped. Second paragraph & more.', $payload['excerpt']);
    }

    public function test_the_same_notification_synced_twice_is_pushed_once(): void
    {
        $this->connected();
        $this->fakeRelay([
            new Response(200, [], json_encode(['sent' => 1, 'gone' => []])),
            new Response(200, [], json_encode(['sent' => 1, 'gone' => []])),
        ]);

        $this->rename();
        // Flarum's syncer hands a recipient over only once; a second, separate
        // sync of the same notification is what the lock is for.
        $this->database()->table('notifications')->delete();
        $this->rename();

        $this->assertCount(1, $this->relayCalls);
    }
}
