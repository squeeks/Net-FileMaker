#!perl -T

use strict;
use warnings;

use Test::More;

use_ok('Net::FileMaker');
use_ok('Net::FileMaker::XML');

SKIP:
{
	skip "FileMaker Server host not specified", 4 unless($ENV{FMS_HOST});
	diag('Server has been defined as '.$ENV{FMS_HOST}) if($ENV{FMS_HOST});

	# Construct through Net::FileMaker
	my $fm = Net::FileMaker->new( host => $ENV{FMS_HOST}, type => 'xml');
	ok($fm, 'Net::FileMaker::XML constructed through Net::FileMaker');
	my $db = $fm->dbnames;
	ok($db, 'Databases found');

	# Direct access the package
	my $fmx = Net::FileMaker::XML->new( host => $ENV{FMS_HOST});
	ok($fmx, 'Directly constructed Net::FileMaker::XML');
	my $dbx = $fmx->dbnames;
	ok($dbx, 'Databases found');

}

done_testing();
