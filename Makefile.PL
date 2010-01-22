use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::FileMaker',
    AUTHOR              => q{Squeeks <squeek@cpan.org>},
    VERSION_FROM        => 'lib/Net/FileMaker.pm',
    ABSTRACT_FROM       => 'lib/Net/FileMaker.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    BUILD_REQUIRES => {
    	'LWP' 		=> 0,
	'XML::Simple'   => "2.18",
    },
    
    META_MERGE => {
	resources => {
            repository => 'http://github/squeeks/Net-FileMaker'
	}
    },

    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net::FileMaker-*' },
);
