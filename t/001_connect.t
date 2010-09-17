#!/usr/bin/env perl

use Test::More tests => 1;
use strict;

use Net::RabbitMQ::Simple;

#my $host = $ENV{'MQHOST'} || "dev.rabbitmq.com";
my $host = $ENV{'MQHOST'};

SKIP: {
    skip 'No $ENV{\'MQHOST\'}\n', 1 unless $host;
    
    my $mq = mqconnect {
        hostname => $host,
        user => 'guest',
        password => 'guest',
        vhost => '/'
    };

    is(ref $mq, 'Net::RabbitMQ::Simple::Wrapper');

    mqdisconnect;
}

1;

