package Net::RabbitMQ::Simple::Publish;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Method::Signatures;
use namespace::autoclean;

has 'body' => (
    is => 'rw', 
    isa => 'Str'
);

has 'mandatory' => (
    is => 'rw', 
    isa => 'Bool', 
    default => 0
);

has 'immediate' => (
    is => 'rw', 
    isa => 'Bool', 
    default => 0
);

method publish ($body, %props) {
    
    $self->conn->publish($self->channel, $self->routing_key, $body,
        {
            exchange => $self->exchange_name,
            mandatory => $self->mandatory,
            immediate => $self->immediate,
        },
        {
            %props
        }
    );

}

__PACKAGE__->meta->make_immutable;
1;

