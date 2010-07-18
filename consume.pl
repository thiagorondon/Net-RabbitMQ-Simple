#!/usr/bin/env perl

use Moose;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Net::RabbitMQ::Simple;
use Data::Dumper;

my $amqp = Net::RabbitMQ::Simple->new();
$amqp->connect;
$amqp->channel(1);

$amqp->exchange_name("foo_api");
$amqp->queue_declare('foo_api');

while (1) {
    print "Waiting for consume...\n";
    $amqp->consume(); 
    my $rv = $amqp->recv(); 
    print Dumper($rv);
    print "Done.\n";
}

$amqp->disconnect();

1;
