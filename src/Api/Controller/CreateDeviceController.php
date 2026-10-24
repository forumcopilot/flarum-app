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

use Carbon\Carbon;
use Flarum\Foundation\ValidationException;
use Flarum\Http\AccessToken;
use Flarum\Http\RequestUtil;
use ForumCopilot\Flapp\Api\DeviceDocument;
use ForumCopilot\Flapp\Connection;
use ForumCopilot\Flapp\Device;
use Illuminate\Support\Str;
use Laminas\Diactoros\Response\JsonResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Symfony\Contracts\Translation\TranslatorInterface;

/**
 * POST /api/flapp-push/devices: the app registers the phone for the reader
 * whose token makes the call.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class CreateDeviceController implements RequestHandlerInterface
{
    /**
     * A handle is the relay's: unpadded base64url.
     */
    const HANDLE_PATTERN = '/^[A-Za-z0-9_-]{16,128}$/';

    const APP_PATTERN = '/^[a-z0-9][a-z0-9.-]{0,39}$/';

    const LOCALE_PATTERN = '/^[A-Za-z]{2,3}([_-][A-Za-z0-9]{2,8}){0,3}$/';

    /**
     * @var Connection
     */
    protected $connection;

    /**
     * @var TranslatorInterface
     */
    protected $translator;

    public function __construct(Connection $connection, TranslatorInterface $translator)
    {
        $this->connection = $connection;
        $this->translator = $translator;
    }

    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        $actor = RequestUtil::getActor($request);
        $actor->assertRegistered();

        // A device hangs on the access token that registered it, so the call
        // must carry one in its header, as the app's calls do. Flarum's own
        // middleware doesn't hand the token on.
        $token = $this->headerToken($request);

        if ($token === null || (int) $token->user_id !== (int) $actor->id) {
            throw new ValidationException(['token' => $this->translator->trans('forumcopilot-flapp.api.token_needed')]);
        }

        if (! $this->connection->isConnected()) {
            throw new ValidationException(['flappPush' => $this->translator->trans('forumcopilot-flapp.api.not_connected')]);
        }

        $body = $request->getParsedBody();
        $body = is_array($body) ? $body : [];

        $handle = $this->string($body, 'handle');
        $platform = $this->string($body, 'platform');
        $app = $this->string($body, 'app');
        $locale = $this->string($body, 'locale');

        $errors = [];

        if ($handle === null || ! preg_match(self::HANDLE_PATTERN, $handle)) {
            $errors['handle'] = $this->translator->trans('forumcopilot-flapp.api.invalid_handle');
        }

        if (! in_array($platform, Device::PLATFORMS, true)) {
            $errors['platform'] = $this->translator->trans('forumcopilot-flapp.api.invalid_platform');
        }

        if ($app === null || ! preg_match(self::APP_PATTERN, $app)) {
            $errors['app'] = $this->translator->trans('forumcopilot-flapp.api.invalid_app');
        }

        if ($locale !== null && ! preg_match(self::LOCALE_PATTERN, $locale)) {
            $errors['locale'] = $this->translator->trans('forumcopilot-flapp.api.invalid_locale');
        }

        if ($errors) {
            throw new ValidationException($errors);
        }

        // A handle belongs to one phone and forum. Registering it again, after
        // a new sign-in or as another reader on the same phone, moves it.
        /** @var Device $device */
        $device = Device::query()->where('handle', $handle)->first() ?: new Device();

        $device->handle = $handle;
        $device->user_id = $actor->id;
        $device->access_token_id = $token->id;
        $device->platform = $platform;
        $device->app = $app;
        $device->locale = $locale;
        $device->created_at = Carbon::now();
        $device->save();

        $keep = Device::query()
            ->where('user_id', $actor->id)
            ->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc')
            ->limit(Device::LIMIT)
            ->pluck('id')
            ->all();

        Device::query()->where('user_id', $actor->id)->whereNotIn('id', $keep)->delete();

        return new JsonResponse(DeviceDocument::make($device), 201, ['Content-Type' => 'application/vnd.api+json']);
    }

    protected function headerToken(ServerRequestInterface $request): ?AccessToken
    {
        $parts = explode(';', $request->getHeaderLine('authorization'));
        $prefix = 'Token ';

        if (! Str::startsWith($parts[0], $prefix)) {
            return null;
        }

        return AccessToken::findValid(trim(substr($parts[0], strlen($prefix))));
    }

    protected function string(array $body, string $key): ?string
    {
        return isset($body[$key]) && is_string($body[$key]) && $body[$key] !== '' ? $body[$key] : null;
    }
}
