package Google::CloudTasks::Location;

use Mouse;
use Google::CloudTasks::Util qw/make_query_string/;
use Google::CloudTasks::Queue;

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

has locationId => (
    is => 'rw',
    isa => 'Str',
);

has displayName => (
    is => 'rw',
    isa => 'Str',
);

has labels => (
    is => 'rw',
    isa => 'HashRef',
);

has metadata => (
    is => 'rw',
    isa => 'HashRef',
);

no Mouse;

__PACKAGE__->meta->make_immutable;

sub new_from_hash {
    my ($self, $client, $hash) = @_;

    my $obj = __PACKAGE__->new(
        client => $client,
    );

    for (qw/name locationId displayName labels metadata/) {
        defined $hash->{$_} and $obj->$_($hash->{$_});
    }

    return $obj;
}

sub list_queues {
    my ($self, $args) = @_;

    my $path = $self->name . '/queues';
    $path .= make_query_string($args, qw/filter pageSize pageToken/);

    my $ret = $self->client->request_get($path);
    my @queues = [
        map { Google::CloudTasks::Queue->new_from_hash($self->client, $_) }
        @{$ret->{queues}}
    ];
    return {
        queues => \@queues,
        nextPageToken => $ret->{nextPageToken},
    };
}

1;
