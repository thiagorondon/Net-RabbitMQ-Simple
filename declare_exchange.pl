#!/usr/bin/env perl

use Moose;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Net::RabbitMQ::Simple;

my $amqp = Net::RabbitMQ::Simple->new();
$amqp->connect;
$amqp->channel(1);
$amqp->exchange_declare("foo_api");

$amqp->disconnect();

1;

