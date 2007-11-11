#!/usr/bin/perl -w

use strict;
use lib qw(/opt/rt3/lib/);
use Benchmark qw/:all/;
use Data::Dumper;

use RT;
RT::LoadConfig();
RT::Init();



my $CurrentUser =  RT::User->new($RT::SystemUser);

$CurrentUser->LoadByEmail('Nicolas.Chuche@equipement.gouv.fr');
# $CurrentUser->LoadByEmail('Eric.Boyon@equipement.gouv.fr');

my $Users = RT::Users->new( $CurrentUser );

$RT::EmailCompletionNonPrivileged ||= '';
$RT::EmailCompletionSearchFields  ||= [qw(EmailAddress)];
$RT::EmailCompletionSearch        ||= 'LIKE';

#$RT::EmailCompletionUnprivileged = "privileged";

my $param = "ch";

print "Test pour NBC\n";
{
    $CurrentUser->LoadByEmail('Nicolas.Chuche@equipement.gouv.fr');
    timethese(10, {'Old' => sub { search_rdbms($param, $CurrentUser);  }, 'New' => sub { search_rdbms_new($param, $CurrentUser);  }, });
}

print "Test pour ERIC\n";
{
    $CurrentUser->LoadByEmail('Eric.Boyon@equipement.gouv.fr');
    timethese(10, {'Old' => sub { search_rdbms($param, $CurrentUser);  }, 'New' => sub { search_rdbms_new($param, $CurrentUser);  }, });
}

$RT::EmailCompletionUnprivileged = "privileged";

print "Test pour NBC privileged\n";
{
    $CurrentUser->LoadByEmail('Nicolas.Chuche@equipement.gouv.fr');
    timethese(10, {'Old' => sub { search_rdbms($param, $CurrentUser);  }, 'New' => sub { search_rdbms_new($param, $CurrentUser);  }, });
}

print "Test pour ERIC privileged\n";
{
    $CurrentUser->LoadByEmail('Eric.Boyon@equipement.gouv.fr');
    timethese(10, {'Old' => sub { search_rdbms($param, $CurrentUser);  }, 'New' => sub { search_rdbms_new($param, $CurrentUser);  }, });
}

$RT::EmailCompletionUnprivileged = qr/gouv.fr/i;

print "Test pour NBC regexp\n";
{
    $CurrentUser->LoadByEmail('Nicolas.Chuche@equipement.gouv.fr');
    timethese(10, {'Old' => sub { search_rdbms($param, $CurrentUser);  }, 'New' => sub { search_rdbms_new($param, $CurrentUser);  }, });
}

print "Test pour ERIC regexp\n";
{
    $CurrentUser->LoadByEmail('Eric.Boyon@equipement.gouv.fr');
    timethese(10, {'Old' => sub { search_rdbms($param, $CurrentUser);  }, 'New' => sub { search_rdbms_new($param, $CurrentUser);  }, });
}


sub search_rdbms {
    my $Email = shift;
    my $CurrentUser = shift;

    my @emails;

    my $Users = RT::Users->new( $RT::SystemUser );
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
	    #print "privileged\n";
	    # Ok, show everybody
	} elsif ( $RT::EmailCompletionUnprivileged eq 'privileged' ) {
	    #print "unpriv and only priv users\n";
	    next unless $User->Privileged();
	} elsif ( ref($RT::EmailCompletionUnprivileged) eq 'Regexp' ) {
	    #print "regexp\n";
	    next unless $User->EmailAddress =~ m/$RT::EmailCompletionUnprivileged/;
	} else {
	    #print "other\n";
	    next
	}

	push @emails, $User->EmailAddress;
    }
    @emails;
}

sub search_rdbms_new {
    my $Email = shift;
    my $CurrentUser = shift;

    return unless $CurrentUser->Privileged() or defined $RT::EmailCompletionUnprivileged;

    my $Users = RT::Users->new( $RT::SystemUser );
    foreach my $field (@{$RT::EmailCompletionSearchFields}) {
	$Users->Limit(SUBCLAUSE => 'EmailCompletion', ALIAS => 'main', FIELD => $field, OPERATOR => $RT::EmailCompletionSearch, VALUE => $Email, ENTRYAGGREGATOR => 'OR');
    }

    $RT::Logger->debug($Users->BuildSelectQuery);

    my @users;
    while (my $User = $Users->Next()) {
	next if $User->id == $RT::Nobody->id;

	# some cleaning on emailaddress
	next if $User->EmailAddress !~ m{[a-zA-Z0-9_.-]+@[^.]+\.[^.]};
	next if $User->EmailAddress =~ m{[,?!/;\\]};

	push @users, $User;
    }

    # if you're privileged user you can see anybody
    #
    # if you're not by default you can see nobody
    # if RT::EmailCompletionUnprivileged is set to anybody you can see anybody
    # else you can see only privileged users

    if ( $CurrentUser->Privileged() or $RT::EmailCompletionUnprivileged eq 'everybody' ) {
	# Ok, show everybody

    } elsif ( $RT::EmailCompletionUnprivileged eq 'privileged' ) {
	@users = grep { $_->Privileged()  } @users;

    } elsif ( ref($RT::EmailCompletionUnprivileged) eq 'Regexp' ) {
	@users = grep { $_->EmailAddress() =~ m/$RT::EmailCompletionUnprivileged/ } @users;

    } else {
	@users = ();
    }

    my @email = map { $_->EmailAddress() } @users;
}
