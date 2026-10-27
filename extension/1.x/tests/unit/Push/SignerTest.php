<?php

/*
 * This file is part of forumcopilot/flarum-flapp.
 *
 * Copyright (c) ForumCopilot.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace ForumCopilot\Flapp\Tests\unit\Push;

use ForumCopilot\Flapp\Push\Signer;
use PHPUnit\Framework\TestCase;

class SignerTest extends TestCase
{
    public function test_signs_the_method_path_time_and_body(): void
    {
        $this->assertEquals(
            "POST\n/v1/forums\n1792800000\n".hash('sha256', '{"a":1}'),
            Signer::message('post', '/v1/forums', 1792800000, '{"a":1}')
        );
    }

    public function test_a_signature_checks_out_with_the_public_key(): void
    {
        list($privateKey, $publicKey) = Signer::generateKeyPair();

        $signature = Signer::sign($privateKey, 'POST', '/v1/push', 1792800000, '{"pushes":[]}');

        $this->assertMatchesRegularExpression('/^[A-Za-z0-9_-]+$/', $signature, 'unpadded base64url');
        $this->assertTrue(Signer::verify($publicKey, 'POST', '/v1/push', 1792800000, '{"pushes":[]}', $signature));
        $this->assertEquals($publicKey, Signer::publicKey($privateKey));
    }

    public function test_any_change_breaks_the_signature(): void
    {
        list($privateKey, $publicKey) = Signer::generateKeyPair();
        list(, $otherPublicKey) = Signer::generateKeyPair();

        $signature = Signer::sign($privateKey, 'POST', '/v1/push', 1792800000, '{"pushes":[]}');

        $this->assertFalse(Signer::verify($publicKey, 'DELETE', '/v1/push', 1792800000, '{"pushes":[]}', $signature));
        $this->assertFalse(Signer::verify($publicKey, 'POST', '/v1/forums', 1792800000, '{"pushes":[]}', $signature));
        $this->assertFalse(Signer::verify($publicKey, 'POST', '/v1/push', 1792800001, '{"pushes":[]}', $signature));
        $this->assertFalse(Signer::verify($publicKey, 'POST', '/v1/push', 1792800000, '{"pushes":[1]}', $signature));
        $this->assertFalse(Signer::verify($otherPublicKey, 'POST', '/v1/push', 1792800000, '{"pushes":[]}', $signature));
        $this->assertFalse(Signer::verify($publicKey, 'POST', '/v1/push', 1792800000, '{"pushes":[]}', 'not!base64'));
    }

    /**
     * The relay's own tests check the same samples, so both sides agree on
     * what a signature is.
     */
    public function test_the_shared_samples_check_out(): void
    {
        $samples = json_decode(file_get_contents(__DIR__.'/../../fixtures/signed-samples.json'), true);

        $this->assertNotEmpty($samples['samples']);

        foreach ($samples['samples'] as $sample) {
            $this->assertTrue(Signer::verify(
                $samples['publicKey'],
                $sample['method'],
                $sample['path'],
                $sample['time'],
                $sample['body'],
                $sample['signature']
            ), $sample['method'].' '.$sample['path']);
        }
    }
}
