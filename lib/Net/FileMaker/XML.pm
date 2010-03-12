package Net::FileMaker::XML;

use strict;
use warnings;

use XML::Twig;

=head1 NAME

Net::FileMaker::XML - Interact with FileMaker Server's XML Interface.

=head1 VERSION

Version 0.05

=cut

our $VERSION = "0.05_02";

=head1 SYNOPSIS

This module provides the interface for communicating with FileMaker Server's XML service.

You can simply invoke L<Net::FileMaker> directly and specify the 'type' 
key in the constructor as "xml":

    use Net::FileMaker;
    
    my $fms = Net::FileMaker->new(host => $host, type => 'xml');

It's also possible to call this module directly:
    
    my $fms = Net::FileMaker::XML->new(host => $host);
    my $dbnames = $fms->dbnames;
    my $fmdb = $fms->database();


=head1 METHODS

=head2 new(host => $host)

Creates a new object. The specified must be a valid address or host name.

=cut

sub new
{
	my($class, %args) = @_;

	# If the protocol isn't specified, let's assume it's just HTTP.
	if($args{host} !~/^http/)
	{
		$args{host} = 'http://'.$args{host};
	}

	my $self = {
		host	  => $args{host},
		ua 	  => LWP::UserAgent->new,
		xml	  => XML::Twig->new,
		uri	  => URI->new($args{host}),
		resultset => '/fmi/xml/fmresultset.xml', # Entirely for dbnames();
	};

	return bless $self;

}

=head2 database(db => $database, user => $user, pass => $pass)

Initiates a new database object for querying data in the databse.

=cut

sub database
{
	my($self, %args) = @_;

	require Net::FileMaker::XML::Database;
	return  Net::FileMaker::XML::Database->new(
			host => $self->{host},
			db   => $args{db},
			user => $args{user} || '',
			pass => $args{pass} || ''
		);
}


=head2 dbnames

Lists all XML/XSLT enabled databases for a given host. This method requires no authentication.

=cut

sub dbnames
{
	my $self = shift;
	my $res  = $self->_request(
			resultset => $self->{resultset}, 
			query	  =>'-dbnames'
	);

	if($res->is_success)
	{
		my $xml = $self->{xml}->parse($res->content);
		return $self->_compose_arrayref('DATABASE_NAME', $xml->simplify);
	}
	else
	{
		return undef;
	}

}

=head1 SEE ALSO

L<Net::FileMaker::XML::Database>

=cut

# _request(query => $query, params => $params, resultset => $resultset, user => $user, pass => $pass)
#
# Performs a request to the FileMaker Server. The query and resultset keys are mandatory, 
# however user and pass keys are not. The query should always be URI encoded.
sub _request
{
        my ($self, %args) = @_;

        # Construct the URI
        my $uri = $self->{uri}->clone;
        $uri->path($args{resultset});
        
        my $url;
	# This kind of defeats the purpose of using URI to begin with,
        if($args{params})
	{
                $uri->query_form(%{$args{params}});
                $url = $uri->as_string."&".$args{query};
        }
        else
        {
           $url = $uri->as_string."?".$args{query};
        }

        my $req = HTTP::Request->new(GET => $url);

        if($args{user} && $args{pass})
        {       
                $req->authorization_basic( $args{user}, $args{pass});
        }       

        my $res = $self->{ua}->request($req);

        return $res;

}

# _request_xml(query => $query, resultset => $resultset, user => $user, pass => $pass)
#
# Performs the same as _request, except will load and parse the XML itself. Returns a
# hashref containing the parsed XML on success.
sub _request_xml
{
	my($self, %args) = @_;

	my $url = $self->{host}.$self->{resultset}.$args{query};

	my $req = HTTP::Request->new(GET => $url);

	if($args{user} && $args{pass})
	{
		$req->authorization_basic( $args{user}, $args{pass});
	}

	my $res = $self->{ua}->request($req);

	if($res->is_success)
	{
		my $xml = XMLin($res->content);
		#TODO: Error Handling.
		return $xml;
	}
	else
	{
		# Shouldn't really return undef, rather...
		# TODO: Incorporate the HTTP error codes into the response so
		# N::F::Error::HTTP can deal with it.
		return undef;
	}

}


# _compose_arrayref($field_name, $xml)
# 
# A common occurance is recomposing response data so unnecessary structure is removed.
sub _compose_arrayref
{
	my ($self, $fieldname, $xml) = @_;
	
	my @output;

	if(ref($xml->{resultset}->{record}) eq 'HASH')
	{
		return $xml->{resultset}->{record}->{field}->{data};
	}
	elsif(ref($xml->{resultset}->{record}) eq 'ARRAY')
	{
		my @output;

		for my $record (@{$xml->{resultset}->{record}})
		{
			push @output, $record->{field}->{$fieldname}->{data};
		}
		
		return \@output;
	}

}


# _assert_param()
#
# Optional parameters sometimes validation to ensure they are correct.
# Warnings are issued if a parameter name is somehow invalid.
sub _assert_param
{
	my($self, $unclean_param, $acceptable_params) = @_;
	my $param;

	if($unclean_param =~/$acceptable_params/)
	{
		$param = $unclean_param;
	}
	else
	{
		# TODO: Localise this error message
		warn "Invalid parameter specified - $unclean_param";
	}


	return $param;
}


1; # End of Net::FileMaker::XML;
