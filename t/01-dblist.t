#!perl -T

use strict;
use warnings;

use Test::More;

use_ok('Net::FileMaker');

SKIP:
{
	skip "FileMaker Server settings not found", 2 unless($ENV{FMS_HOST} && $ENV{FMS_USER} && $ENV{FMS_PASS});

	my $fh = Net::FileMaker->new( host => $ENV{FMS_HOST}, user => $ENV{FMS_USER}, pass => $ENV{FMS_PASS} );
	ok($fh, 'Net::FileMaker object is defined');

	my $db = $fh->dbnames;
	ok($db, 'Databases found');
}

done_testing();
