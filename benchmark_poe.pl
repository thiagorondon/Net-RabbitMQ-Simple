
use Benchmark qw(:all);

use FindBin qw($Bin);
use lib "$Bin/lib";

use POE qw(Wheel::Run Filter::Reference);
use Net::RabbitMQ::Simple;

sub MAX_CONCURRENT_TASKS () { 50 }
sub NUM_TASKS () { 100 }
our $task_counter = 0;

POE::Session->create(
    inline_states => {
        _start  =>  \&start_tasks,
        next_task   => \&start_tasks,
        task_result => \&handle_task_result,
        task_done   => \&handle_task_done,
        sig_child   => \&sig_child,
    }
);

sub start_tasks {
    my ($kernel, $heap) = @_[KERNEL, HEAP];
    while (keys(%{$heap->{task}}) < MAX_CONCURRENT_TASKS) {
        last if $task_counter == NUM_TASKS;
        $task_counter++;
        my $task = POE::Wheel::Run->new(
            Program => sub {
                task_consume($next_task) },
                StdoutFilter    => POE::Filter::Reference->new(),
                StdoutEvent     => "task_result",
                StderrEvent     => "task_debug",
                CloseEvent      => "task_done",
            );

        $heap->{task}->{$task->ID} = $task;
        $kernel->sig_child($task->PID, "sig_child");
    }
}

sub task_consume {
    my $task = shift;
    my $filter = POE::Filter::Reference->new();

    mqconnect; # share ?

    publish {
        exchange => 'triagem',
        queue => 'triagem',
        route => 'triagem_rota',
        message => 'foobar' . $task,
    };

    mqdisconnect;

    my %result = (
        task => $task,
        rv => $rv
    );

    my $output = $filter->put([\%result]);
}

sub handle_task_result {
    my $result = $_[ARG0];
}

sub handle_task_done {
    my ($kernel, $heap, $task_id) = @_[KERNEL, HEAP, ARG0];
    delete $heap->{task}->{$task_id};
    $kernel->yield("next_task");
}

sub sig_child {
    my ($heap, $sig, $pid, $exit_val) = @_[HEAP, ARG0, ARG1, ARG2];
    my $details = delete $heap->{$pid};
    warn "$$: Child $pid exited";
}

$poe_kernel->run();
exit 0;



