package Net::RabbitMQ::Simple::Queue;

use Moose;

use Moose::Util::TypeConstraints;
use MooseX::Method::Signatures;

# queue
has 'queue_name' => (
    is => 'rw', 
    isa => 'Str'
);

has 'routing_key' => (
    is => 'rw', 
    isa => 'Str', 
    default => '#'
);

after 'routing_key' => sub {
    my ($self, $argv) = shift;
    $self->_validate_routing_key if $argv;
};

method queue_declare (Str $queue_name = '', %props) {
    $self->queue_name($queue_name);
    $self->conn->queue_declare($self->channel, $queue_name, { %props });
}

method queue_bind (Str $routing_key = '#') {
    $routing_key ||= $self->routing_key;
    $self->routing_key($routing_key);
    $self->conn->queue_bind($self->channel, $self->queue_name,
        $self->exchange_name, $routing_key);
}

method queue_unbind (Str $routing_key = '#') {
    $self->conn->queue_unbind($self->channel, $self->queue_name,
                $self->exchange_name, $routing_key);
}

1;

