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

1;

