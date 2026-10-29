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

/**
 * What an app asks for when it opens /flapp/authorize: which app it is, the
 * one-time RSA public key (PEM) the sign-in is encrypted to, and a nonce the
 * app checks on the way back. The page and the approve call both read it.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class AuthorizeRequest
{
    /**
     * The payload must fit one RSA-OAEP block of a 2048-bit key (214 bytes),
     * so the nonce is kept short.
     */
    const NONCE_PATTERN = '/^[A-Za-z0-9_-]{16,64}$/';

    const MIN_KEY_BITS = 2048;

    const MAX_KEY_BITS = 4096;

    /**
     * @var string|null
     */
    public $appId;

    /**
     * @var string|null
     */
    public $publicKey;

    /**
     * @var string|null
     */
    public $nonce;

    public function __construct(array $params)
    {
        $this->appId = self::string($params, 'app');
        $this->publicKey = self::string($params, 'publicKey');
        $this->nonce = self::string($params, 'nonce');
    }

    /**
     * The first field that isn't valid, or null when the request is.
     */
    public function invalidField(): ?string
    {
        if ($this->app() === null) {
            return 'app';
        }

        if (! $this->keyIsUsable()) {
            return 'publicKey';
        }

        if ($this->nonce === null || ! preg_match(self::NONCE_PATTERN, $this->nonce)) {
            return 'nonce';
        }

        return null;
    }

    /**
     * @return array|null the app's name and redirect (Apps)
     */
    public function app(): ?array
    {
        return Apps::find($this->appId);
    }

    /**
     * The app's redirect with these query parameters.
     */
    public function redirectWith(array $query): string
    {
        return $this->app()['redirect'].'?'.http_build_query($query, '', '&', PHP_QUERY_RFC3986);
    }

    protected function keyIsUsable(): bool
    {
        if ($this->publicKey === null) {
            return false;
        }

        $key = openssl_pkey_get_public($this->publicKey);

        if ($key === false) {
            return false;
        }

        $details = openssl_pkey_get_details($key);

        return $details !== false
            && $details['type'] === OPENSSL_KEYTYPE_RSA
            && $details['bits'] >= self::MIN_KEY_BITS
            && $details['bits'] <= self::MAX_KEY_BITS;
    }

    protected static function string(array $params, string $key): ?string
    {
        return isset($params[$key]) && is_string($params[$key]) && $params[$key] !== '' ? $params[$key] : null;
    }
}
