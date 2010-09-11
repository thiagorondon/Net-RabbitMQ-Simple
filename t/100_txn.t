#!/usr/bin/env perl

use Test::More tests => 4;
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
    name => 'mtest_y',
    passive => 0,
    durable => 1,
    auto_delete => 1,
    exclusive => 0
};

tx $mq;

ok($mq->exchange_name);

publish $mq, {
    exchange => 'mtest_y',
    queue => 'mtesty',
    route => 'mtest_y_route',
    message => 'message',
    options => { content_type => 'text/plain' }
};

rollback $mq;

publish $mq, {
    exchange => 'mtest_y',
    queue => 'mtesty',
    route => 'mtest_y_route',
    message => 'message',
    options => { content_type => 'text/plain' }
};

commit $mq;

my $rv = {};
$rv = consume $mq;

ok($rv);

$rv = get $mq;

is($rv, undef);

eval {
    exchange_delete $mq, {
        name => 'mtest_y',
        options => { if_unused => 0, nowait => 0 }
    };
};
is($@, '', 'exchange_delete');

$mq->disconnect;

1;

