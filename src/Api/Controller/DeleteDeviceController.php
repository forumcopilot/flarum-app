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
use ForumCopilot\Flapp\Device;
use Illuminate\Support\Arr;
use Laminas\Diactoros\Response\EmptyResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 * DELETE /api/flapp-push/devices/{id}: the app stops pushes to this phone.
 * Another reader's device is answered as not found.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class DeleteDeviceController implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        $actor = RequestUtil::getActor($request);
        $actor->assertRegistered();

        Device::query()
            ->where('user_id', $actor->id)
            ->findOrFail((int) Arr::get($request->getQueryParams(), 'id'))
            ->delete();

        return new EmptyResponse(204);
    }
}
