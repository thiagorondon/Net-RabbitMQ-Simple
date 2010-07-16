#!/usr/bin/env perl

use Moose;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Net::RabbitMQ::Simple;
use Data::Dumper;

my $amqp = Net::RabbitMQ::Simple->new();
$amqp->connect;
$amqp->channel(1);

$amqp->exchange_name("nsms_api");
$amqp->queue_declare('nsms_api');

$amqp->consume(); 

my $rv = $amqp->recv(); 
print Dumper($rv);

$amqp->disconnect();

1;
