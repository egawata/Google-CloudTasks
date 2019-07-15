package Google::CloudTasks;
use 5.008001;
use strict;
use warnings;
use utf8;

use Google::CloudTasks::Client;

our $VERSION = "0.01";

sub new {
    my ($class, @args) = @_;

    return Google::CloudTasks::Client->new(@args);
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

