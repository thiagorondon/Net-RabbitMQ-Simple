#!/usr/bin/env perl
#
# Aware TI, 2010, http://www.aware.com.br
# Thiago Rondon <thiago@aware.com.br>
#

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/lib";

use Net::RabbitMQ::Simple;
use Data::Dumper;
use POE qw(Wheel::Run Filter::Reference);

sub MAX_CONCURRENT_TASKS () { 3 }
our $task_counter = 0;

POE::Session->create(
    inline_states => {
        _start      => \&start_tasks,
        next_task   => \&start_tasks,
        task_result => \&handle_task_result,
        task_done   => \&handle_task_done,
        sig_child   => \&sig_child,
    }
);

sub start_tasks {
    my ($kernel, $heap) = @_[KERNEL, HEAP];
    while (keys(%{$heap->{task}}) < MAX_CONCURRENT_TASKS) {
        $task_counter++;
        my $next_task = $task_counter;
        print "Starting consume for $next_task ... \n";
        my $task = POE::Wheel::Run->new(
            Program      => sub {
                consume($next_task) },
                StdoutFilter => POE::Filter::Reference->new(),
                StdoutEvent  => "task_result",
                StderrEvent  => "task_debug",
                CloseEvent   => "task_done",
        );

        $heap->{task}->{$task->ID} = $task;
        $kernel->sig_child($task->PID, "sig_child");
    }
}

# TODO: make conn persistent ?
sub consume {
    my $task   = shift;
    my $filter = POE::Filter::Reference->new();

    my $amqp = Net::RabbitMQ::Simple->new();
    $amqp->connect;
    $amqp->channel(1);
    $amqp->exchange_name("foobar");
    $amqp->queue_declare('baz');
    $amqp->consume(); 
    my $rv = $amqp->recv(); 
    $amqp->disconnect();
    
    my %result = (
        task   => $task,
        rv => $rv
    );
    
    my $output = $filter->put([\%result]);
    print @$output;
}

sub handle_task_result {
    my $result = $_[ARG0];
    print "Get one:\n";
    print Dumper($result);

}

sub handle_task_done {
    my ($kernel, $heap, $task_id) = @_[KERNEL, HEAP, ARG0];
    delete $heap->{task}->{$task_id};
    $kernel->yield("next_task");
    print "Done\n";
}


sub sig_child {
    my ($heap, $sig, $pid, $exit_val) = @_[HEAP, ARG0, ARG1, ARG2];
    my $details = delete $heap->{$pid};

#    warn "$$: Child $pid exited";
}

# Run until there are no more tasks.
$poe_kernel->run();
exit 0;


