#!/usr/bin/perl -w

##
# 
# LOG:
# 
package mysql;

use Exporter;
use Time::HiRes qw(usleep nanosleep time gettimeofday);
use Data::Dumper;
use vars qw($VERSION @ISA @EXPORT);
use DBI;

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();

##
# __construct()
sub new {
	$class = shift;
	$self = {
	 'errorCode' => 0,
	 'errorMessage' => '',
	 'dbh' => undef,
	
	 'db' => 'ig_panel',
	 'host' => 'localhost',
	 'user' => 'ig',
	 'pass' => 'santic86',
	};
	bless $self, $class;
	return $self;
}

sub isConnected {
	( $self ) = @_;
	return ( defined $self->{'dbh'} );
}

sub start {
	( $self ) = @_;
	$self->{'dbh'} = DBI->connect(
		"DBI:mysql:".$self->{'db'}.":".$self->{'host'}, 
		$self->{'user'},
		$self->{'pass'}, 
		{ PrintError  => 0 } 
	);
}

sub add {
	( $self, $table, $hash ) = @_;
	if ( ! $self->isConnected() ) { $self->start(); }

	@keys = keys %hash;
	@values = values %hash;

	$sth = $self->{'dbh'}->prepare("INSERT INTO $table(?) VALUES (?);");
	$sth->execute_array({},\@keys, \@values);
        $sqlQuery->finish;
}

sub runQuery {
	( $self, $q ) = @_;
	if ( ! $self->isConnected() ) { $self->start(); }

        $sqlQuery = $self->{'dbh'}->prepare($q);
        $sqlQuery->execute;
        if ($sqlQuery->errstr) { $self->setError(101, $sqlQuery->errstr); } # cos poszlo nietak
        else {
	       while ($row = $sqlQuery->fetchrow_hashref()) 
		{ push(@r, {%$row} ); }
        }
        $sqlQuery->finish;

	return @r;
}

sub koniec {
	( $self ) = @_;
	if ( $self->isConnected() )
	 { $self->{'dbh'}->disconnect; }
	$self->{'dbh'} = undef;
}


## set error message
sub setError {
	( $self, $errorCode, $errorMessage ) = @_;
	$self->{'errorCode'} = $errorCode;
	$self->{'errorMessage'} = $errorMessage;
}

## @return string ok|error|error message
sub getModuleMessage {
	( $self, $arr ) = @_;
	if ( $self->{'errorCode'} => 0 ) { return $self->{'errorMessage'}; }
	return 'ok';
} #---


1;
