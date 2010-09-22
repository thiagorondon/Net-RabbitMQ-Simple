package Net::RabbitMQ::Simple::Exchange;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Method::Signatures;
use namespace::autoclean;

enum 'Exchange' => qw/direct topic fanout headers/;

has exchange_type => (
    is => 'rw', 
    isa => 'Exchange', 
    default => 'direct'
);

has exchange_name => (
    is => 'rw', 
    isa => 'Str'
);

after exchange_name => sub {
    my ($self, $argv) = @_;
    $self->_check_shortstr('exchange_name') if $argv;
};

method exchange_declare (Str $exchange_name, %props) {
    $self->exchange_name($exchange_name);
    
    $props{type} = $self->exchange_type if !defined($props{type})
        or $self->exchange_type($props{type});

    $props{exchange_type} = $props{type};
    delete $props{type};

    $self->conn->exchange_declare(
        $self->channel, $self->exchange_name, { %props } );
}

method exchange_delete ($exchange, %props) {
    $self->conn->exchange_delete($self->channel, $exchange, { %props });
}

__PACKAGE__->meta->make_immutable;

1;

