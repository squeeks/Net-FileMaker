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
    
    PREREQ_PM => {
    'Test::More'	=> 0,
	'LWP' 		=> 0,
	'URI'		=> 0,
	'DateTime::Format::CLDR'  => 0,
	'Carp'      => 0,
	'XML::Twig'     => "3.33",
    },

    MIN_PERL_VERSION => '5.008',

    META_MERGE => {
	resources => {
            repository => 'http://github.com/squeeks/Net-FileMaker'
	}
    },

    test      		=> { TESTS => join( ' ', (glob( 't/*.t'), glob('t/*/*.t'))) },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net::FileMaker-*' },
);
