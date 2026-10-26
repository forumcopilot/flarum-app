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
use Flarum\Testing\integration\RetrievesAuthorizedUsers;
use ForumCopilot\Flapp\Push\Signer;
use GuzzleHttp\Psr7\Response;

class UnreadTest extends FlappTestCase
{
    use RetrievesAuthorizedUsers;

    const HANDLE = 'aaaaaaaaaaaaaaaaaaaaaa';

    protected function setUp(): void
    {
        parent::setUp();

        $this->extension('forumcopilot-flapp');

        list($privateKey) = Signer::generateKeyPair();
        $now = Carbon::now()->toDateTimeString();

        $this->prepareDatabase([
            'users' => [
                $this->normalUser(),
            ],
            'discussions' => [
                ['id' => 1, 'title' => 'Welcome thread', 'slug' => 'welcome-thread', 'created_at' => $now, 'user_id' => 2, 'first_post_id' => 1, 'comment_count' => 1],
                ['id' => 2, 'title' => 'Second thread', 'slug' => 'second-thread', 'created_at' => $now, 'user_id' => 2, 'first_post_id' => 2, 'comment_count' => 1],
            ],
            'posts' => [
                ['id' => 1, 'discussion_id' => 1, 'number' => 1, 'created_at' => $now, 'user_id' => 2, 'type' => 'comment', 'content' => '<t><p>Hello there</p></t>'],
                ['id' => 2, 'discussion_id' => 2, 'number' => 1, 'created_at' => $now, 'user_id' => 2, 'type' => 'comment', 'content' => '<t><p>Hello again</p></t>'],
            ],
            'notifications' => [
                ['id' => 1, 'user_id' => 2, 'from_user_id' => 1, 'type' => 'discussionRenamed', 'subject_id' => 1, 'created_at' => $now, 'is_deleted' => 0],
                ['id' => 2, 'user_id' => 2, 'from_user_id' => 1, 'type' => 'discussionRenamed', 'subject_id' => 2, 'created_at' => $now, 'is_deleted' => 0],
            ],
            'access_tokens' => [
                ['id' => 10, 'token' => 'normaltoken-remember-aaaaaaaaaaaaaaaaaaa', 'user_id' => 2, 'type' => 'session_remember', 'created_at' => $now, 'last_activity_at' => $now],
            ],
            'flapp_devices' => [
                ['id' => 1, 'user_id' => 2, 'access_token_id' => 10, 'handle' => self::HANDLE, 'platform' => 'ios', 'app' => 'flapp', 'locale' => 'en', 'created_at' => $now],
            ],
            'flapp_keys' => [
                ['forum_id' => 'f_test', 'private_key' => $privateKey, 'created_at' => $now],
            ],
        ]);
    }

    protected function sent(): array
    {
        $this->assertCount(1, $this->relayCalls);
        $request = $this->relayCalls[0]['request'];
        $this->assertEquals('https://relay.test/v1/unread', (string) $request->getUri());

        return json_decode((string) $request->getBody(), true);
    }

    public function test_reading_all_notifications_sends_the_new_count(): void
    {
        $this->connected();
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 1, 'gone' => []]))]);

        $response = $this->send($this->request('POST', '/api/notifications/read', ['authenticatedAs' => 2]));

        $this->assertEquals(204, $response->getStatusCode());
        $this->assertEquals(['forumId' => 'f_test', 'counts' => [['handle' => self::HANDLE, 'unread' => 0]]], $this->sent());
    }

    public function test_deleting_all_notifications_sends_the_new_count(): void
    {
        $this->connected();
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 1, 'gone' => []]))]);

        $response = $this->send($this->request('DELETE', '/api/notifications', ['authenticatedAs' => 2]));

        $this->assertEquals(204, $response->getStatusCode());
        $this->assertEquals(0, $this->sent()['counts'][0]['unread']);
    }

    public function test_reading_one_notification_sends_what_is_left(): void
    {
        $this->connected();
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 1, 'gone' => []]))]);

        $response = $this->send($this->request('PATCH', '/api/notifications/1', [
            'authenticatedAs' => 2,
            'json' => ['data' => ['type' => 'notifications', 'id' => '1', 'attributes' => ['isRead' => true]]],
        ]));

        $this->assertEquals(200, $response->getStatusCode(), (string) $response->getBody());
        $this->assertEquals(1, $this->sent()['counts'][0]['unread']);
    }

    public function test_a_reader_without_a_device_sends_nothing(): void
    {
        $this->connected();
        $this->fakeRelay([]);
        $this->database()->table('flapp_devices')->delete();

        $this->send($this->request('POST', '/api/notifications/read', ['authenticatedAs' => 2]));

        $this->assertCount(0, $this->relayCalls);
    }

    public function test_nothing_is_sent_while_disconnected(): void
    {
        $this->fakeRelay([]);

        $this->send($this->request('POST', '/api/notifications/read', ['authenticatedAs' => 2]));

        $this->assertCount(0, $this->relayCalls);
    }

    public function test_a_device_the_relay_no_longer_knows_is_deleted(): void
    {
        $this->connected();
        $this->fakeRelay([new Response(200, [], json_encode(['sent' => 0, 'gone' => [self::HANDLE]]))]);

        $this->send($this->request('POST', '/api/notifications/read', ['authenticatedAs' => 2]));

        $this->assertEquals(0, $this->database()->table('flapp_devices')->count());
    }
}
