<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Api\Controller;

use Flarum\Foundation\ValidationException;
use Flarum\Http\RequestUtil;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Connector;
use ForumCopilot\Flapp\Push\RelayException;
use Laminas\Diactoros\Response\JsonResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Symfony\Contracts\Translation\TranslatorInterface;

/**
 * POST /api/flapp-push/connection: the admin page's Connect.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class ConnectController implements RequestHandlerInterface
{
    /**
     * @var Connection
     */
    protected $connection;

    /**
     * @var Connector
     */
    protected $connector;

    /**
     * @var TranslatorInterface
     */
    protected $translator;

    public function __construct(Connection $connection, Connector $connector, TranslatorInterface $translator)
    {
        $this->connection = $connection;
        $this->connector = $connector;
        $this->translator = $translator;
    }

    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        RequestUtil::getActor($request)->assertAdmin();

        if ($this->connection->isConnected()) {
            throw new ValidationException(['connection' => $this->translator->trans('forumcopilot-flapp.api.already_connected')]);
        }

        try {
            $this->connector->connect();
        } catch (RelayException $e) {
            throw new ValidationException(['relay' => $this->translator->trans('forumcopilot-flapp.api.relay_failed', ['message' => $e->getMessage()])]);
        }

        return new JsonResponse([
            'relay' => $this->connection->connectedRelayUrl(),
            'forumId' => $this->connection->forumId(),
        ]);
    }
}
