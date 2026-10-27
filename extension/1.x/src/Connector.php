<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp;

use Flarum\Http\UrlGenerator;
use Flarum\Settings\SettingsRepositoryInterface;
use ForumCopilot\Flapp\Push\RelayClient;
use ForumCopilot\Flapp\Push\RelayException;
use ForumCopilot\Flapp\Push\Signer;
use Psr\Log\LoggerInterface;

/**
 * Connects the forum to the relay, and disconnects it.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class Connector
{
    /**
     * @var Connection
     */
    protected $connection;

    /**
     * @var RelayClient
     */
    protected $relay;

    /**
     * @var SettingsRepositoryInterface
     */
    protected $settings;

    /**
     * @var UrlGenerator
     */
    protected $url;

    /**
     * @var LoggerInterface
     */
    protected $log;

    public function __construct(Connection $connection, RelayClient $relay, SettingsRepositoryInterface $settings, UrlGenerator $url, LoggerInterface $log)
    {
        $this->connection = $connection;
        $this->relay = $relay;
        $this->settings = $settings;
        $this->url = $url;
        $this->log = $log;
    }

    /**
     * Make a signing key, enrol the forum with the relay and keep its id.
     *
     * @return string the forum's id on the relay
     * @throws RelayException
     */
    public function connect(): string
    {
        list($privateKey) = Signer::generateKeyPair();
        $relayUrl = $this->connection->relayUrlToConnect();

        $forumId = $this->relay->enrol(
            $relayUrl,
            $this->url->to('forum')->base(),
            (string) $this->settings->get('forum_title'),
            $privateKey
        );

        $this->connection->store($relayUrl, $forumId, $privateKey);

        return $forumId;
    }

    /**
     * Forget the connection and every device registered under it. The relay
     * is asked to forget the forum too; if it can't be reached, the forum is
     * disconnected all the same, and without the key nothing can push to its
     * old handles.
     */
    public function disconnect(): void
    {
        $forumId = $this->connection->forumId();

        if ($forumId === null) {
            return;
        }

        $relayUrl = $this->connection->connectedRelayUrl();
        $privateKey = $this->connection->privateKey();

        if ($relayUrl && $privateKey) {
            try {
                $this->relay->forget($relayUrl, $forumId, $privateKey);
            } catch (RelayException $e) {
                $this->log->warning('[forumcopilot/flarum-flapp] Disconnected without the relay: '.$e->getMessage());
            }
        }

        Device::query()->delete();

        $this->connection->clear();
    }
}
