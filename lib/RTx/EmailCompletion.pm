package RTx::EmailCompletion;

use strict;

our $VERSION = "0.01";

1;

__END__

=head1 NAME

RTx::EmailCompletion - Auto completion for email field

=head1 VERSION

This document describes version 0.01 of RTx::EmailCompletion

=head1 DESCRIPTION

I'm so tired to type email address by hand that I've done this module
try Add ajax autocompletion on email field

There's 3 S<things :>

=over

=item *

a small web service C<html/Ajax/Email> which search in all known users
in the database

=item *

the scriptaculous library to autocomplete

=item *

and modified html RT pages to use those two first component

=back

As I've embedded some pages of RT, it should work only for release
3.6.3. But I keep the patches of all modified files in C<patches/> so
you can try to use them against other release.

=head1 INSTALLATION

Install it like a standard perl module

 perl Makefile.PL
 make
 make install


=head1 AUTHORS

Nicolas Chuche E<lt>nchuche@barna.beE<gt>

=head1 COPYRIGHT

Copyright 2007 by Nicolas Chuche E<lt>nchuche@barna.beE<gt>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

All Scriptaculous and Prototype program are placed under MIT licence
and are copyrighted by their owners (see top of files).

=cut
