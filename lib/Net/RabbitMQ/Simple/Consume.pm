package Net::RabbitMQ::Simple::Consume;

use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

# consume and get.
has 'consumer_tag' => (is => 'rw', isa => 'Str', default => 'absent');
has 'no_local' => (is => 'rw', isa => 'Bool', default => 0);
has 'no_ack' => (is => 'rw', isa => 'Bool', default => 1);
has 'exclusive' => (is => 'rw', isa => 'Bool', default => 0);

sub consume {
    my $self = shift;
    my %props = @_;
    # for ack option
    $props{no_ack} = $self->no_ack if !defined($props{no_ack});
    # todo: check if the channel is open.
    $self->conn->consume($self->channel, $self->queue_name, { %props });
}

sub get {
    my $self = shift;
    my %props = @_;
    # for ack option
    $props{no_ack} = $self->no_ack if !defined($props{no_ack});
    # todo: check if the channel is open.
    $self->conn->get($self->channel, $self->queue_name, { %props });
}


sub recv () { shift->conn->recv() }

__PACKAGE__->meta->make_immutable;

1;

