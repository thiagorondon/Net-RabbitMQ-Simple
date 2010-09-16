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
    queue => 'mtest_ack',
    queue_options => { passive => 0, durable => 1, exclusive => 0, auto_delete => 0 },
    route => 'mtest_route',
    ack => 1,
    message => 'message2',
    options => { content_type => 'text/plain' }
};

my $rv = {};
$rv = consume { ack => 1 };

$rv->{delivery_tag} = 10;
mqdisconnect;

$mq = mqconnect {
    hostname => $host,
};

$rv = consume {
    exchange => 'mtest_x',
    ack => 1,
    queue => 'mtest_ack'
};

my $acktag = $rv->{delivery_tag};
$rv->{delivery_tag} = 10;
ack $acktag;
ok($rv);

mqdisconnect;

1;

