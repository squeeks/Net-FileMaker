package Net::FileMaker::XML::ResultSet;

use strict;
use warnings;
use Moose;
use Net::FileMaker::XML;

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

Net::FileMaker::XML::ResultSet

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

This module handles the hash returned by the Net::FileMaker::XML search methods  . Don't call this module directly, instead use L<Net::FileMaker::XML>.

=head1 METHODS

=cut

sub new
{
	my($class, $res_hash) = @_;
    
	my $self = {
		_res_hash      => $res_hash, # complete result hash provided by Net::FileMaker::XML search methods
		# these are the references to the parsed blocks
		_field_def	   => undef, 
		_resultset     => undef,
		_datasource    => undef,
		_product       => undef,
		_version       => undef,
		_xmlns         => undef
	};
	bless $self;
	
	# let's begin the parsing
	$self->_parse;
	
	return $self;
}

# _parse
# calls all the methods that parse the single blocks of the response

sub _parse
{
	my $self = shift;
	# parse the resultset
	$self->_parse_field_definition;
}

# _parse_field_definition
# parses the field definition instantiating a N::F::X::D::FieldDefinition

sub _parse_field_definition
{
    my ($self)  = @_;
    require Net::FileMaker::XML::ResultSet::FieldsDefinition;
    $self->{_field_def} = new Net::FileMaker::XML::ResultSet::FieldsDefinition($self->{_res_hash}{metadata}{'field-definition'});
}

=head2 fields_definition

	returns the fields definition

=cut

sub fields_definition
{
	my $self = shift;
	return $self->{_field_def}->fields;
}

=head2 datasource

=item * 'database' 			# database file name
=item * 'layout' 			# kind of layout, eg. 'List'
=item * 'timestamp-format' 	# eg. 'MM/dd/yyyy HH:mm:ss',
=item * 'date-format' 		# eg. 'MM/dd/yyyy',
=item * 'time-format' 		# eg. 'HH:mm:ss',
=item * 'table' 			# name of the selected database table,
=item * 'total-count' 		# total count of the records in the selected table

=cut

sub fields_definition
{
	my $self = shift;
	return $self->{_field_def}->fields;
}

1; # End of Net::FileMaker::XML::Database;
__END__