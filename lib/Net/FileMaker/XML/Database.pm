package Net::FileMaker::XML::Database;

use strict;
use warnings;

use URI::Escape;

our @ISA = qw(Net::FileMaker::XML);

=head1 NAME

Net::FileMaker::XML::Database;

=head1 VERSION

Version 0.05 - Developer release 1

=cut

our $VERSION = 0.05_01;

=head1 SYNOPSIS

This module handles all the tasks with XML data.

    use Net::FileMaker::XML;
    my $fm = Net::FileMaker::XML->new();
    my $db = $fm->database(db => $db, user => $user, pass => $pass);
    
    my $layouts = $db->layoutnames;

=cut

sub new
{
	my($class, %args) = @_;

	my $self = {
		host      => $args{host},
		db        => $args{db},
		user      => $args{user},
		pass      => $args{pass},
		resultset => '/fmi/xml/fmresultset.xml?',
                ua        => LWP::UserAgent->new,
                xml       => XML::Simple->new		
	};

	return bless $self;
}

=head2 layoutnames

Returns an arrayref containing layouts accessible for the respective database.

=cut

sub layoutnames
{
	my $self = shift;
	my $res = $self->_request(
		user => $self->{user},
		pass => $self->{pass},
		resultset => $self->{resultset},
		query =>'-db='.uri_escape_utf8($self->{db}).'&-layoutnames'
	);

	if($res->is_success)
	{
		my $xml = $self->{xml}->XMLin($res->content);

		return $self->_compose_arrayref($xml);
	}
	else
	{
		return undef;
	}
}

=head2 findall($layout, %options)

Returns all rows on a specific database and layout.

=cut

sub findall
{
	my ($self, %args) = @_;

	my $url = '-findall&-db=' . $args{db} . '' . $args{layout}; 

	# Keys are just actual URL vars from the API minus the prefixing dash.
	# According to the documentation, that means all the options are:
	# –recid, –lop, –op, –max, –skip, –sortorder, –sortfield, –script, –script.prefind, –script.presort

	#TODO: Validations done on the applicable params so we don't spew junk to the server.
	for my $var (keys %{$args{params}})
	{	
		$url .= sprintf('-%s=%s&', uri_escape_utf8($var), uri_escape_utf8($args{$var}));
	}

	my $res = $self->_request(query=> $url, resultset => $self->{resultset});

	if($res->is_success)
	{
		my $xml = $self->{xml}->XMLin($res->content);

		return $xml->{resultset};
	}
	else
	{
		return undef;
	}

}

=head2 total_rows($database, $layout)

Returns a scalar with the total rows for a given database and layout.

=cut

sub total_rows
{
	my($self, $database, $layout) = @_;

	# Just do a findall with 1 record and parse the result. This might break on an empty database.
	my $res = $self->_request(resultset => $self->{resultset}, query =>'-findall&-max=1&-db='.uri_escape_utf8($database)."&-lay=".uri_escape_utf8($layout));

	if($res->is_success)
	{
		my $xml = XMLin($res->content);
		
		return $xml->{resultset}->{count};
	}
	else
	{
		return undef;
	}
}


1; # End of Net::FileMaker::XML::Database;
