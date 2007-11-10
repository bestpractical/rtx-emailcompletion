use inc::Module::Install;

RTx('EmailCompletion');
author('Nicolas Chuche <nchuche@barna.be>');
abstract('autompletion on mail');
license('perl');
WriteAll( meta => 1 );

sub MY::postamble {
    package MY;
    "\npredist: all\n" .
    "\tpod2readme  lib/RTx/EmailCompletion.pm > README\n".
    "\tsvk log -v  > ChangeLog\n"
}
