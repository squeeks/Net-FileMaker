package Net::FileMaker::XML::Database;

use strict;
use warnings;

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

This module handles all the tasks with XML data. Don't call this module directly, instead use L<Net::FileMaker::XML>.

    use Net::FileMaker::XML;
    my $fm = Net::FileMaker::XML->new(host => $host);
    my $db = $fm->database(db => $db, user => $user, pass => $pass);
    
    my $layouts = $db->layoutnames;
    my $scripts = $db->scriptnames;
    my $records = $db->findall( layout => $layout, params => { '-max' => '10'});
    my $records = $db->findany( layout => $layout, params => { '-skip' => '10'});

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
		uri	  => URI->new($args{host}),	
	};

	return bless $self;
}

=head2 layoutnames

Returns an arrayref containing layouts accessible for the respective database.

=cut

sub layoutnames
{
	my $self = shift;
        my $xml = $self->_request(
                user      => $self->{user},
                pass      => $self->{pass},
                resultset => $self->{resultset},
                query     => '-layoutnames',
                params    => { '-db' => $self->{db} }
        );   


	return $self->_compose_arrayref('LAYOUT_NAME', $xml);
}

=head2 scriptnames

Returns an arrayref containing scripts accessible for the respective database.

=cut

sub scriptnames
{
	my $self = shift;
        my $xml = $self->_request(
                user      => $self->{user},
                pass      => $self->{pass},
                resultset => $self->{resultset},
                query     => '-scriptnames',
                params    => { '-db' => $self->{db} }
        );   


	return $self->_compose_arrayref('SCRIPT_NAME', $xml);
}

=head2 find(layout => $layout, params => { parameters })

Returns a hashref of rows on a specific database and layout.

=cut

sub find
{
	my ($self, %args) = @_;

	$args{params}->{'-lay'} = $args{layout};
	$args{params}->{'-db'}  = $self->{db};
	
	my $xml = $self->_request(
			resultset => $self->{resultset}, 
			user 	  => $self->{user}, 
			pass 	  => $self->{pass}, 
			query	  => '-find',
			params    => $args{params}
	);

	return $xml;
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

	my $xml = $self->_request(
			resultset => $self->{resultset}, 
			user 	  => $self->{user}, 
			pass 	  => $self->{pass}, 
			query	  => '-findall',
			params    => $params
	);

	return $xml;
}

=head2 findany(layout => $layout, params => { parameters }, nocheck => 1)

Returns a hashref of random rows on a specific database and layout.

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

	my $xml = $self->_request(
			resultset => $self->{resultset}, 
			user 	  => $self->{user}, 
			pass 	  => $self->{pass}, 
			query	  => '-findany',
			params    => $params
	);

	return $xml;
}

=head2 total_rows(layout => $layout)

Returns a scalar with the total rows for a given layout.

=cut

sub total_rows
{
	my($self, %args) = @_;

	# Just do a findall with 1 record and parse the result. This might break on an empty database.
	my $xml = $self->_request(
		resultset => $self->{resultset},
		params    => {'-db' => $self->{db}, '-lay' => $args{layout}, '-max' => '1' },
		query 	  => '-findall'
	);

	return $xml;
}


1; # End of Net::FileMaker::XML::Database;

