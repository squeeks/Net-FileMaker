#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

BEGIN
{
    use_ok( 'Net::FileMaker::XML::ResultSet::Row' );
}

diag( "Net::FileMaker::XML::ResultSet::Row, Perl $], $^X" );
