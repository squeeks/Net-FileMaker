#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

BEGIN
{
    use_ok( 'Net::FileMaker::XML::ResultSet' );
}

diag( "Testing Net::FileMaker::XML::ResultSet, Perl $], $^X" );