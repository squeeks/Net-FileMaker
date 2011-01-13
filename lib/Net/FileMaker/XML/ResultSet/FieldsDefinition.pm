package Net::FileMaker::XML::ResultSet::FieldsDefinition;

use strict;
use warnings;

=head1 NAME

Net::FileMaker::XML::ResultSet::FieldsDefinition

=head1 SYNOPSIS

This module handles the field definition hash returned by the
L<Net::FileMaker::XML> search methods. Don't call this module 
directly, instead use L<Net::FileMaker::XML>.

=head1 METHODS

=cut

sub new
{
	my($class, $res_hash) = @_;
	
	my $self = {
		_res_hash      => $res_hash, # complete result hash provided by Net::FileMaker::XML search methods
		# these are the references to the parsed blocks
	};
	bless $self;
	$self->_parse;
	return $self;
}

=head2 get($field_name)

Returns the field definition object
(L<Net::FileMaker::XML::ResultSet::FieldsDefinition::Field>).

=cut

sub get
{
	my ( $self, $field ) = @_;
	return $self->{fields}{$field};
}

=head2 fields

Returns an hash with the field definition objects
(L<Net::FileMaker::XML::ResultSet::FieldsDefinition::Field>)

=cut

sub fields
{
	my ( $self, $field ) = @_;
	return $self->{fields};
}


# _parse
# 
sub _parse
{
	my $self = shift;
	my %fields;
	require Net::FileMaker::XML::ResultSet::FieldsDefinition::Field;
	foreach my $key (sort keys %{$self->{_res_hash}}) {
		$fields{$key} = Net::FileMaker::XML::ResultSet::FieldsDefinition::Field->new($self->{_res_hash}{$key});
	}
	$self->{fields} = \%fields;
}

1;
