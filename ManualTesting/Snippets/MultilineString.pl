#!/usr/bin/perl
use strict;
use warnings;

my $name = 'Foo';

# The multiline string starts after the <<"END_MSG" and ends when END_MSG appears on its own line
my $message = <<"END_MSG";
Hello $name, 
how are you?
This message can span multiple lines and even 
interpolate variables like \$name.
END_MSG

# foo!
print $message;
