#!/usr/bin/perl -w

package RolloutServer;

use strict;
use Net::Netmask;
use HTTP::Server::Simple::CGI;
use HTTP::Server::Simple::Static;
use File::Spec::Functions qw( canonpath );
use IO::Dir;
use URI::Escape;

use base qw( HTTP::Server::Simple::CGI );

sub new {
	my($class, $listen, $allow, $base) = @_;
	my $self = bless(new HTTP::Server::Simple::CGI, $class);

	$self->{base} = $base;

	$self->{allow} = [];
	foreach (split /,/, $allow)
	{
		my $net = new Net::Netmask $_;
		push @{$self->{allow}}, $net;
	}

	my($address, $port) = split /:/, $listen;
	$self->host($address);
	$self->port($port);

	return $self;
}


sub handle_request {
	my($self, $cgi) = @_;
	my $path = canonpath(uri_unescape($cgi->path_info()));

	printf STDERR "%s %s %s [%s] \"%s %s %s\" %s %s\n",
		$cgi->remote_host(), "-", "-", scalar(localtime()), $cgi->request_method(),
		$path, "HTTP/1.0", "200", 0;

	my $found = 0;
	foreach (@{$self->{allow}})
	{
		$found++ if $_->match($cgi->remote_host());
	}
	if (!$found || $path eq '/')
	{
		print "HTTP/1.0 403 Not Allowed\n\n";
		print "Not allowed to access $path\n";
	}

	my $localpath = $self->{base}. canonpath(uri_unescape($path));
	if (-d $localpath)
	{
		print "HTTP/1.0 200 OK\n";
		print "Content-Type: text/html\n\n";
		print "<html><body><h1>Directory Listing of $path</h1>\n";
		my $dir = new IO::Dir $localpath;
		foreach (sort $dir->read())
		{
			next if /^\./;
			$_ .= "/" if -d "$localpath/$_";
			print "<img src=\"file.jpg\" alt=\"file\"><a href=\"$_\">$_</a> <br>\n";
		}
		print "</body></html>\n";
		return;
	}

	if (!$self->serve_static($cgi, $self->{base}))
	{
		print "HTTP/1.0 404 Not Found\n\n";
		print "The file you requested was not found\n";
	}
}

1;
