package Google::CloudTasks::Queue;

our $VERSION = "0.01";

use Mouse;

has client => (
    is => 'ro',
    isa => 'Google::CloudTasks::Client',
    required => 1,
    weak_ref => 1,
);

has name => (
    is => 'rw',
    isa => 'Str',
);

has rateLimits => (
    is => 'rw',
    isa => 'Google::CloudTasks::RateLimits',
);

has retryConfig => (
    is => 'rw',
    isa => 'Google::CloudTasks::RetryConfig',
);

has state => (
    is => 'rw',
    isa => 'Str',
);

has purgeTime => (
    is => 'rw',
    isa => 'Str',
);

has appEngineRouting => (
    is => 'rw',
    isa => 'Google::CloudTasks::AppEngineRouting',
);

no Mouse;

__PACKAGE__->meta->make_immutable;

sub new_from_hash {
    my ($class, $client, $hash) = @_;

    my $obj = __PACKAGE__->new(
        client => $client,
    );

    for (qw/name state purgeTime/) {
        if (defined $hash->{$_}) {
            $obj->$_($hash->{$_});
        }
    }

    if ($hash->{rateLimits}) {
        $obj->rateLimits(Google::CloudTasks::RateLimits->new($hash->{rateLimits}));
    }
    if ($hash->{retryConfig}) {
        $obj->retryConfig(Google::CloudTasks::RetryConfig->new($hash->{retryConfig}));
    }

    return $obj;
}

sub delete {
    my ($self) = @_;

    return $self->client->request_delete($self->name);
}

package Google::CloudTasks::RateLimits;

use Mouse;

has maxDispatchesPerSecond => (is => 'rw', isa => 'Num');
has maxBurstSize => (is => 'rw', isa => 'Num');
has maxConcurrentDispatches => (is => 'rw', isa => 'Num');

no Mouse;

__PACKAGE__->meta->make_immutable;

package Google::CloudTasks::RetryConfig;

use Mouse;

has maxAttempts => (is => 'rw', isa => 'Num');
has maxRetryDuration => (is => 'rw', isa => 'Str');
has minBackoff => (is => 'rw', isa => 'Str');
has maxBackoff => (is => 'rw', isa => 'Str');
has maxDoublings => (is => 'rw', isa => 'Num');

no Mouse;

__PACKAGE__->meta->make_immutable;

package Google::CloudTasks::AppEngineRouting;

use Mouse;

has service => (is => 'rw', isa => 'Str');
has version => (is => 'rw', isa => 'Str');
has instance => (is => 'rw', isa => 'Str');
has host => (is => 'rw', isa => 'Str');

no Mouse;

__PACKAGE__->meta->make_immutable;

1;
