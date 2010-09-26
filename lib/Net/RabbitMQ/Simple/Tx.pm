package Net::RabbitMQ::Simple::Tx;

use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

sub tx () { 
    my $self = shift;
    $self->conn->tx_select($self->channel); 
}

sub rollback() { 
    my $self = shift;
    $self->conn->tx_rollback($self->channel); 
}

sub commit() { 
    my $self = shift;
    $self->conn->tx_commit($self->channel); 
}

__PACKAGE__->meta->make_immutable;

1;

