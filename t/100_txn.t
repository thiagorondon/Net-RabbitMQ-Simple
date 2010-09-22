#!/usr/bin/env perl

use Test::More tests => 4;
use strict;

use Net::RabbitMQ::Simple;

my $host = $ENV{'MQHOST'};

SKIP: {
    skip 'No $ENV{\'MQHOST\'}\n', 4 unless $host;

    my $mq = mqconnect {
        hostname => $host,
        user => 'guest',
        password => 'guest',
        vhost => '/'
    };

    exchange {
        name => 'mtest_y',
        passive => 0,
        durable => 1,
        auto_delete => 1,
        exclusive => 0
    };

    tx;

    ok($mq->exchange_name);

    publish {
        exchange => 'mtest_y',
        queue => 'mtesty',
        route => 'mtest_y_route',
        message => 'message',
        options => { content_type => 'text/plain' }
    };

    rollback ;

    publish {
        exchange => 'mtest_y',
        queue => 'mtesty',
        route => 'mtest_y_route',
        message => 'message',
        options => { content_type => 'text/plain' }
    };

    commit;

    my $rv = {};
    $rv = consume; 

    ok($rv);

    $rv = get;

    is($rv, undef);

    eval {
        exchange_delete {
            name => 'mtest_y',
            if_unused => 0, 
            nowait => 0
        };
    };
    is($@, '', 'exchange_delete');

    mqdisconnect;
}

1;

