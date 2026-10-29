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
use Flarum\Http\CookieFactory;
use Flarum\Http\RememberAccessToken;
use Flarum\Http\RequestUtil;
use Flarum\User\Exception\PermissionDeniedException;
use ForumCopilot\Flapp\SignIn\AuthorizeRequest;
use ForumCopilot\Flapp\SignIn\SignInPayload;
use Laminas\Diactoros\Response\JsonResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Symfony\Contracts\Translation\TranslatorInterface;

/**
 * POST /api/flapp-auth/approve: the member taps Authorize on /flapp/authorize.
 * The forum makes them a remember token, the kind "Remember me" makes, encrypts
 * it to the app's key and answers with the app's redirect, which the page then
 * follows. The relay plays no part.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class ApproveSignInController implements RequestHandlerInterface
{
    /**
     * @var CookieFactory
     */
    protected $cookies;

    /**
     * @var TranslatorInterface
     */
    protected $translator;

    public function __construct(CookieFactory $cookies, TranslatorInterface $translator)
    {
        $this->cookies = $cookies;
        $this->translator = $translator;
    }

    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        $actor = RequestUtil::getActor($request);
        $actor->assertRegistered();

        // Only the member's own web session approves, on the forum's page and
        // with its CSRF token, which Flarum checks for a session: never a call
        // carrying a token or an API key.
        if ($request->getHeaderLine('authorization') !== '') {
            throw new PermissionDeniedException();
        }

        $body = $request->getParsedBody();
        $authorize = new AuthorizeRequest(is_array($body) ? $body : []);
        $field = $authorize->invalidField();

        if ($field !== null) {
            throw new ValidationException([$field => $this->translator->trans('forumcopilot-flapp.api.invalid_sign_in_request')]);
        }

        $token = RememberAccessToken::generate((int) $actor->id);
        $prefix = substr($this->cookies->getName('remember'), 0, -strlen('_remember'));

        $payload = SignInPayload::encrypt($token->token, (int) $actor->id, $authorize->nonce, $prefix, $authorize->publicKey);

        return new JsonResponse(['redirect' => $authorize->redirectWith(['payload' => $payload])]);
    }
}
