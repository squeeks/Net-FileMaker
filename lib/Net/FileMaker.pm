package Net::FileMaker;

use warnings;
use strict;

use 5.008;

use LWP::UserAgent;
use XML::Simple;
use URI::Escape;

=head1 NAME

Net::FileMaker - Interact with FileMaker Server

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

This package provides an interface to FileMaker Server's various APIs - Initially this is limited to the XML based API.

    use Net::FileMaker;

    my $fms = Net::FileMaker->new('http://fmserver', 'username', 'pass');
    
    my $dbs = $fms->get_databases;
    my $layouts = $fms->get_layouts('database');

    

=head1 METHODS

=head2 new($host,$user,$pass)

Creates a new object. Username and password are not mandatory if you're just planning on calling get_databases, 
else you'll be required to supply it pending the permissions of your setup.

B<NOTE:> This will most likely change in future versions.

=cut

sub new
{
	my($class, $host, $user, $pass) = @_;
	my $self = {
		host	=> $host,
		user	=> $user || undef,
		pass	=> $pass || undef,
		ua	=> LWP::UserAgent->new,
		
		# For now, using the resultset class would be the best idea as it's the most
		# flexible, but in the future we'll need to support at least layout set as well.
		resultset_path	=> '/fmi/xml/fmresultset.xml?',
	};

	return bless $self, $class;
}

=head2 get_databases()

Lists all XML enabled databases for a given host. This method is the only one that doesn't require 
authentication.

=cut

sub get_databases
{
	my $self = shift;
	my $res  = $self->_request('-dbnames');

	if($res->is_success)
	{
		my $xml = XMLin($res->content);
		return $xml->{resultset}->{record}->{field}->{data};
	}
	else
	{
		return undef;
	}
}

=head2 get_layouts($database)

Returns all layouts accessible for the respective database.

=cut

sub get_layouts
{
	my ($self, $database) = @_;
	my $res = $self->_request( '-db='.uri_escape_utf8($database).'&-layoutnames');

	if($res->is_success)
	{
		my $xml = XMLin($res->content);
		
		return $xml->{resultset}->{record};
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
	my $res   = $self->_request('-findall&-max=1&-db='.uri_escape_utf8($database)."&-lay=".uri_escape_utf8($layout));

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

=head2 find_all($database, $layout, %options)

Returns all rows on a specific database and layout.

=cut

sub find_all
{
	my ($self, $database, $layout, %attr) = @_;

	my $url = '-findall&-db=' . $database . '' . $layout;  # This could be done better...

	# Keys are just actual URL vars from the API minus the prefixing dash.
	# According to the documentation, that means all the options are:
	# –recid, –lop, –op, –max, –skip, –sortorder, –sortfield, –script, –script.prefind, –script.presort

	for my $var (keys %attr)
	{	
		$url .= sprintf('-%s=%s&', uri_escape_utf8($var), uri_escape_utf8($attr{$var}));
	}

	my $res = $self->_request($url);

	if($res->is_success)
	{
		my $xml = XMLin($res->content);

		return $xml->{resultset};
	}
	else
	{
		return undef;
	}


}


sub _request
{
	my ($self, $args) = @_;

	my $url = $self->{host}.$self->{resultset_path}.$args;

	my $req = HTTP::Request->new(GET => $url);

	if($self->{user} && $self->{pass})
	{
		$req->authorization_basic( $self->{user}, $self->{pass});
	}

	my $res = $self->{ua}->request($req);
	
	return $res;
}


=head1 AUTHOR

Squeeks, C<< <squeek at cpan.org> >>

=head1 BUGS

This distrobution is in it's early stages and B<things will be prone to breaking and changing in future versions>. 
Please keep an eye out on the change log and the documentation of new releases before submitting bug reports.

Please report any bugs or feature requests to C<bug-net::filemaker at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net::FileMaker>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes. Please ensure to include the version of FileMaker Server 
in your report.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::FileMaker


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net::FileMaker>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net::FileMaker>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net::FileMaker>

=item * Search CPAN

L<http://search.cpan.org/dist/Net::FileMaker/>

=back

=head1 DEVELOPMENT

Everyone is welcome to help towards the project with bugfixes, feature requests or contributions. 
You'll find the git repository for this project is located at L<http://github.com/squeeks/Net-FileMaker>.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Squeeks.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Net::FileMaker
