use strict;
use warnings;
package Dancer::Plugin::StatsD;
use Dancer;
use Dancer::Plugin;
use Etsy::StatsD;

# ABSTRACT: Dancer Plugin for StatsD support

my $statsd;

# Create statsd object, or return existing one
sub statsd_obj {
    # Return it if we got it
    return $statsd if $statsd;

    my $config = plugin_setting;
    my $host = $config->{host};
    my $port = $config->{port};
    my $sample_rate = $config->{sample_rate} // 1;

    die "No StatsD Host/Port found!" unless $host && $port;

    return $statsd = Etsy::StatsD->new( $host, $port, $sample_rate );
}

register statsd    => sub { statsd_obj };

register_plugin;

1;

=head1 SYNOPSIS

L<Dancer::Plugin::StatsD> is a L<Dancer> plugin that lets you log events and
track times using C<StatsD>.

    use Dancer;
    use Dancer::Plugin::StatsD qw( statsd increment decrement update timing );
    use Time::HiRes qw( time );

    hook before_error_renden => sub {
        my ($err) = @_;
        statsd->increment( 'errors.' . $err->code );
    };

    get '/' => sub {
        # Increment the homepage hits counter
        statsd->increment( 'hits.homepage' );

        my $t1 = time;

        # Do something that takes a while

        # Log the time taken in ms
        statsd->timing( 'something.slow', (time - $t1) / 1000 );
    };

    dance;
