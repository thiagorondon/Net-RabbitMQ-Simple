package Net::RabbitMQ::Simple;

use Moose;
use Net::RabbitMQ;
use Moose::Util::TypeConstraints;
use MooseX::Method::Signatures;

use namespace::autoclean;

# conn object.
has conn => (is => 'rw', isa => 'Object');

# connect options.
has hostname => (
    is => 'rw', 
    isa => 'Str', 
    default => '127.0.0.1',
);

has username => (is => 'rw', isa => 'Str', default => 'guest');
has password => (is => 'rw', isa => 'Str', default => 'guest');
has vhost => (is => 'rw', isa => 'Str', default => '/');
has channel_max => (is => 'rw', isa => 'Int', default => 0);
has frame_max => (is => 'rw', isa =>  'Int', default => 131072);
has heartbeat => (is => 'rw', isa => 'Int', default => 0);

# validates from rabbitfoot
sub _validate_vhost {
    my ($self) = @_;
    die 'vhost', "\n" if 255 < length($self->vhost)
        || $self->vhost !~ m{^[a-zA-Z0-9/\-_]+$};
}

sub _check_shortstr {
    my ($self, $arg) = @_;

    die $arg, "\n" if 255 < length($self->$arg)
        || $self->$arg !~ m{^[a-zA-Z0-9-_.:]+$};
}

sub _validate_routing_key {
    my ($self,) = @_;

    return if !$self->routing_key;
    die 'routing_key', "\n" if 255 < length($self->routing_key);
    return;
}

# connect 
method connect {
    my $mq = Net::RabbitMQ->new();
    $self->_validate_vhost;
    $mq->connect($self->hostname,
        {
        user => $self->username,
        password => $self->password,
        vhost => $self->vhost,
        channel_max => $self->channel_max,
        frame_max => $self->frame_max,
        hearbeat => $self->heartbeat
        });
    $self->conn($mq) ? 0 : 1;
}

# channel options
has channel => (is => 'rw', isa => 'Int', default => 1);

after channel => sub {
    my ($self, $argv) = @_;
    $self->conn->channel_open($argv) if $argv;
};

# exchange options
enum 'Exchange' => qw/direct topic/;
has exchange_type => (is => 'rw', isa => 'Exchange', default => 'direct');
has exchange_name => (is => 'rw', isa => 'Str');
has passive => (is => 'rw', isa => 'Bool', default => 0);
has durable => (is => 'rw', isa => 'Bool', default => 1);
has auto_delete => (is => 'rw', isa => 'Bool', default => 1);

after exchange_name => sub {
    my ($self, $argv) = @_;
    $self->_check_shortstr('exchange_name') if $argv;
};

method exchange_declare (Str $exchange_name) {
    $self->exchange_name($exchange_name);
    $self->conn->exchange_declare(
        $self->channel, $self->exchange_name, 
            {
                exchange_type => $self->exchange_type,
                passive => $self->passive,
                durable => $self->durable,
                auto_delete => $self->auto_delete
            }
        );
}

# queue
has 'queue_name' => (is => 'rw', isa => 'Str');
has 'routing_key' => (is => 'rw', isa => 'Str', default => '#');

after 'routing_key' => sub {
    my ($self, $argv) = shift;
    $self->_validate_routing_key if $argv;
};

method queue_declare (Str $queue_name = '') {
    $self->queue_name($queue_name);
    $self->conn->queue_declare($self->channel, $queue_name,
            {
                exchange_type => $self->exchange_type,
                passive => $self->passive,
                durable => $self->durable,
                auto_delete => $self->auto_delete
            }
        );
}

method queue_bind (Str $routing_key = '#') {
    $routing_key ||= $self->routing_key;
    $self->routing_key($routing_key);
    $self->conn->queue_bind($self->channel, $self->queue_name,
        $self->exchange_name, $routing_key);
}

method queue_unbind (Str $routing_key = '#') {
    $self->conn->queue_bind($self->channel, $self->queue_name,
        $routing_key);
}



# publish
has 'body' => (is => 'rw', isa => 'Str');
has 'mandatory' => (is => 'rw', isa => 'Bool', default => 0);
has 'immediate' => (is => 'rw', isa => 'Bool', default => 0);

method publish ($body) {
    
    $self->conn->publish($self->channel, $self->routing_key, $body,
        {
            exchange => $self->exchange_name,
            mandatory => $self->mandatory,
            immediate => $self->immediate
        },
        # TODO
    );

}

#consume
has 'consumer_tag' => (is => 'rw', isa => 'Str', default => 'absent');
has 'no_local' => (is => 'rw', isa => 'Bool', default => 0);
has 'no_ack' => (is => 'rw', isa => 'Bool', default => 1);
has 'exclusive' => (is => 'rw', isa => 'Bool', default => 0);

method consume () {
    $self->conn->consume($self->channel, $self->queue_name);
}

method recv () {
    $self->conn->recv();
}

method disconnect() {
    $self->conn->disconnect();
}

1;

