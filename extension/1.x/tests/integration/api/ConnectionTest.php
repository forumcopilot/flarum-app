<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Tests\integration\api;

use Flarum\Testing\integration\RetrievesAuthorizedUsers;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Device;
use ForumCopilot\Flapp\Push\RelayClient;
use ForumCopilot\Flapp\Push\Signer;
use ForumCopilot\Flapp\Tests\integration\FlappTestCase;
use GuzzleHttp\Exception\ConnectException;
use GuzzleHttp\Psr7\Request;
use GuzzleHttp\Psr7\Response;

class ConnectionTest extends FlappTestCase
{
    use RetrievesAuthorizedUsers;

    protected function setUp(): void
    {
        parent::setUp();

        $this->extension('forumcopilot-flapp');

        $this->prepareDatabase([
            'users' => [$this->normalUser()],
        ]);
    }

    protected function connect(int $userId = 1)
    {
        return $this->send($this->request('POST', '/api/flapp-push/connection', ['authenticatedAs' => $userId]));
    }

    protected function forumAttributes(): array
    {
        return $this->json($this->send($this->request('GET', '/api')))['data']['attributes'];
    }

    protected function assertSigned(array $call, string $publicKey): void
    {
        /** @var \Psr\Http\Message\RequestInterface $request */
        $request = $call['request'];

        $time = (int) $request->getHeaderLine('X-Flapp-Time');
        $this->assertEqualsWithDelta(time(), $time, 60);

        $this->assertTrue(Signer::verify(
            $publicKey,
            $request->getMethod(),
            $request->getUri()->getPath(),
            $time,
            (string) $request->getBody(),
            $request->getHeaderLine('X-Flapp-Signature')
        ), 'The signature checks out against the forum\'s public key.');
    }

    public function test_an_admin_connects_the_forum(): void
    {
        $this->fakeRelay([new Response(201, [], json_encode(['forumId' => 'f_abc']))]);

        $response = $this->connect();

        $this->assertEquals(200, $response->getStatusCode(), (string) $response->getBody());
        $this->assertEquals(['relay' => RelayClient::DEFAULT_URL, 'forumId' => 'f_abc'], $this->json($response));

        // The relay got the forum's address, title and public key, signed with
        // the key it is enrolling.
        $this->assertCount(1, $this->relayCalls);

        /** @var Request $request */
        $request = $this->relayCalls[0]['request'];
        $body = json_decode((string) $request->getBody(), true);

        $this->assertEquals('POST', $request->getMethod());
        $this->assertEquals(RelayClient::DEFAULT_URL.'/v1/forums', (string) $request->getUri());
        $this->assertFalse($request->hasHeader('X-Flapp-Forum'));
        $this->assertEquals('http://localhost', $body['url']);
        $this->assertArrayHasKey('title', $body);
        $this->assertSigned($this->relayCalls[0], $body['publicKey']);

        // The forum keeps the private half, outside the settings.
        $privateKey = $this->database()->table(Connection::KEYS_TABLE)->where('forum_id', 'f_abc')->value('private_key');
        $this->assertEquals($body['publicKey'], Signer::publicKey($privateKey));
        $this->assertEquals(0, $this->database()->table('settings')->where('value', 'like', '%PRIVATE KEY%')->count());

        $this->assertEquals([
            'relay' => RelayClient::DEFAULT_URL,
            'forumId' => 'f_abc',
            'version' => RelayClient::PROTOCOL_VERSION,
        ], $this->forumAttributes()['flappPush']);
    }

    public function test_connects_to_the_relay_set_by_hand(): void
    {
        $this->setting(Connection::RELAY_URL, 'https://staging.relay.test/prefix');
        $this->fakeRelay([new Response(201, [], json_encode(['forumId' => 'f_abc']))]);

        $this->assertEquals(200, $this->connect()->getStatusCode());

        $request = $this->relayCalls[0]['request'];
        $this->assertEquals('https://staging.relay.test/prefix/v1/forums', (string) $request->getUri());
        $this->assertSigned($this->relayCalls[0], json_decode((string) $request->getBody(), true)['publicKey']);
        $this->assertEquals('https://staging.relay.test/prefix', $this->forumAttributes()['flappPush']['relay']);
    }

    public function test_only_admins_connect(): void
    {
        $this->fakeRelay([]);

        $this->assertEquals(403, $this->connect(2)->getStatusCode());
        $this->assertCount(0, $this->relayCalls);
    }

    public function test_cannot_connect_twice(): void
    {
        $this->connected();
        $this->fakeRelay([]);

        $this->assertEquals(422, $this->connect()->getStatusCode());
        $this->assertCount(0, $this->relayCalls);
    }

    public function test_a_refusal_from_the_relay_leaves_the_forum_disconnected(): void
    {
        $this->fakeRelay([new Response(429, [], json_encode(['error' => 'Too many enrolments']))]);

        $response = $this->connect();

        // The relay's words reach the admin through the error's detail; the
        // tests can't check its translation, which flarum/testing doesn't load.
        $this->assertEquals(422, $response->getStatusCode());
        $this->assertEquals('/data/attributes/relay', $this->json($response)['errors'][0]['source']['pointer']);
        $this->assertArrayNotHasKey('flappPush', $this->forumAttributes());
        $this->assertEquals(0, $this->database()->table(Connection::KEYS_TABLE)->count());
    }

    public function test_an_answer_without_a_forum_id_is_a_failure(): void
    {
        $this->fakeRelay([new Response(201, [], '{}')]);

        $this->assertEquals(422, $this->connect()->getStatusCode());
        $this->assertArrayNotHasKey('flappPush', $this->forumAttributes());
    }

    public function test_not_connected_means_no_flapp_push(): void
    {
        $this->assertArrayNotHasKey('flappPush', $this->forumAttributes());
    }

    public function test_disconnecting_tells_the_relay_and_drops_the_devices(): void
    {
        $this->fakeRelay([
            new Response(201, [], json_encode(['forumId' => 'f_abc'])),
            new Response(204),
        ]);

        $this->connect();
        $publicKey = json_decode((string) $this->relayCalls[0]['request']->getBody(), true)['publicKey'];

        list($request) = $this->withToken($this->request('POST', '/api/flapp-push/devices', [
            'json' => ['handle' => 'aaaaaaaaaaaaaaaaaaaaaa', 'platform' => 'android', 'app' => 'flapp'],
        ]), 2);
        $this->assertEquals(201, $this->send($request)->getStatusCode());

        $response = $this->send($this->request('DELETE', '/api/flapp-push/connection', ['authenticatedAs' => 1]));

        $this->assertEquals(204, $response->getStatusCode());

        $request = $this->relayCalls[1]['request'];
        $this->assertEquals('DELETE', $request->getMethod());
        $this->assertEquals(RelayClient::DEFAULT_URL.'/v1/forums/f_abc', (string) $request->getUri());
        $this->assertEquals('f_abc', $request->getHeaderLine('X-Flapp-Forum'));
        $this->assertSigned($this->relayCalls[1], $publicKey);

        $this->assertArrayNotHasKey('flappPush', $this->forumAttributes());
        $this->assertEquals(0, Device::query()->count());
        $this->assertEquals(0, $this->database()->table(Connection::KEYS_TABLE)->count());
    }

    public function test_disconnects_even_when_the_relay_is_unreachable(): void
    {
        $this->fakeRelay([
            new Response(201, [], json_encode(['forumId' => 'f_abc'])),
            new ConnectException('Connection refused', new Request('DELETE', 'https://relay.test')),
        ]);

        $this->connect();

        $response = $this->send($this->request('DELETE', '/api/flapp-push/connection', ['authenticatedAs' => 1]));

        $this->assertEquals(204, $response->getStatusCode());
        $this->assertArrayNotHasKey('flappPush', $this->forumAttributes());
    }

    public function test_only_admins_disconnect(): void
    {
        $this->connected();

        $response = $this->send($this->request('DELETE', '/api/flapp-push/connection', ['authenticatedAs' => 2]));

        $this->assertEquals(403, $response->getStatusCode());
        $this->assertArrayHasKey('flappPush', $this->forumAttributes());
    }
}
