package Net::FileMaker::XML::ResultSet::FieldsDefinition::Field;

use strict;
use warnings;
use Moose;
use Carp;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter Net::FileMaker::XML);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
our @EXPORT_OK = (  );

our @EXPORT = qw(

    
);

=head1 NAME

Net::FileMaker::XML::ResultSet::FieldsDefinition::Field

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

This module handles the single field definition hash returned by the Net::FileMaker::XML search methods  . Don't call this module directly, instead use L<Net::FileMaker::XML>.

=head1 METHODS

=cut

sub new
{
	my($class, $res_hash) = @_;
    
	my $self = {
		_res_hash      => $res_hash, 
		global 			=> undef,
		numeric_only 	=> undef,
		four_digit_year => undef,
		not_empty 		=> undef,
		auto_enter 		=> undef,
		type 			=> undef,
		time_of_day 	=> undef,
		max_repeat  	=> undef,
		result		 	=> undef		
	};
	bless $self;
	$self->_parse;
	return $self;
}

# _parse
# 



#The <field-definition> attributes specify: 
#  whether the field is an auto-enter field (“yes” or “no”) 
#  whether the field is a four-digit-year field (“yes” or “no) 
#  whether it is a global field (“yes” or “no”)
#  the maximum number of repeating values (max-repeat attribute)
#  the maximum number of characters allowed (max-characters attribute) 
#  whether it is a not-empty field (“yes” or “no”)
#  whether it is for numeric data only (“yes” or “no”) 
#  result (“text”, “number”, “date”, “time”, “timestamp”, or “container”) 
#  whether it is a time-of-day field (“yes” or “no”) 
#  type (“normal”, “calculation”, or “summary”


sub _parse
{
	my $self = shift;
	$self->{global} 		= $self->{_res_hash}{global} eq 'no' ? 0 : 1				if defined $self->{_res_hash}{global} ;
	$self->{numeric_only} 	= $self->{_res_hash}{'numeric-only'} eq 'no' ? 0 : 1 		if defined $self->{_res_hash}{'numeric-only'};
	$self->{four_digit_year} = $self->{_res_hash}{'four-digit-year'} eq 'no' ? 0 : 1	if defined $self->{_res_hash}{'four-digit-year'};
	$self->{not_empty} 		= $self->{_res_hash}{'not-empty'} eq 'no' ? 0 : 1			if defined $self->{_res_hash}{'not-empty'};
	$self->{auto_enter} 	= $self->{_res_hash}{'auto-enter'} eq 'no' ? 0 : 1			if defined $self->{_res_hash}{'auto-enter'};
	$self->{type} 			= $self->{_res_hash}{type}									if defined $self->{_res_hash}{type};
	$self->{time_of_day} 	= $self->{_res_hash}{'time-of-day'} eq 'no' ? 0 : 1			if defined $self->{_res_hash}{'time-of-day'};
	$self->{max_repeat} 	= $self->{_res_hash}{'max-repeat'}							if defined $self->{_res_hash}{'max-repeat'};
	$self->{max_characters}	= $self->{_res_hash}{'max-characters'}						if defined $self->{_res_hash}{'max-characters'};	
	$self->{result} 		= $self->{_res_hash}{result}								if defined $self->{_res_hash}{result};
}

=head2 get('field')

returns the value for the passed parameter

the accepted params are ( possible results in parentheses ):	
=over 4

=item * global (0,1)
=item * numeric_only (0,1)
=item * four_digit_year (0,1)
=item * not_empty (0,1)
=item * auto_enter (0,1)
=item * type (“normal”, “calculation”, or “summary”)
=item * time_of_day (0,1)
=item * max_repeat (int)
=item * max_characters (int)
=item * result (“text”, “number”, “date”, “time”, “timestamp”, or “container”) 

=cut

my @availables = qw( global numeric_only four_digit_year not_empty auto_enter type time_of_day max_repeat max_characters result );

sub get
{
	my ( $self, $par ) = @_;

	croak 'this parameter is not defined!' if(! grep $_ eq $par, @availables);
	return $self->{$par};
}

=head2 get_all

	returns a reference to an hash with all the parameters of this field

=cut

sub get_all
{
	my $self = shift;
	my %tmp = map { $_ => $self->{$_} } @availables;
	return \%tmp;
}


1;
__END__