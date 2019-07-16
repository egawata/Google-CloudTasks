package Google::CloudTasks::Client;

use Mouse;
use WWW::Google::Cloud::Auth::ServiceAccount;
use LWP::UserAgent;
use HTTP::Request;
use URI;
use URI::QueryParam;
use JSON::XS;
use Google::CloudTasks::Location;
use Google::CloudTasks::Queue;

our $VERSION = "0.01";

has base_url => (
    is => 'ro',
    isa => 'Str',
    default => 'https://cloudtasks.googleapis.com/',
);

has version => (
    is => 'ro',
    isa => 'Str',
    default => 'v2',
);

has credentials_path => (
    is => 'ro',
    isa => 'Str'
);

has auth => (
    is => 'ro',
    lazy_build => 1,
);

has ua => (
    is => 'ro',
    lazy => 1,
    default => sub { LWP::UserAgent->new() },
);

no Mouse;

__PACKAGE__->meta->make_immutable;

sub _build_auth {
    my ($self) = @_;

    if (!$self->credentials_path) {
        die "attribute 'credentials_path' is required";
    }
    my $auth = WWW::Google::Cloud::Auth::ServiceAccount->new(
        credentials_path => $self->credentials_path,
    );
    return $auth;
}

sub request {
    my ($self, $method, $path, $content) = @_;

    my $url = $self->base_url . $self->version . '/' . $path;
    my $req = HTTP::Request->new($method, $url);
    $req->header('Content-Type' => 'application/json; charset=utf8');
    $req->header('Authorization' => 'Bearer ' . $self->auth->get_token);
    if ($content) {
        my $encoded_body = encode_json($content);
        $req->header('Content-Length' => length($encoded_body));
        $req->content($encoded_body);
        print "Content = [$encoded_body]\n";
    }
    my $res = $self->ua->request($req);

    if ($res->is_success) {
        return decode_json($res->content);
    }
    else {
        die "Fail: " . $res->content;
    }
}

sub request_get {
    my ($self, $path) = @_;
    return $self->request(GET => $path);
}

sub request_post {
    my ($self, $path, $content) = @_;
    $content //= {};
    return $self->request(POST => $path, $content);
}

sub request_delete {
    my ($self, $path) = @_;
    return $self->request(DELETE => $path);
}

sub request_patch {
    my ($self, $path) = @_;
    return $self->request(PATCH => $path);
}

sub _make_query_param {
    my ($args, @keys) = @_;

    my $u = URI->new();
    for (@keys) {
        if (defined $args->{$_}) {
            $u->query_param($_ => $args->{$_});
        }
    }

    return $u->query ? '?' . $u->query : '';
}

sub get_location {
    my ($self, $args) = @_;
    my $path = $args->{name};
    my $ret = $self->request_get($path);
    my $location = Google::CloudTasks::Location->new_from_hash($self, $ret);
    return $location;
}

sub list_locations {
    my ($self, $args) = @_;
    my $path = $args->{name} . '/locations';
    $path .= _make_query_param($args, qw/filter pageSize pageToken/);

    return $self->request_get($path);
}

sub create_queue {
    my ($self, $args) = @_;
    my $path = $args->{parent} . '/queues';

    my $ret = $self->request_post($path, $args->{queue});
    return Google::CloudTasks::Queue->new_from_hash($self, $ret);
}

sub delete_queue {
    my ($self, $args) = @_;
    my $queue = Google::CloudTasks::Queue->new(
        client => $self,
        name => $args->{name},
    );

    return $queue->delete();
}

sub get_iam_policy {
    my ($self, $args) = @_;
    my $path = $args->{resource} . ':getIamPolicy';

    return $self->request_post($path);
}

sub set_iam_policy {
    my ($self, $args) = @_;
    my $path = $args->{resource} . ':setIamPolicy';

    my %opts = ();
    if ($args->{policy}) {
        $opts{policy} = $args->{policy};
    }
    return $self->request_post($path, \%opts);
}

sub list_queues {
    my ($self, $args) = @_;
    my $path = $args->{parent};
    $path .= _make_query_param($args, qw/filter pageSize pageToken/);

    my $ret = $self->request_get($path);
    my @queues = [
        map { Google::CloudTasks::Queue->new_from_hash($self, $_) }
        @{$ret->{queues}}
    ];
    return {
        queues => \@queues,
        nextPageToken => $ret->{nextPageToken},
    };
}

sub get_queue {
    my ($self, $args) = @_;
    my $path = $args->{name};

    my $ret = $self->request_get($path);
    return Google::CloudTasks::Queue->new_from_hash($self, $ret);
}

sub patch_queue {
    my ($self, $args) = @_;
    my $path = $args->{name};
    $path .= _make_query_param($args, qw/updateMask/);

    my %opts = ();
    if ($args->{queue}) {
        $opts{queue} = $args->{queue};
    }

    return $self->request_patch($path, \%opts);
}

sub pause_queue {
    my ($self, $args) = @_;
    my $path = $args->{name} . ':pause';
    return $self->request_post($path);
}

sub purge_queue {
    my ($self, $args) = @_;
    my $path = $args->{name} . ':purge';
    return $self->request_post($path);
}

sub resume_queue {
    my ($self, $args) = @_;
    my $path = $args->{name} . ':resume';
    return $self->request_post($path);
}

sub test_iam_permissions {
    my ($self, $args, $permissions) = @_;
    my $path = $args->{resource} . ':testIamPermissions';
    my %opts = ();
    $args->{permissions} and $opts{permissions} = $args->{permissions};
    return $self->request_post($path, \%opts);
}

sub create_task {
    my ($self, $args) = @_;
    my $path = $args->{parent} . '/tasks';

    my %opts = ();
    for (qw/task responseView/) {
        defined $args->{$_} and $opts{$_} = $args->{$_};
    }

    return $self->request_post($path, \%opts);
}

sub delete_task {
    my ($self, $args) = @_;
    my $path = $args->{name};

    return $self->request_delete($path);
}

sub get_task {
    my ($self, $args) = @_;
    my $path = $args->{name};

    $path .= _make_query_param($args, qw/responseView/);

    return $self->request_get($path);
}

sub list_tasks {
    my ($self, $args) = @_;
    my $path = $args->{parent} . '/tasks';

    $path .= _make_query_param($args, qw/responseView pageSize pageToken/);

    return $self->request_get($path);
}

sub run_task {
    my ($self, $args) = @_;
    my $path = $args->{name} . ':run';

    my %opts = ();
    for (qw/responseView/) {
        defined $args->{$_} and $opts{$_} = $args->{$_};
    }

    return $self->request_post($path, \%opts);
}

1;
