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
}
