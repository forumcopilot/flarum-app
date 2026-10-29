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

use RuntimeException;

/**
 * The sign-in the forum hands the app, encrypted to the app's one-time public
 * key with RSA-OAEP (SHA-1, as OpenSSL and Discourse's User API Keys use), so
 * only the app that asked can read it, whoever catches the redirect.
 *
 * Shared by the 1.x and 2.x lines, so it stays PHP 7.3.
 */
class SignInPayload
{
    const VERSION = 1;

    /**
     * @return string the ciphertext, base64
     */
    public static function encrypt(string $token, int $userId, string $nonce, string $cookiePrefix, string $publicKey): string
    {
        $json = json_encode([
            'v' => self::VERSION,
            'token' => $token,
            'userId' => $userId,
            'nonce' => $nonce,
            'cookiePrefix' => $cookiePrefix,
        ]);

        if (! openssl_public_encrypt($json, $encrypted, $publicKey, OPENSSL_PKCS1_OAEP_PADDING)) {
            throw new RuntimeException('The sign-in could not be encrypted to the app\'s key.');
        }

        return base64_encode($encrypted);
    }
}
