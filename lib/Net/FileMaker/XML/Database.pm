package Net::FileMaker::XML::Database;

use strict;
use warnings;

use URI::Escape;

our @ISA = qw(Net::FileMaker::XML);

=head1 NAME

Net::FileMaker::XML::Database

=cut

=head1 SYNOPSIS

This module handles all the tasks with XML data.

    use Net::FileMaker::XML;
    my $fm = Net::FileMaker::XML->new();
    my $db = $fm->database(db => $db, user => $user, pass => $pass);
    
    my $layouts = $db->layoutnames;
    my $scripts = $db->scriptnames;


=head1 METHODS

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
                xml       => XML::Twig->new,
		uri	  => URI->new($args{host})
		
	};

	return bless $self;
}

=head2 layoutnames($database)

Returns an arrayref containing layouts accessible for the respective database.

=cut

sub layoutnames
{
	my $self = shift;
        my $res = $self->_request(
                user      => $self->{user},
                pass      => $self->{pass},
                resultset => $self->{resultset},
                query     => '-layoutnames',
                params    => { '-db' => $self->{db} }
        );   


	if($res->is_success)
	{
		my $xml = $self->{xml}->parse($res->content);
		return $self->_compose_arrayref('LAYOUT_NAME', $xml->simplify);
	}
	else
	{
		return undef;
	}
}

=head2 scriptnames($database)

Returns an arrayref containing scripts accessible for the respective database.

=cut

sub scriptnames
{
	my $self = shift;
        my $res = $self->_request(
                user      => $self->{user},
                pass      => $self->{pass},
                resultset => $self->{resultset},
                query     => '-scriptnames',
                params    => { '-db' => $self->{db} }
        );   


	if($res->is_success)
	{
		my $xml = $self->{xml}->parse($res->content);
		return $self->_compose_arrayref('SCRIPT_NAME', $xml->simplify);
	}
	else
	{
		return undef;
	}
}


=head2 findall($layout, { options })

Returns all rows on a specific database and layout.

=cut

sub findall
{
	my ($self, $layout, $args) = @_;

	my $url;

	# Keys are just actual URL vars from the API minus the prefixing dash.
	# According to the documentation, that means all the options are:
	# –recid, –lop, –op, –max, –skip, –sortorder, –sortfield, –script, –script.prefind, –script.presort

	#TODO: Validations done on the applicable params so we don't spew junk to the server.
	for my $var (keys %{$args})
	{	
		$url .= sprintf('-%s=%s&', uri_escape_utf8($var), uri_escape_utf8($args->{$var}));
	}

        $url .= '-findall&-db=' . uri_escape_utf8($self->{db}) . '&-lay=' . $layout;

	my $res = $self->_request(
			resultset => $self->{resultset}, 
			user 	  => $self->{user}, 
			pass 	  => $self->{pass}, 
			query	  => $url
	);

	if($res->is_success)
	{
		my $xml = $self->{xml}->parse($res->content);
		my $xml_data = $xml->simplify;
		return $xml_data->{resultset}->{record};
	}
	else
	{
		return $res;
	}2

}

=head2 total_rows($database, $layout)

Returns a scalar with the total rows for a given database and layout.

=cut

sub total_rows
{
	my($self, $layout) = @_;

	# Just do a findall with 1 record and parse the result. This might break on an empty database.
	my $res = $self->_request(
		resultset => $self->{resultset}, 
		query 	  =>'-findall&-max=1&-db='.uri_escape_utf8($self->{db})."&-lay=".uri_escape_utf8($layout)
	);

	if($res->is_success)
	{
		my $xml = $self->{xml}->parse($res->content);
		my $xml_data = $xml->simplify;
		return $xml_data->{resultset}->{count};
	}
	else
	{
		return undef;
	}
}


1; # End of Net::FileMaker::XML::Database;

