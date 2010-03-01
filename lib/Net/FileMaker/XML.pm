package Net::FileMaker::XML;

use strict;
use warnings;

use XML::Simple;

=head1 NAME

Net::FileMaker::XML - Interact with FileMaker XML Interface.

=head1 VERSION

Version 0.05 - Developer release 1

=cut

our $VERSION = 0.05_01;

=head1 SYNOPSIS

There is no need to call this module directly, you can simply invoke L<Net::FileMaker> directly and specify the 'type' 
key in the constructor as "xml", although this is not enforced.

    use Net::FileMaker;

    my $fms = Net::FileMaker->new(host => $host, type => 'xml');
    my $dbnames = $fms->dbnames;
    my $fmdb = $fms->database();

=head1 METHODS

=cut

sub new
{
	my($class, $host, $db, $user, $pass) = @_;
	my $self = {
			host => $host,
			ua   => LWP::UserAgent->new
		};

	return bless $self;

}

=head2 database(db => $database, user => $user, pass => $pass)

Initiates a new database object for querying data in the databse.

=cut

sub database
{
	my($self, $host, %args) = @_;

	require Net::FileMaker::XML::Database;
	return  Net::FileMaker::XML::Database->new(
			host => $host,
			db   => $args{db},
			user => $args{user} || '',
			pass => $args{pass} || ''
		);
}

#
#	TODO: Put in the bits to handle layouts.
#

=head2 dbnames

Lists all XML/XSLT enabled databases for a given host. This method requires no authentication.

=cut

sub dbnames
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


# FIXME FIXME FIXME FIXME
#TODO: This method needs to do the XML parsing for us...
#TODO: before that, it needs to handle errors for us as well.
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

1; # End of Net::FileMaker::XML;