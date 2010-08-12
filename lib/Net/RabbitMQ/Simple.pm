
package Net::RabbitMQ::Simple;
our $VERSION = "0.0002";

use Moose;
use 5.008001;
use Devel::Declare ();
use Carp qw/ confess /;

extends 'Devel::Declare::Context::Simple';

use aliased 'Net::RabbitMQ::Simple::Wrapper';

sub mqconnect (@_) {
    my $mq = Wrapper->new(@_);
    $mq->connect;
    $mq->channel(1); #TODO
    return $mq;
}

sub exchange (@_) {
    my ($mq, $opt) = @_;
    
    my $exchange = $opt->{exchange};
    Carp::confess("please give the exchange name") if !$exchange;
    delete $opt->{exchange};

    $mq->exchange_declare($exchange, %{$opt});
}

sub exchange_delete (@_) {
    my ($mq, $opt) = @_;
    
    my $exchange = $opt->{exchange};
    Carp::confess("please give the exchange name") if !$exchange;

    $mq->exchange_delete($exchange, %{$opt->{options}});
}


sub publish (@_) {
    my ($mq, $opt) = @_;
   
    $mq->exchange_name($opt->{exchange}) if $opt->{exchange};

    $mq->queue_declare($opt->{queue}, %{$opt->{queue_options}});
    $mq->queue_bind($opt->{route});

    map { $mq->$_($opt->{$_}) if defined($opt->{$_}) }
        qw/mandatory immediate/;
    
    # ACKs
    $mq->purge($mq->queue_name) if defined($opt->{ack}) and $opt->{ack} == 1;

    $mq->publish($opt->{message}, %{$opt->{options}});
}

sub consume (@_) {
    my ($mq, $opt) = @_;
   
    $mq->exchange_name($opt->{exchange}) if defined($opt->{exchange});
    $mq->queue_declare($opt->{queue}) if defined($opt->{queue});
    
    $mq->no_ack(0) if defined($opt->{ack}) and $opt->{ack} == 1;

    $mq->consume($opt->{options} || ());
    $mq->recv();
}

sub get (@_) {
    my ($mq, $opt) = @_;
   
    $mq->exchange_name($opt->{exchange}) if defined($opt->{exchange});
    $mq->queue_declare($opt->{queue}) if defined($opt->{queue});
    
    $mq->no_ack(0) if defined($opt->{ack}) and $opt->{ack} == 1;

    $mq->get($opt->{options} || ());
}


sub purge (@_) { shift->purge(@_) }
sub ack (@_) { shift->ack(@_) }
sub mqdisconnect(@_) { shift->disconnect(@_) }

sub import {
    my $class = shift;
    my $caller = caller;
    my $ctx = __PACKAGE__->new;

    my @cmds = ( 'mqconnect', 'publish', 'consume', 'purge', 'ack',
        'mqdisconnect', 'exchange', 'get', 'exchange_delete');

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

    return;
}

1;

__END__

=head1 NAME

Net::RabbitMQ::Simple - A simple syntax for Net::RabbitMQ

=head1 VERSION

This document describes NET::RabbitMQ::Simple version 0.0002

=head1 SYNOPSIS


    use Net::RabbitMQ::Simple;

    my $mq = mqconnect {
        hostname => 'localhost',
        user => 'guest',
        password => 'guest',
        vhost => '/'
    };

    exchange $mq, {
        exchange => 'mtest_x',
        type => 'direct',
        passive => 0,
        durable => 1,
        auto_delete => 0,
        exclusive => 0
    };

    publish $mq, {
        exchange => 'maketest',
        queue => 'mtest',
        route => 'mtest_route',
        message => 'message',
        options => { content_type => 'text/plain' }
    };

    consume $mq;
    my $rv = $mq->recv();
    
    # use Data::Dumper;
    # print Dumper($rv);

    mqdisconnect $mq;

=head1 DESCRIPTION

This package implements a simple syntax on top of L<Net::RabbitMQ>. With the
help of this package it is possible to write simple AMQP applications with a
few lines of perl code.

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


