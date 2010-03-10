#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

BEGIN
{
    use_ok( 'Net::FileMaker::Error' );
}

diag( "Testing Net::FileMaker::Error, Perl $], $^X" );
