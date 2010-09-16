package Net::RabbitMQ::Simple::Tx;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Method::Signatures;
use namespace::autoclean;

method tx () { $self->conn->tx_select($self->channel); }
method rollback() { $self->conn->tx_rollback($self->channel); }
method commit() { $self->conn->tx_commit($self->channel); }

__PACKAGE__->meta->make_immutable;

1;

