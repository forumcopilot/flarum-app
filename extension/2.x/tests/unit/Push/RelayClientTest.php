<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Tests\unit\Push;

use ForumCopilot\Flapp\Push\RelayClient;
use ForumCopilot\Flapp\Push\RelayException;
use ForumCopilot\Flapp\Push\Signer;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\ConnectException;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Middleware;
use GuzzleHttp\Psr7\Request;
use GuzzleHttp\Psr7\Response;
use PHPUnit\Framework\TestCase;

class RelayClientTest extends TestCase
{
    /**
     * @var string
     */
    protected $privateKey;

    protected function setUp(): void
    {
        list($this->privateKey) = Signer::generateKeyPair();
    }

    protected function client(array $responses): RelayClient
    {
        return new RelayClient(new Client(['handler' => HandlerStack::create(new MockHandler($responses))]));
    }

    public function test_a_refusal_carries_the_relays_words_and_status(): void
    {
        $client = $this->client([new Response(429, [], json_encode(['error' => 'Too many enrolments']))]);

        try {
            $client->enrol('https://relay.test', 'https://forum.test', 'Forum', $this->privateKey);
            $this->fail('A refusal throws.');
        } catch (RelayException $e) {
            $this->assertEquals(429, $e->getCode());
            $this->assertStringContainsString('Too many enrolments', $e->getMessage());
        }
    }

    public function test_an_unreachable_relay_throws(): void
    {
        $client = $this->client([new ConnectException('Connection refused', new Request('POST', 'https://relay.test'))]);

        $this->expectException(RelayException::class);

        $client->enrol('https://relay.test', 'https://forum.test', 'Forum', $this->privateKey);
    }

    public function test_a_forum_the_relay_no_longer_knows_counts_as_forgotten(): void
    {
        $client = $this->client([new Response(404), new Response(410)]);

        $client->forget('https://relay.test', 'f_abc', $this->privateKey);
        $client->forget('https://relay.test', 'f_abc', $this->privateKey);

        $this->addToAssertionCount(1);
    }

    public function test_any_other_refusal_to_forget_throws(): void
    {
        $client = $this->client([new Response(500)]);

        $this->expectException(RelayException::class);

        $client->forget('https://relay.test', 'f_abc', $this->privateKey);
    }

    public function test_a_push_answers_with_the_handles_that_are_gone(): void
    {
        $client = $this->client([new Response(200, [], json_encode(['sent' => 1, 'gone' => ['aaaaaaaaaaaaaaaaaaaaaa', 42]]))]);

        $gone = $client->push('https://relay.test', 'f_abc', $this->privateKey, [['handle' => 'aaaaaaaaaaaaaaaaaaaaaa', 'payload' => ['v' => 1]]]);

        $this->assertSame(['aaaaaaaaaaaaaaaaaaaaaa'], $gone);
    }

    public function test_a_push_names_the_forums_title_when_given(): void
    {
        $calls = [];
        $stack = HandlerStack::create(new MockHandler([
            new Response(200, [], json_encode(['sent' => 1, 'gone' => []])),
            new Response(200, [], json_encode(['sent' => 1, 'gone' => []])),
        ]));
        $stack->push(Middleware::history($calls));
        $client = new RelayClient(new Client(['handler' => $stack]));
        $pushes = [['handle' => 'aaaaaaaaaaaaaaaaaaaaaa', 'payload' => ['v' => 1]]];

        $client->push('https://relay.test', 'f_abc', $this->privateKey, $pushes, 'Flarum 2.0 Demo Community');
        $client->push('https://relay.test', 'f_abc', $this->privateKey, $pushes);

        $this->assertSame(
            ['forumId' => 'f_abc', 'forumTitle' => 'Flarum 2.0 Demo Community', 'pushes' => $pushes],
            json_decode((string) $calls[0]['request']->getBody(), true)
        );
        $this->assertSame(['forumId' => 'f_abc', 'pushes' => $pushes], json_decode((string) $calls[1]['request']->getBody(), true));
    }

    public function test_a_push_the_relay_has_already_seen_counts_as_sent(): void
    {
        $client = $this->client([new Response(409, [], json_encode(['error' => 'The relay has already seen this call.']))]);

        $this->assertSame([], $client->push('https://relay.test', 'f_abc', $this->privateKey, [['handle' => 'aaaaaaaaaaaaaaaaaaaaaa', 'payload' => ['v' => 1]]]));
    }

    public function test_a_refused_push_throws(): void
    {
        $client = $this->client([new Response(422, [], json_encode(['error' => 'pushes[0]: payload.title must be a string']))]);

        $this->expectException(RelayException::class);

        $client->push('https://relay.test', 'f_abc', $this->privateKey, [['handle' => 'aaaaaaaaaaaaaaaaaaaaaa', 'payload' => ['v' => 1]]]);
    }
}
