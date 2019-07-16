package Google::CloudTasks::Util;

use strict;
use warnings;
use utf8;

our @ISA = qw(Exporter);

our $VERSION = "0.01";

our @EXPORT_OK = qw/make_query_string/;

sub make_query_string {
    my ($args, @keys) = @_;

    my $u = URI->new();
    for (@keys) {
        if (defined $args->{$_}) {
            $u->query_param($_ => $args->{$_});
        }
    }

    return $u->query ? '?' . $u->query : '';
}

1;
