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

our @EXPORT = qw();

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
		_res_hash      => $res_hash		
	};
	bless $self;
	$self->_parse;
	return $self;
}

# _parse
# 

sub _parse
{
	my $self = shift;
	$self->{global} 			= $self->{_res_hash}{global} eq 'no' ? 0 : 1				if defined $self->{_res_hash}{global} ;
	$self->{'numeric-only'} 	= $self->{_res_hash}{'numeric-only'} eq 'no' ? 0 : 1 		if defined $self->{_res_hash}{'numeric-only'};
	$self->{'four-digit-year'} 	= $self->{_res_hash}{'four-digit-year'} eq 'no' ? 0 : 1		if defined $self->{_res_hash}{'four-digit-year'};
	$self->{'not-empty'} 		= $self->{_res_hash}{'not-empty'} eq 'no' ? 0 : 1			if defined $self->{_res_hash}{'not-empty'};
	$self->{'auto-enter'} 		= $self->{_res_hash}{'auto-enter'} eq 'no' ? 0 : 1			if defined $self->{_res_hash}{'auto-enter'};
	$self->{type} 				= $self->{_res_hash}{type}									if defined $self->{_res_hash}{type};
	$self->{'time-of-day'} 		= $self->{_res_hash}{'time-of-day'} eq 'no' ? 0 : 1			if defined $self->{_res_hash}{'time-of-day'};
	$self->{'max-repeat'} 		= $self->{_res_hash}{'max-repeat'}							if defined $self->{_res_hash}{'max-repeat'};
	$self->{'max-characters'}	= $self->{_res_hash}{'max-characters'}						if defined $self->{_res_hash}{'max-characters'};	
	$self->{result} 			= $self->{_res_hash}{result}								if defined $self->{_res_hash}{result};
}

=head2 get('field')

returns the value for the passed parameter

it might return ( possible results in parentheses ):
	
=over

=item * global (0,1)

=item * numeric-only (0,1)

=item * four-digit-year (0,1)

=item * not-empty (0,1)

=item * auto_enter (0,1)

=item * type (“normal”, “calculation”, or “summary”)

=item * time-of_day (0,1)

=item * max-repeat (int)

=item * max-characters (int)

=item * result (“text”, “number”, “date”, “time”, “timestamp”, or “container”) 

=back

=cut

my @availables = qw( global numeric-only four-digit-year not-empty auto-enter type time-of-day max-repeat max-characters result );

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