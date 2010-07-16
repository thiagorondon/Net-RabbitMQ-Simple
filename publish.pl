#!/usr/bin/env perl

use Moose;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Net::RabbitMQ::Simple;

my $amqp = Net::RabbitMQ::Simple->new();

=head1 connect

    hostname => '127.0.0.1',
    username => 'guest',
    password => 'guest',
    vhost => '/',
    channel_max => 0,
    frame_max => 131072,
    heartbeat => 0

=cut

$amqp->connect;


=head1 channel

    argv1 - positive number describing the channel.

=cut

$amqp->channel(1);

=head1

    declare the exchange.
    argv1 - the name of the exchange to be instantiated.

=cut

$amqp->exchange_declare('nsms_api');

=head1

    declare the queue.
    argv1 - name of queue.
=cut

$amqp->queue_declare('nsms_api');

=head1

    is a previously declared queue, C<$exchange> is a
    previously declared exchange, and C<$routing_key> is the routing
    key that will bind the specified queue to the specified exchange.

=cut

$amqp->queue_bind('nsms_api_route');

=head1

    Here, we go.

=cut

$amqp->publish('foo');

# TODO
# content_type, encoding, reply_to, expiration, message_id, delivery_mode
# # timestamp, ......., ......, ...... .


=head1

    rabbitmqctl list_queues

=cut

$amqp->disconnect();

1;


1;

