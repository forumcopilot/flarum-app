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

use Flarum\Settings\SettingsRepositoryInterface;
use ForumCopilot\Flapp\Push\RelayClient;
use Illuminate\Database\ConnectionInterface;

/**
 * Whether the forum is connected to the relay, and with what.
 *
 * The forum's id and the relay's address are settings: they are public, in
 * GET /api. The private key has its own table, because Flarum sends every
 * setting to the admin page.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class Connection
{
    /**
     * The relay to connect to. Unset means RelayClient::DEFAULT_URL; set it
     * by hand to use another relay, such as staging.
     */
    const RELAY_URL = 'forumcopilot-flapp.relay_url';

    /**
     * The relay the forum is connected to, and its id there.
     */
    const CONNECTED_RELAY_URL = 'forumcopilot-flapp.connected_relay_url';
    const FORUM_ID = 'forumcopilot-flapp.forum_id';

    const KEYS_TABLE = 'flapp_keys';

    /**
     * @var SettingsRepositoryInterface
     */
    protected $settings;

    /**
     * @var ConnectionInterface
     */
    protected $db;

    public function __construct(SettingsRepositoryInterface $settings, ConnectionInterface $db)
    {
        $this->settings = $settings;
        $this->db = $db;
    }

    public function isConnected(): bool
    {
        return $this->forumId() !== null;
    }

    public function forumId(): ?string
    {
        $forumId = $this->settings->get(self::FORUM_ID);

        return $forumId ? (string) $forumId : null;
    }

    public function connectedRelayUrl(): ?string
    {
        return $this->isConnected() ? (string) $this->settings->get(self::CONNECTED_RELAY_URL) : null;
    }

    public function relayUrlToConnect(): string
    {
        return (string) ($this->settings->get(self::RELAY_URL) ?: RelayClient::DEFAULT_URL);
    }

    public function privateKey(): ?string
    {
        $forumId = $this->forumId();

        if ($forumId === null) {
            return null;
        }

        $privateKey = $this->db->table(self::KEYS_TABLE)->where('forum_id', $forumId)->value('private_key');

        return $privateKey ? (string) $privateKey : null;
    }

    public function store(string $relayUrl, string $forumId, string $privateKey): void
    {
        $this->db->table(self::KEYS_TABLE)->insert([
            'forum_id' => $forumId,
            'private_key' => $privateKey,
            'created_at' => date('Y-m-d H:i:s'),
        ]);

        $this->settings->set(self::CONNECTED_RELAY_URL, $relayUrl);
        $this->settings->set(self::FORUM_ID, $forumId);
    }

    public function clear(): void
    {
        $this->db->table(self::KEYS_TABLE)->delete();

        $this->settings->delete(self::FORUM_ID);
        $this->settings->delete(self::CONNECTED_RELAY_URL);
    }
}
