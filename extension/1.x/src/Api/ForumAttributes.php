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
use Flarum\Http\UrlGenerator;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Push\RelayClient;
use ForumCopilot\Flapp\SignIn\SignInPayload;

/**
 * On GET /api, for everyone, guests included:
 *
 * - flappPush: the app reads it to know the forum pushes, and where to get a
 *   handle. Absent until connected.
 * - flappSignIn: the app signs in through the forum's /flapp/authorize page,
 *   in the phone's browser. Whenever the extension is on, connected or not.
 *
 * Flarum 1.x only.
 */
class ForumAttributes
{
    /**
     * @var Connection
     */
    protected $connection;

    /**
     * @var UrlGenerator
     */
    protected $url;

    public function __construct(Connection $connection, UrlGenerator $url)
    {
        $this->connection = $connection;
        $this->url = $url;
    }

    public function __invoke(ForumSerializer $serializer, $model, array $attributes): array
    {
        $attributes = [
            'flappSignIn' => [
                'version' => SignInPayload::VERSION,
                'authorizeUrl' => $this->url->to('forum')->route('flapp.authorize'),
            ],
        ];

        if ($this->connection->isConnected()) {
            $attributes['flappPush'] = [
                'relay' => $this->connection->connectedRelayUrl(),
                'forumId' => $this->connection->forumId(),
                'version' => RelayClient::PROTOCOL_VERSION,
            ];
        }

        return $attributes;
    }
}
