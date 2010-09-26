
use Test::More tests => 3;
use Test::LeakTrace;

use Net::RabbitMQ::Simple;

my $host = $ENV{'MQHOST'};

SKIP: {
    skip 'No $ENV{\'MQHOST\'}\n', 3 unless $host;

    leaks_cmp_ok { mqconnect; } '<', 7;
    no_leaks_ok { publish {
                exchange => 'mtest_x',
                queue => 'leak',
                route => 'leak_rota',
                message => 'message leak',
                };
        } 'no memory leaks'; 

    leaks_cmp_ok {
            my $rv = {};
            $rv = get { queue => 'leak', ack => 1 };
            ack $rv->{delivery_tag} if defined($rv);
        } '<', 10;

    mqdisconnect;
}

1;


