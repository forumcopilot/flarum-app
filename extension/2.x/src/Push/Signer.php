<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Push;

use RuntimeException;

/**
 * Signs the forum's calls to the relay with its P-256 key.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class Signer
{
    /**
     * Make a new key pair.
     *
     * @return string[] the private key and the public key, both PEM
     */
    public static function generateKeyPair(): array
    {
        $key = openssl_pkey_new([
            'private_key_type' => OPENSSL_KEYTYPE_EC,
            'curve_name' => 'prime256v1',
        ]);

        if ($key === false || ! openssl_pkey_export($key, $privateKey)) {
            throw new RuntimeException('Could not make a signing key: '.openssl_error_string());
        }

        return [$privateKey, static::publicKey($privateKey)];
    }

    /**
     * The public half of a private key, PEM.
     */
    public static function publicKey(string $privateKey): string
    {
        $key = openssl_pkey_get_private($privateKey);
        $details = $key === false ? false : openssl_pkey_get_details($key);

        if ($details === false) {
            throw new RuntimeException('Could not read the signing key: '.openssl_error_string());
        }

        return $details['key'];
    }

    /**
     * What gets signed: the method, the path with its query, the Unix time
     * and the body's SHA-256, one per line.
     */
    public static function message(string $method, string $path, int $time, string $body): string
    {
        return implode("\n", [strtoupper($method), $path, (string) $time, hash('sha256', $body)]);
    }

    /**
     * Sign a call. The signature is the DER-encoded ECDSA signature over the
     * message's SHA-256, in unpadded base64url.
     */
    public static function sign(string $privateKey, string $method, string $path, int $time, string $body): string
    {
        if (! openssl_sign(static::message($method, $path, $time, $body), $signature, $privateKey, OPENSSL_ALGO_SHA256)) {
            throw new RuntimeException('Could not sign: '.openssl_error_string());
        }

        return rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');
    }

    /**
     * Check a signature as the relay does. The extension never needs this;
     * the tests and the relay's own checks do.
     */
    public static function verify(string $publicKey, string $method, string $path, int $time, string $body, string $signature): bool
    {
        $der = base64_decode(strtr($signature, '-_', '+/'), true);

        return $der !== false
            && openssl_verify(static::message($method, $path, $time, $body), $der, $publicKey, OPENSSL_ALGO_SHA256) === 1;
    }
}
