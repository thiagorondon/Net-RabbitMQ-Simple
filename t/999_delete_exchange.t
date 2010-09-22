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

    eval { 
        exchange_delete { 
            name => 'mtest_x',
            if_unused => 0, 
            nowait => 0
        };
    };
    is($@, '', 'exchange_delete');

    mqdisconnect;
}

1;

