package Net::RabbitMQ::Simple::Queue;

use Moose;

use Moose::Util::TypeConstraints;
use namespace::autoclean;

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

sub queue_declare {
    my $self = shift;
    my $queue_name = shift || '';
    my %props = @_;

    $self->queue_name($queue_name);
    $self->conn->queue_declare($self->channel, $queue_name, { %props });
}

sub queue_bind {
    my $self = shift;
    my $routing_key = shift || '#';
    
    $routing_key ||= $self->routing_key;
    $self->routing_key($routing_key);
    $self->conn->queue_bind($self->channel, $self->queue_name,
        $self->exchange_name, $routing_key);
}

sub queue_unbind {
    my $self = shift;
    my $routing_key = shift || '#';
    $self->conn->queue_unbind($self->channel, $self->queue_name,
                $self->exchange_name, $routing_key);
}

__PACKAGE__->meta->make_immutable;

1;

