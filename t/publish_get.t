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

publish $mq, {
    exchange => 'mtest_x',
    queue => 'mtest',
    route => 'mtest_route',
    message => 'message',
    options => { content_type => 'text/plain' }
};

my $getr = get $mq;
ok($getr);

$getr = get $mq;
is($getr, undef, 'get should return empty');

1;


