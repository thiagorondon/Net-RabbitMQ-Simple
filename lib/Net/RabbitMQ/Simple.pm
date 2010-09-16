package Net::RabbitMQ::Simple;
our $VERSION = "0.0003";

use Moose;
use 5.008001;
use Devel::Declare ();
use Carp qw/ confess /;

extends 'Devel::Declare::Context::Simple';

use aliased 'Net::RabbitMQ::Simple::Wrapper';

=head1 NAME

Net::RabbitMQ::Simple - A simple syntax for Net::RabbitMQ

=head1 VERSION

This document describes NET::RabbitMQ::Simple version 0.0002

=head1 SYNOPSIS


    use Net::RabbitMQ::Simple;

    mqconnect {
        hostname => 'localhost',
        user => 'guest',
        password => 'guest',
        vhost => '/'
    };

    exchange {
        name => 'mtest_x',
        type => 'direct',
        passive => 0,
        durable => 1,
        auto_delete => 0,
        exclusive => 0
    };

    publish {
        exchange => 'maketest',
        queue => 'mtest',
        route => 'mtest_route',
        message => 'message',
        options => { content_type => 'text/plain' }
    };

    my $rv = consume;

    # or
    # my $rv = get { options => { routing_key => 'foo.*' }}

    # use Data::Dumper;
    # print Dumper($rv);

    mqdisconnect;

=head1 DESCRIPTION

This package implements a simple syntax on top of L<Net::RabbitMQ>. With the
help of this package it is possible to write simple AMQP applications with a
few lines of perl code.

=head1 METHODS

=cut

=head2 mqconnect

Connect to AMQP server using librabbitmq.

    my $mq = mqconnect ({
        user => 'guest'
        password => 'guest',
        vhost => '/',
        channel_max => 0,
        frame_max => 131072,
        heartbeat => 0
    });

=cut

our $_mq;

sub mqconnect (@) {
    $_mq = Wrapper->new(@_);
    $_mq->connect;
    $_mq->channel(1); #TODO
    return $_mq;
}

=head2 exchange

Declare an exchange for work.

    exchange {
        name => 'name_of_exchange',
        exchange_type => 'direct',
        passive => 0,
        durable => 0,
        auto_delete => 1
    };

=cut

sub exchange (@) {
    my ($opt) = @_;
    my $exchange = $opt->{name};
    Carp::confess("please give the exchange name") if !$exchange;
    delete $opt->{name};

    $_mq->exchange_declare($exchange, %{$opt});
}

=head2 exchange_delete

Delete an exchange if is possible.

    exchange_delete {
        name => 'name_of_exchange',
        if_unused => 1,
        nowait => 0
    };

=cut

sub exchange_delete (@) {
    my ($opt) = @_;
    
    my $exchange = $opt->{name};
    Carp::confess("please give the exchange name") if !$exchange;
    delete $opt->{name};

    $_mq->exchange_delete($exchange, %{$opt});
}
=head2 exchange_publish

Publish a new message.

    publish {
        exchange => 'exchange',
        queue => 'queue',
        route => 'route',
        message => 'message',
        options => { content_type => 'text/plain' }
    };

=cut

sub publish (@) {
    my ($opt) = @_;
   
    $_mq->exchange_name($opt->{exchange}) if $opt->{exchange};

    $_mq->queue_declare($opt->{queue}, %{$opt->{queue_options}});
    $_mq->queue_bind($opt->{route});

    map { $_mq->$_($opt->{$_}) if defined($opt->{$_}) }
        qw/mandatory immediate/;
    
    # ACKs
    $_mq->purge($_mq->queue_name) 
        if defined($opt->{ack}) and $opt->{ack} == 1;

    $_mq->publish($opt->{message}, %{$opt->{options}});
}

=head2 consume

Consume messages from queue.

    consume {
        queue => 'name'
    };

=cut

sub consume (@) {
    my ($opt) = @_;
    $_mq->no_ack(0) if defined($opt->{ack}) and $opt->{ack} == 1;
    $_mq->exchange_name($opt->{exchange}) if defined($opt->{exchange});
    $_mq->queue_declare($opt->{queue}) if defined($opt->{queue});

    $_mq->consume($opt->{options} || ());
    $_mq->recv();
}

=head2 get

Consume messages from queue, but return undef if doesn't have message.

    get {
        queue => 'queue',
        options => { routing_key => 'foo' }
    };

=cut

sub get (@) {
    my ($opt) = @_;
    $_mq->no_ack(0) if defined($opt->{ack}) and $opt->{ack} == 1;
    $_mq->exchange_name($opt->{exchange}) if defined($opt->{exchange});
    $_mq->queue_declare($opt->{queue}) if defined($opt->{queue});

    $_mq->get($opt->{options} ? %{$opt->{options}} : ());
}

sub tx (@) { $_mq->tx(); }
sub commit (@) { $_mq->commit(); }
sub rollback (@) { $_mq->rollback(); }

sub purge (@) { $_mq->purge(@_) }
sub ack (@) { $_mq->ack(@_) }
sub mqdisconnect(@) { $_mq->disconnect(@_) }

sub import {
    my $class = shift;
    my $caller = caller;
    my $ctx = __PACKAGE__->new;

    my @cmds = ( 'mqconnect', 'publish', 'consume', 'purge', 'ack',
        'mqdisconnect', 'exchange', 'get', 'exchange_delete',
        'tx', 'commit', 'rollback');

    Devel::Declare->setup_for(
        $caller, {
            map { $_ => { const => sub { $ctx->parser(@_) } } } @cmds
        }
    );

    no strict 'refs';
    map { *{$caller."::$_"} = \&$_ } @cmds;
}

sub parser {
    my $self = shift;
    $self->init(@_);
    $self->skip_declarator;

    my $name = $self->strip_name;
    my $proto = $self->strip_proto;
    
    # TODO
#    my ($mq, $opt);

#    if (ref($_[1]) eq 'HASH') {
#       ($mq, $opt) = @_;
#    } else {
#       $mq = $_mq;
#       ($opt) = @_;
#    }


    return;
}

1;

=head1 SUPPORT

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/tbr/Bugs.html?Dist=Net-RabbitMQ-Simple>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-RabbitMQ-Simple>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-RabbitMQ-Simple>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-RabbitMQ-Simple>

=back

=head1 SEE ALSO

L<Net::RabbitMQ>, L<Devel::Declare>

=head1 AUTHOR

Thiago Rondon. <thiago@aware.com.br>

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

=cut


