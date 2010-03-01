#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

diag(' '); # Wraps message to next line
diag('To prevent skipping these tests, set the environment varibles FMS_HOST, FMS_USER and FMS_PASS to the respective address, user and password of your server.');
diag('If you do not set these vars, the tests will just skip where necessary and you will not get complete coverage.');

BEGIN {
    use_ok( 'Net::FileMaker' ) || print "Bail out!";
}

diag( "Testing Net::FileMaker $Net::FileMaker::VERSION, Perl $], $^X" );
