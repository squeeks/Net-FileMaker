package Net::FileMaker::XML::ResultSet;

use strict;
use warnings;
use Net::FileMaker::XML;

=head1 NAME

Net::FileMaker::XML::ResultSet

=head1 SYNOPSIS

This module handles the hash returned by the Net::FileMaker::XML search methods. 
Don't call this module directly, instead use L<Net::FileMaker::XML>.

=head1 METHODS

=cut

sub new
{
    my($class, %args) = @_;
    my @rows;
    my $self = {
        _res_hash      => $args{rs}, # complete result hash provided by Net::FileMaker::XML search methods
        _db            => $args{db}, # ref to the db, it is useful to add an $row->update method later
        # these are the references to the parsed blocks
        _field_def       => undef, 
        _rows           => \@rows            
    };
    bless $self;
    
    # let's begin the parsing
    $self->_parse;
    
    return $self;
}

=head2 fields_definition

Returns an hash with the fields' definition. See
L<Net::FileMaker::XML::FieldsDefinition::Field>.

=cut

sub fields_definition
{
    my $self = shift;
    return $self->{_field_def}->fields;
}

=head2 datasource

Return an hash with useful information about the datasource.
You don't need to use this information to parse the date, time or timestamp fields 
as it is already done by the C<get_inflated> methods of each row returned by the I<rows> method.

the hash contains:

=over 4

=item * database          

    database file name

=item * layout       

    kind of layout, eg. 'List

=item * timestamp-format

    eg. 'MM/dd/yyyy HH:mm:ss'

=item * date-format       

    eg. 'MM/dd/yyyy'

=item * time-format       

    eg. 'HH:mm:ss'

=item * table             

    name of the selected database table

=item * total-count       

    total count of the records in the selected table

=back


=cut

sub datasource
{
    my $self = shift;
    return $self->{_res_hash}{datasource};
}

=head2 xmlns

Returns the XML namespace of the response.

=cut

sub xmlns
{
    my $self = shift;
    return $self->{_res_hash}{xmlns}; 
}


=head2 version

Returns the XML version of the response.

=cut

sub version
{
    my $self = shift;
    return $self->{_res_hash}{version}; 
}

=head2 product

Returns an hash with information about the FileMaker Server.

=cut

sub product
{
    my $self = shift;
    return {
        version => $self->{_res_hash}{product}{'FileMaker Web Publishing Engine'}{version},
        build    => $self->{_res_hash}{product}{'FileMaker Web Publishing Engine'}{build},
    }
}

=head2 total_count

Returns an integer representing the total number of rows that match the research
but B<does not> take into account the limit clause.

=cut

sub total_count
{
    my $self = shift;
    return $self->{_res_hash}{resultset}{count};
}

=head2 fetch_size

Returns an integer representing the total number of rows of the resultset, but
does take into account the limit clause.

=cut

sub fetch_size
{
    my $self = shift;
    return $self->{_res_hash}{resultset}{'fetch-size'};
}


# _parse_rows
sub _parse_rows
{
    my $self = shift;
    require Net::FileMaker::XML::ResultSet::Row;
    my $cd = $self->fields_definition;    # column definition, I need it for the inflater
    my $ds = $self->datasource;
    if($self->fetch_size == 1){ # if the fetch size is 1 it returns an hash with the row, if more it returns an array
        push @{$self->{_rows}} , Net::FileMaker::XML::ResultSet::Row->new($self->{_res_hash}{resultset}{record}, $cd , $ds);
    }else{
        for my $row (@{$self->{_res_hash}{resultset}{record}}){
            push @{$self->{_rows}} , Net::FileMaker::XML::ResultSet::Row->new($row, $cd,$ds,$self->{_db});
        }
    }
}

=head2 rows

Returns all the rows of the resultset as L<Net::FileMaker::XML::ResultSet::Row>
objects.

=cut

sub rows
{
    my $self = shift;
    return $self->{_rows};
}

# _parse
# calls all the methods that parse the single blocks of the response
sub _parse
{
    my $self = shift;
    # parse the resultset
    $self->_parse_field_definition;
    $self->_parse_rows;
}

# _parse_field_definition
# parses the field definition instantiating a N::F::X::D::FieldDefinition
sub _parse_field_definition
{
    my ($self)  = @_;
    require Net::FileMaker::XML::ResultSet::FieldsDefinition;
    $self->{_field_def} = Net::FileMaker::XML::ResultSet::FieldsDefinition->new($self->{_res_hash}{metadata}{'field-definition'});
}



1;
