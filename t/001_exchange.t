#!/usr/bin/env perl

use Test::More tests => 2;
use strict;

use Net::RabbitMQ::Simple;

my $host = $ENV{'MQHOST'} || "dev.rabbitmq.com";

my $mq = mqconnect {
    hostname => $host,
    user => 'guest',
    password => 'guest',
    vhost => '/'
};

exchange $mq, {
    name => 'mtest_x',
    type => 'direct',
    passive => 0,
    durable => 1,
    auto_delete => 0,
    exclusive => 0
};
is($mq->exchange_type, 'direct');
ok($mq->exchange_name);

1;

