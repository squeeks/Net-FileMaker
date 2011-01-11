#!perl -T

use strict; 
use warnings;

use Test::More;

unless ( $ENV{FMS_HOST} && $ENV{FMS_USER} && $ENV{FMS_PASS} && $ENV{FMS_LAYOUT} )
{
    plan( skip_all => "FileMaker Server and authentication not declared" );
}

use_ok('Net::FileMaker');
use_ok('Net::FileMaker::XML');
use_ok('Net::FileMaker::XML::ResultSet');


# Direct access the package 
my $fmx = Net::FileMaker::XML->new( host => $ENV{FMS_HOST});
ok($fmx, 'Directly constructed Net::FileMaker::XML');

my $dbx = $fmx->dbnames;
my $fmdb = $fmx->database(db => $dbx->[0], user => $ENV{FMS_USER}, pass => $ENV{FMS_PASS});
ok($fmdb,'Logged in');

my $records = $fmdb->find(layout => $ENV{FMS_LAYOUT}, params => { '-max' => '3'});
my $rs = Net::FileMaker::XML::ResultSet->new(rs => $records , db => $fmdb);
ok($rs, 'Directly constructed Net::FileMaker::XML::ResultSet');

done_testing();
