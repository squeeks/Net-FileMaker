package Net::FileMaker::XML::ResultSet::Row;

use strict;
use warnings;
use Carp;
use DateTime;
use DateTime::Format::CLDR;

=head1 NAME

Net::FileMaker::XML::ResultSet::FieldsDefinition::Row

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

This module handles the single row of the resultset returned by the Net::FileMaker::XML search methods  . Don't call this module directly, instead use L<Net::FileMaker::XML>.

=head1 METHODS

=cut

sub new
{
	my($class, $res_hash , $col_def , $data_source , $db) = @_;
	my $self = {
		_col_def	=> $col_def,
		_datasource => $data_source,	
		_res_hash	=> $res_hash,
		_db_ref     => $db		
	};
	bless $self;
	$self->_parse;
	return $self;
}



# _parse
sub _parse{
	my $self = shift;
	
}

=head2 mod_id

	returns the mod id for this row

=cut

sub mod_id
{
	my $self = shift;
	return $self->{_res_hash}{'mod-id'};
}


=head2 record_id

	returns the record id for this row

=cut

sub record_id
{
	my $self = shift;
	return $self->{_res_hash}{'record-id'};
}


=head2 get('colname')

	returns the value of the selected column for this row

=cut

sub get
{
	my ( $self , $col ) = @_;
	return $self->{_res_hash}{field}{$col}{data};
}


=head2 get_inflated('colname')

	returns the value of the selected column for this row, if the type is date|time|datetime returns a DateTime obj

=cut

sub get_inflated
{
	my ( $self , $col ) = @_;
	# if the field is a  “date”, “time” or “timestamp"
	if(defined $self->{_col_def}{$col}){
		if($self->{_col_def}{$col}{result} =~ m/^(date|time|timestamp)$/xms ){
			# let's convert it to a DateTime
			my $pattern = $self->{_datasource}{"$1-format"}; # eg. 'MM/dd/yyyy HH:mm:ss'
		    my $cldr = new DateTime::Format::CLDR(
		        pattern     => $pattern
		    );
		    return $cldr->parse_datetime($self->{_res_hash}{field}{$col}{data}) if(defined $self->{_res_hash}{field}{$col}{data});
		}
	}
	# if the type is one of the ones above let's convert the value in a DateTime
	return $self->{_res_hash}{field}{$col}{data};
}

=head2 get_columns

	returns an hash with column names & relative values for this row

=cut
sub get_columns
{
	my ( $self , $col ) = @_;
	my %res;
	foreach my $k(sort keys %{$self->{_res_hash}{field}}) {
		$res{$k} = $self->get($k);
	}	
	return \%res;
}

=head2 get_inflated_columns

	returns an hash with column names & relative values for this row, if the type is date|time|datetime returns a DateTime obj

=cut

sub get_inflated_columns
{
	my ( $self , $col ) = @_;
	my %res;
	foreach my $k(sort keys %{$self->{_res_hash}{field}}) {
		$res{$k} = $self->get_inflated($k);
	}	
	return \%res;
}


1;
__END__