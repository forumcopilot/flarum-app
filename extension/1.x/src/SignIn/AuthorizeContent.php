<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\SignIn;

use Flarum\Frontend\Document;
use Psr\Http\Message\ServerRequestInterface;
use Symfony\Contracts\Translation\TranslatorInterface;

/**
 * /flapp/authorize, a page of the forum's own frontend: its theme, language,
 * Log In and Sign Up modals, CAPTCHAs and OAuth buttons. This checks the
 * request and hands the page what it shows (flappAuthorize in app.data); the
 * forum JS draws it.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class AuthorizeContent
{
    /**
     * @var TranslatorInterface
     */
    protected $translator;

    public function __construct(TranslatorInterface $translator)
    {
        $this->translator = $translator;
    }

    public function __invoke(Document $document, ServerRequestInterface $request)
    {
        $authorize = new AuthorizeRequest($request->getQueryParams());
        $app = $authorize->app();

        $document->title = $this->translator->trans('forumcopilot-flapp.forum.authorize.title', ['app' => $app ? $app['name'] : 'Flapp']);

        $document->payload['flappAuthorize'] = $authorize->invalidField() === null
            ? [
                'app' => $authorize->appId,
                'appName' => $app['name'],
                'cancelUrl' => $authorize->redirectWith(['error' => 'cancelled']),
            ]
            : ['error' => true];
    }
}
