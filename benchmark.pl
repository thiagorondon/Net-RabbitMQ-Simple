
use Benchmark qw(:all);

use FindBin qw($Bin);
use lib "$Bin/lib";

use Net::RabbitMQ::Simple;

mqconnect;

my $count = 100;
print "start publish...\n";
my $t = timeit ($count,  
    sub {
        my $f = $count;
        while($f) {
            publish {
                exchange => 'triagem',
                queue => 'triagem',
                route => 'triagem_rota',
                message => 'foobar',
            };
            $f--;
        }
    }
);

print "$count (publish) ", timestr($t), "\n";

print "start get..\n";

my $t = timeit ($count,  
    sub {
        my $f = $count;
        while($f) {
            my $rv = {};
            $rv = get { queue => 'triagem', ack => 1 };
            ack $rv->{delivery_tag} if defined($rv);
            $f--;
        }
    }
);

print "$count (get) ", timestr($t), "\n";


mqdisconnect;

