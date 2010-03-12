package Net::FileMaker::XML::Database;

use strict;
use warnings;

use URI::Escape;

our @ISA = qw(Net::FileMaker::XML);

#
# Particular methods have specific parameters that are optional, but need to be validated to mitigate sending
# bad parameters to the server.
my $acceptable_params = {
	'findall' => '-recid|-lop|-op|-max|-skip|-sortorder|-sortfield|-script|-script\.prefind|-script\.presort',
	'findany' => '-recid|-lop|-op|-max|-skip|-sortorder|-sortfield|-script|-script\.prefind|-script\.presort',
	'delete'  => 'db|lay|recid|script',
	'dup'     => 'db|lay|recid|script',
	'edit'    => 'db|lay|recid|modid|script',
};

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
		resultset => '/fmi/xml/fmresultset.xml',
                ua        => LWP::UserAgent->new,
                xml       => XML::Twig->new,
		uri	  => URI->new($args{host})
		
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

=head2 scriptnames

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


=head2 findall(layout => $layout, params => { parameters }, nocheck => 1)

Returns all rows on a specific database and layout.

nocheck is an optional argument that will skip checking of parameters if set to 1.

=cut

sub findall
{
	my ($self, %args) = @_;

	my $params = { 
		'-lay' => $args{layout},
		'-db'  => $self->{db}
	};

	if($args{params} && ref($args{params}) eq 'HASH')
	{
		for my $param(keys %{$args{params}})
		{
			# Perform or skip parameter checking
			if($args{nocheck} && $args{nocheck} == 1)
			{
				$params->{$param} = $args{params}->{$param};
			}
			else
			{
				$params->{$param} = $args{params}->{$param} if $self->_assert_param($param, $acceptable_params->{findall});
			}
		}
	}

	my $res = $self->_request(
			resultset => $self->{resultset}, 
			user 	  => $self->{user}, 
			pass 	  => $self->{pass}, 
			query	  => '-findall',
			params    => $params
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
	};

}

=head2 findany(layout => $layout, params => { parameters }, nocheck => 1)

Returns a random hashref of rows on a specific database and layout.

nocheck is an optional argument that will skip checking of parameters if set to 1.

=cut

sub findany
{
	my ($self, %args) = @_;

	my $params = { 
		'-lay' => $args{layout},
		'-db'  => $self->{db}
	};

	if($args{params} && ref($args{params}) eq 'HASH')
	{
		for my $param(keys %{$args{params}})
		{
			# Perform or skip parameter checking
			if($args{nocheck} && $args{nocheck} == 1)
			{
				$params->{$param} = $args{params}->{$param};
			}
			else
			{
				$params->{$param} = $args{params}->{$param} if $self->_assert_param($param, $acceptable_params->{findall});
			}
		}
	}

	my $res = $self->_request(
			resultset => $self->{resultset}, 
			user 	  => $self->{user}, 
			pass 	  => $self->{pass}, 
			query	  => '-findany',
			params    => $params
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
	};

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

