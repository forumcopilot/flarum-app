<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Api;

use Flarum\Api\Serializer\ForumSerializer;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Push\RelayClient;

/**
 * flappPush on GET /api, for everyone, guests included: the app reads it to
 * know the forum pushes, and where to get a handle. Absent until connected.
 *
 * Flarum 1.x only.
 */
class ForumAttributes
{
    /**
     * @var Connection
     */
    protected $connection;

    public function __construct(Connection $connection)
    {
        $this->connection = $connection;
    }

    public function __invoke(ForumSerializer $serializer, $model, array $attributes): array
    {
        if (! $this->connection->isConnected()) {
            return [];
        }

        return [
            'flappPush' => [
                'relay' => $this->connection->connectedRelayUrl(),
                'forumId' => $this->connection->forumId(),
                'version' => RelayClient::PROTOCOL_VERSION,
            ],
        ];
    }
}
