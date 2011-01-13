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
	my($class, $res_hash , $dataset) = @_;
	
	my $cd = $dataset->fields_definition;    # column definition, I need it for the inflater
	my $ds = $dataset->datasource;
	my $db = $dataset->{db};
	
	my $self = {
		columns_def => $cd,
		datasource 	=> $ds,    
		result_hash => $res_hash,
		db_ref     	=> $db        
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

=head2 get_type('colname')

Returns the type of the selected column for this row.

=cut

sub get_type
{
	my ( $self , $col ) = @_;
	return $self->{columns_def}{$col}{result};
}

=head2 get_inflated('colname')

Returns the value of the selected column for this row. If the type is
date, time or datetime returns, it will return a L<DateTime> object.

=cut

sub get_inflated
{
	my ( $self , $col ) = @_;
	# if the field is a  “date”, “time” or “timestamp"
	if(defined $self->get_type($col)){
		if($self->get_type($col) =~ m/^(date|time|timestamp)$/xms ){
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

Returns an hash with column names & relative values for this row. 
If the type is date, time or datetime returns a L<DateTime> object.

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

=head2 update(params => { 'Field Name' => $value , ... })

Updates the row with the fieldname/value pairs passed to params, 
returns an L<Net::FileMaker::XML::ResultSet> object.

=head3 Dates and Times editing

Filemaker accepts time|date editing as a string only in the format 
defined in the datasource, otherwise throws an error.
If you don't want to mess around with that this method allows you 
to pass a L<DateTime> object and does the dirty work for you. 

=cut


sub update
{
	my ( $self , %pars ) = @_;
	my $db 		= $self->{db_ref};
	my $layout 	= $self->{datasource}{layout};
	# let's play with DateTimes if passed
	my $updates;
	foreach my $key (keys %{$pars{params}}){
		my $value = $pars{params}{$key};
		if(ref($value) eq 'DateTime' ){
			# let's find what kind of field it is
			my $format = $self->get_type($key);
			# and then it's format
			my $pattern = $self->{datasource}{"$format-format"}; # eg. 'MM/dd/yyyy HH:mm:ss'
			$pars{params}{$key} = new DateTime::Format::CLDR(pattern => $pattern)->format_datetime($value);
		}
	}
	my $result = $db->edit(layout =>$layout  , recid => $self->record_id , params => $pars{params} );
	return $result;
}

=head2 delete(params => { 'Field Name' => $value , ... })

Deletes this row, returns an L<Net::FileMaker::XML::ResultSet> object.

=cut


sub delete
{
	my ( $self , %params ) = @_;
	my $db 		= $self->{db_ref};
	my $layout 	= $self->{datasource}{layout};
	my $result = $db->delete(layout =>$layout  , recid => $self->record_id , params => $params{params});
	return $result;
}

1;
