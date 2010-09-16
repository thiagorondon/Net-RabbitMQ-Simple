package Net::RabbitMQ::Simple::Wrapper;

use Moose;

extends qw/
    Net::RabbitMQ::Simple::Exchange
    Net::RabbitMQ::Simple::Queue
    Net::RabbitMQ::Simple::Publish
    Net::RabbitMQ::Simple::Consume
    Net::RabbitMQ::Simple::Tx
    /;

use Net::RabbitMQ;
use Moose::Util::TypeConstraints;
use MooseX::Method::Signatures;
use Carp qw/ confess /;

has conn => (
    is => 'rw', 
    isa => 'Object'
);

has hostname => (
    is => 'rw', 
    isa => 'Str', 
    default => 'localhost',
);

has user => (
    is => 'rw', 
    isa => 'Str', 
    default => 'guest'
);

has password => (
    is => 'rw', 
    isa => 'Str', 
    default => 'guest'
);

has vhost => (
    is => 'rw', 
    isa => 'Str', 
    default => '/'
);

has channel_max => (
    is => 'rw', 
    isa => 'Int', 
    default => 0
);

has frame_max => (
    is => 'rw', 
    isa =>  'Int', 
    default => 131072
);

has heartbeat => (
    is => 'rw', 
    isa => 'Int', 
    default => 0
);

has channel => (
    is => 'rw', 
    isa => 'Int', 
    default => 1
);

after channel => sub {
    my ($self, $argv) = @_;
    $self->conn->channel_open($argv) if $argv;
};


method _validate_vhost {
    Carp::confess("vhost has length > 255") if 255 < length($self->vhost)
        || $self->vhost !~ m{^[a-zA-Z0-9/\-_]+$};
}

method _check_shortstr ($arg) {
    Carp::confess($self->arg . "has length > 255") if 255 < length($self->$arg)
        || $self->$arg !~ m{^[a-zA-Z0-9-_.:]+$};
}

method _validate_routing_key {
    return if !$self->routing_key;
    Carp::confess('routing_key has length > 255') 
        if 255 < length($self->routing_key);
}

# connect 
method connect {
    my $mq = Net::RabbitMQ->new();
    $self->_validate_vhost;
    $mq->connect($self->hostname,
        {
        user => $self->user,
        password => $self->password,
        vhost => $self->vhost,
        channel_max => $self->channel_max,
        frame_max => $self->frame_max,
        hearbeat => $self->heartbeat
        });
    $self->conn($mq) ? 0 : 1;
}

method disconnect { $self->conn->disconnect(); }

for my $item (qw/purge ack/) {
    method "$item" ($tag) {
        $self->conn->$item($self->channel, $tag);
    }
}

1;

