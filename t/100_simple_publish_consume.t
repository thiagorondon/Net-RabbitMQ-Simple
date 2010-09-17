#!/usr/bin/env perl

use Test::More tests => 1;
use strict;

use Net::RabbitMQ::Simple;

my $host = $ENV{'MQHOST'};

SKIP: {
    skip 'No $ENV{\'MQHOST\'}\n', 1 unless $host;

    my $mq = mqconnect {
        hostname => $host,
        user => 'guest',
        password => 'guest',
        vhost => '/'
    };

    publish {
        exchange => 'mtest_x',
        queue => 'mtest',
        route => 'mtest_route',
        message => 'message',
        options => { content_type => 'text/plain' }
    };

    my $rv = {};
    $rv = consume;

    ok($rv);
    mqdisconnect;
}

1;

