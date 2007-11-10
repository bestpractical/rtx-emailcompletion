package RTx::EmailCompletion;

use strict;
use RT::Users;

our $VERSION = "0.03";

sub search_rdbms {
    my $Email = shift;
    my $CurrentUser = shift;

    my @emails;

    my $Users = RT::Users->new( $CurrentUser );
    foreach my $field (@{$RT::EmailCompletionSearchFields}) {
	$Users->Limit(SUBCLAUSE => 'EmailCompletion', ALIAS => 'main', FIELD => $field, OPERATOR => $RT::EmailCompletionSearch, VALUE => $Email, ENTRYAGGREGATOR => 'OR');
    }

    $RT::Logger->debug($Users->BuildSelectQuery);

    while (my $User = $Users->Next()) {
	next if $User->id == $RT::Nobody->id;

	# some cleaning on emailaddress
	next if $User->EmailAddress !~ m{[a-zA-Z0-9_.-]+@[^.]+\.[^.]};
	next if $User->EmailAddress =~ m{[,?!/;\\]};

	# if you're privileged user you can see anybody
	#
	# if you're not by default you can see nobody
	# if RT::EmailCompletionUnprivileged is set to anybody you can see anybody
	# else you can see only privileged users

	if ( $CurrentUser->Privileged() or $RT::EmailCompletionUnprivileged eq 'everybody' ) {
	    # Ok, show everybody
	} elsif ( $RT::EmailCompletionUnprivileged eq 'privileged' ) {
	    next unless $User->Privileged();
	} elsif ( ref($RT::EmailCompletionUnprivileged) eq 'Regexp' ) {
	    next unless $User->EmailAddress =~ m/$RT::EmailCompletionUnprivileged/;
	} else {
	    next
	}

	push @emails, $User->EmailAddress;
    }
    @emails;
}

1;

__END__

=head1 NAME

RTx::EmailCompletion - Add auto completion on RT email fields

=head1 VERSION

This document describes version 0.03 of RTx::EmailCompletion.

=head1 DESCRIPTION

I'm so tired to type email address by hand that I've done this module
to add AJAX autocompletion on all email field of RT. As adding
completion is dynamic, it should work on most RT releases (see later
if it's not the case).

There's 3 S<things :>

=over

=item *

a small web service C<html/Ajax/EmailCompletion> which search in all
known users in the S<database ;>

=item *

prototype library to manipulate DOM and scriptaculous library to
S<autocomplete ;>

=item *

a small javascript which parse html pages and add autocomplete on
known input tags.

=back

=head1 INSTALLATION

if upgrading from 0.01, see later UPGRADE FROM 0.01.

Install it like a standard perl module :

 RTHOME=/opt/rt3 perl Makefile.PL
 make
 make install

=head1 CONFIGURATION

By default, completion works only for privileged users.

You can activate it for unprivileged users (in the SelfService) by
setting $EmailCompletionUnprivileged in
F<RTHOME/etc/RT_SiteConfig.pm>. There's three ways :

=over

=item *
show everybody

  Set($EmailCompletionUnprivileged,"everybody");

=item *
show only privileged users

  Set($EmailCompletionUnprivileged,"privileged");

=item *
show only email matching a regexp

  Set($EmailCompletionUnprivileged, qr/\@my\.corp\.domain$/ );

=back

You can also change the operator used in the C<where> clause to search
email with the global var $RT::EmailCompletionSearch. The default one
is C<LIKE>.

To change it, add a line like this in F<RTHOME/etc/RT_SiteConfig.pm> :

 Set($EmailCompletionSearch, "STARTSWITH");

This variable can take the values C<LIKE>, C<STARTSWITH> and
C<ENDSWITH>.

By default, the plugin searches on Users.EmailAddress.

You can change where it searches by setting $EmailCompletionSearchFields
in RTHOME/etc/RT_SiteConfig.pm to an arrayref of fields from the
Users table.

   Set( $EmailCompletionSearchFields, [qw(EmailAddress RealName Name)] );

This would allow you to search by usernames, full names and email addresses

=head1 HOW TO ADD FIELD TO AUTOCOMPLETION

If you find email field without autocomplete, you can modify
C<html/NoAuth/js/emailcompletion.js> to handle this field (and email
me to patch this module).

At the beginning of this file you will find two global vars
C<multipleCompletion> and C<singleCompletion>. They are array of
regexp.

Regexp must match all the word because C<^> and C<$> are added for
matching. So if you want to match C<Field1> and C<Field2> you must add
something like C<Field.> or better C<Field[12]>.

To verify javascript find your input tag, you can uncomment the line
just after the "DEBUGGING PURPOSE" one. All input tags find by the
script will appear with a big red border.

=head1 UPGRADE FROM 0.01

As directory structure has change, If you upgrade from 0.01, you must
delete :

  RTHOME/local/html/Ajax/EmailCompletion
  RTHOME/local/html/NoAuth/js/emailcompletion.js
  RTHOME/local/html/NoAuth/js/

Be careful of you have other javascripts in RTHOME/local/html/NoAuth/js/

=head1 HISTORY

The first version (unreleased) modify html pages. The better method
actually used allow this module to be compatible with, virtually, all
RT release.

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
