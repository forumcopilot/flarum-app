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

use Carbon\Carbon;
use ForumCopilot\Flapp\Push\PayloadBuilder;
use PHPUnit\Framework\TestCase;

class PayloadBuilderTest extends TestCase
{
    public function test_a_reaction_shows_as_its_emoji_however_fof_reactions_hands_it_over(): void
    {
        $model = new \stdClass();
        $model->identifier = 'heart';
        $model->display = null;

        $this->assertEquals('❤️', PayloadBuilder::reaction($model));
        $this->assertEquals('❤️', PayloadBuilder::reaction('{"id":5,"identifier":"heart","type":"emoji","enabled":true,"display":null}'));
        $this->assertEquals('👍', PayloadBuilder::reaction(['identifier' => 'thumbsup']));
        $this->assertEquals('👍', PayloadBuilder::reaction('thumbsup'));
    }

    public function test_another_reaction_shows_its_display_name_or_identifier(): void
    {
        $this->assertEquals('Insightful', PayloadBuilder::reaction(['identifier' => 'fas fa-lightbulb', 'display' => 'Insightful']));
        $this->assertEquals('sparkles', PayloadBuilder::reaction('sparkles'));
    }

    public function test_a_days_suspension_pushed_a_few_seconds_later_is_still_a_day(): void
    {
        $now = Carbon::parse('2026-10-26 21:29:02');

        $this->assertEquals('1 day', PayloadBuilder::suspendedFor($now->copy()->addDay()->subSeconds(5), 'en', $now));
        $this->assertEquals('3 days', PayloadBuilder::suspendedFor($now->copy()->addDays(3), 'en', $now));
        $this->assertEquals('1 Tag', PayloadBuilder::suspendedFor($now->copy()->addDay()->subSeconds(5), 'de', $now));
    }
}
