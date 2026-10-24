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

use ForumCopilot\Flapp\Device;

/**
 * A device as a JSON:API document, so the app reads it as it reads the rest
 * of Flarum's API. The handle isn't sent back: the app already has it.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class DeviceDocument
{
    public static function make(Device $device): array
    {
        return [
            'data' => [
                'type' => 'flappDevices',
                'id' => (string) $device->id,
                'attributes' => [
                    'platform' => $device->platform,
                    'app' => $device->app,
                    'locale' => $device->locale,
                    'createdAt' => $device->created_at->toAtomString(),
                ],
            ],
        ];
    }
}
