package Google::CloudTasks;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Mouse;
use WWW::Google::Cloud::Auth::ServiceAccount;
use LWP::UserAgent;
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

sub request_get {
    my ($self, $path, $param) = @_;

    if ($param) {
        $path .= '?' . $param;
    }

    my $res = $self->ua->get(
        $self->base_url . $self->version . '/' . $path,
        'Content-Type' => 'application/json; charset=utf8',
        'Authorization' => 'Bearer ' . $self->auth->get_token,
    );

    if ($res->is_success) {
        return decode_json($res->content);
    }
    else {
        die "Failed to call API : " . $res->content;
    }
}

sub request_post {
    my ($self, $path, $body) = @_;

    my $res = $self->ua->post(
        $self->base_url . $self->version . '/' . $path,
        'Content-Type' => 'application/json; charset=utf8',
        'Authorization' => 'Bearer ' . $self->auth->get_token,
        $body ? (Content => encode_json($body)) : (),
    );

    if ($res->is_success) {
        return decode_json($res->content);
    }
    else {
        die "Failed to call API : " . $res->content;
    }
}

sub request_delete {
    my ($self, $path) = @_;

    my $res = $self->ua->delete(
        $self->base_url . $self->version . '/' . $path,
        'Content-Type' => 'application/json; charset=utf8',
        'Authorization' => 'Bearer ' . $self->auth->get_token,
    );

    if ($res->is_success) {
        return decode_json($res->content);
    }
    else {
        die "Failed to call API : " . $res->content;
    }
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

