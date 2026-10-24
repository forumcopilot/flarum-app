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

use Flarum\Http\RequestUtil;
use ForumCopilot\Flapp\Connector;
use Laminas\Diactoros\Response\EmptyResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 * DELETE /api/flapp-push/connection: the admin page's Disconnect.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class DisconnectController implements RequestHandlerInterface
{
    /**
     * @var Connector
     */
    protected $connector;

    public function __construct(Connector $connector)
    {
        $this->connector = $connector;
    }

    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        RequestUtil::getActor($request)->assertAdmin();

        $this->connector->disconnect();

        return new EmptyResponse(204);
    }
}
