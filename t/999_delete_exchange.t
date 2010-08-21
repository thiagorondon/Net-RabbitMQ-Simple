#!/usr/bin/env perl

use Test::More tests => 1;
use strict;

use Net::RabbitMQ::Simple;

my $host = $ENV{'MQHOST'} || "dev.rabbitmq.com";

my $mq = mqconnect {
    hostname => $host,
    user => 'guest',
    password => 'guest',
    vhost => '/'
};

eval { 
    exchange_delete $mq, { 
        name => 'mtest_x',
        options => { if_unused => 0, nowait => 0 }
    };
};
is($@, '', 'exchange_delete');

1;

