#!/usr/bin/env perl

use Test::More tests => 3;
use strict;

use Net::RabbitMQ::Simple;

my $host = $ENV{'MQHOST'} || "dev.rabbitmq.com";

my $mq = mqconnect {
    hostname => $host,
    user => 'guest',
    password => 'guest',
    vhost => '/'
};

exchange {
    name => 'ex_topic',
    type => 'topic',
    passive => 0,
    durable => 1,
    auto_delete => 1,
    exclusive => 0
};

ok($mq->exchange_name);

publish {
    exchange => 'ex_topic',
    queue => 'foo.bar',
    route => 'foo.bar',
    message => 'message foo.bar',
    options => { content_type => 'text/plain' }
};

my $rv = {};

$rv = get { options => { 
        exchange => 'ex_topic',
        routing_key => 'foo.*' } 
};
ok($rv);

publish {
    exchange => 'ex_topic',
    queue => 'foo.baz',
    route => 'foo.baz',
    message => 'message foo.baz',
    options => { 
        exchange => 'ex_topic',
        content_type => 'text/plain' }
};

$rv = get { options => { routing_key => '#.baz' } } ;

ok($rv);

1;

