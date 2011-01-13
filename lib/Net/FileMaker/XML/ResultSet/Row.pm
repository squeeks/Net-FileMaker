package Net::FileMaker::XML::ResultSet::Row;

use strict;
use warnings;
use Carp;
use DateTime;
use DateTime::Format::CLDR;

=head1 NAME

Net::FileMaker::XML::ResultSet::FieldsDefinition::Row

=head1 SYNOPSIS

This module handles the single row of the resultset returned by the
L<Net::FileMaker::XML> search methods. Don't call this module directly, 
instead use L<Net::FileMaker::XML>.

=head1 METHODS

=cut

sub new
{
	my($class, $res_hash , $col_def , $data_source , $db) = @_;
	my $self = {
		columns_def    => $col_def,
		datasource => $data_source,    
		result_hash    => $res_hash,
		db_ref     => $db        
	};
	bless $self;
	return $self;
}

=head2 mod_id

Returns the mod id for this row.

=cut

sub mod_id
{
	my $self = shift;
	return $self->{result_hash}{'mod-id'};
}


=head2 record_id

Returns the record id for this row.

=cut

sub record_id
{
	my $self = shift;
	return $self->{result_hash}{'record-id'};
}


=head2 get('colname')

Returns the value of the selected column for this row.

=cut

sub get
{
	my ( $self , $col ) = @_;
	return $self->{result_hash}{field}{$col}{data};
}


=head2 get_inflated('colname')

Returns the value of the selected column for this row. If the type is
date, time or datetime returns, it will return a L<DateTime> object.

=cut

sub get_inflated
{
	my ( $self , $col ) = @_;
	# if the field is a  “date”, “time” or “timestamp"
	if(defined $self->{columns_def}{$col}){
		if($self->{columns_def}{$col}{result} =~ m/^(date|time|timestamp)$/xms ){
			# let's convert it to a DateTime
			my $pattern = $self->{datasource}{"$1-format"}; # eg. 'MM/dd/yyyy HH:mm:ss'
			my $cldr = DateTime::Format::CLDR->new(
				pattern     => $pattern
			);
			return $cldr->parse_datetime($self->{result_hash}{field}{$col}{data}) if(defined $self->{result_hash}{field}{$col}{data});
		}
	}
	# if the type is one of the ones above let's convert the value in a DateTime
	return $self->{result_hash}{field}{$col}{data};
}

=head2 get_columns

Returns an hash with column names & relative values for this row.

=cut
sub get_columns
{
	my ( $self , $col ) = @_;
	my %res;
	foreach my $k(sort keys %{$self->{result_hash}{field}}) {
		$res{$k} = $self->get($k);
	}    
	return \%res;
}

=head2 get_inflated_columns

Returns an hash with column names & relative values for this row. If the type is
date, time or datetime returns a L<DateTime> object.

=cut

sub get_inflated_columns
{
	my ( $self , $col ) = @_;
	my %res;
	foreach my $k(sort keys %{$self->{result_hash}{field}}) {
		$res{$k} = $self->get_inflated($k);
	}    
	return \%res;
}



1;
