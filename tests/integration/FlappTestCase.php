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
use Flarum\Testing\integration\TestCase;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Push\RelayClient;
use GuzzleHttp\Client;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Middleware;
use Illuminate\Support\Str;
use Psr\Http\Message\ServerRequestInterface;

abstract class FlappTestCase extends TestCase
{
    /**
     * The calls the fake relay received. The tests stay PHP 7.3, as the 1.x
     * line runs them too.
     *
     * @var array[]
     */
    protected $relayCalls = [];

    /**
     * Start with the forum connected to a relay. Settings are read at boot,
     * so they can't go through prepareDatabase().
     */
    protected function connected(string $forumId = 'f_test'): void
    {
        $this->setting(Connection::FORUM_ID, $forumId);
        $this->setting(Connection::CONNECTED_RELAY_URL, 'https://relay.test');
    }

    /**
     * Answer the relay's calls with these responses, in order.
     */
    protected function fakeRelay(array $responses): void
    {
        $stack = HandlerStack::create(new MockHandler($responses));
        $stack->push(Middleware::history($this->relayCalls));

        $this->app()->getContainer()->instance(RelayClient::class, new RelayClient(new Client(['handler' => $stack])));
    }

    /**
     * Sign the request in as the user with a token in the Authorization
     * header, as the app does.
     *
     * @return array the request and the token's id
     */
    protected function withToken(ServerRequestInterface $request, int $userId): array
    {
        $token = Str::random(40);

        $id = $this->database()->table('access_tokens')->insertGetId([
            'token' => $token,
            'user_id' => $userId,
            'created_at' => Carbon::now()->toDateTimeString(),
            'last_activity_at' => Carbon::now()->toDateTimeString(),
            'type' => 'session_remember',
        ]);

        return [$request->withHeader('Authorization', "Token $token"), (int) $id];
    }

    protected function json($response): array
    {
        return json_decode((string) $response->getBody(), true) ?? [];
    }
}
