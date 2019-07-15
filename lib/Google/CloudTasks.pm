package Google::CloudTasks;
use 5.008001;
use strict;
use warnings;
use utf8;

our $VERSION = "0.01";

use Mouse;
use WWW::Google::Cloud::Auth::ServiceAccount;
use LWP::UserAgent;
use HTTP::Request;
use URI;
use URI::QueryParam;
use JSON::XS;

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
    }
    use Data::Dumper;
    print Dumper($req);
    my $res = $self->ua->request($req);

    if ($res->is_success) {
        return decode_json($res->content);
    }
    else {
        die "Fail: " . $res->content;
    }
}

sub request_get {
    my ($self, $path, $param) = @_;

    if ($param) {
        $path .= '?' . $param;
    }

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

    return $u->query;
}

sub create_queue {
    my ($self, $args, $queue) = @_;
    my $path = $args->{parent} . '/queues';

    return $self->request_post($path, $queue);
}

sub delete_queue {
    my ($self, $args) = @_;
    my $path = $args->{name};

    return $self->request_delete($path);
}

sub get_iam_policy {
    my ($self, $args) = @_;
    my $path = $args->{resource} . ':getIamPolicy';

    return $self->request_post($path);
}

sub list_queues {
    my ($self, $args) = @_;
    my $path = $args->{parent};
    my $query = _make_query_param($args, qw/filter pageSize pageToken/);

    return $self->request_get($path, $query);
}

sub get_queue {
    my ($self, $args) = @_;
    my $path = $args->{name};

    return $self->request_get($path);
}

1;
__END__

=encoding utf-8

=head1 NAME

Google::CloudTasks - Google CloudTasks API library for Perl

=head1 SYNOPSIS

    use Google::CloudTasks;

=head1 DESCRIPTION

Google::CloudTasks is ...

=head1 LICENSE

Copyright (C) egawata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

egawata E<lt>egawa.takashi@gmail.comE<gt>

=cut

