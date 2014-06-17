#!/usr/bin/perl -w

##
# 
# LOG:
# 
package makeStatusData;

#use List::Util qw( min max );
use Exporter;
use vars qw($VERSION @ISA @EXPORT);

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
	 'dataParser' => undef,
	 'configData' => undef
	};
	bless $self, $class;
	return $self;
}

sub setConfigData {
	( $self, $configData ) = @_;
	$self->{'configData'} = $configData;
}
sub setDataParser {
	( $self, $dataParser ) = @_;
	$self->{'dataParser'} = $dataParser;
}

## out string
sub getData {
	( $self ) = @_;
	%dataHash = ($self->makeMaminfo(), $self->makeLoad());
	$json_data = $self->{'dataParser'}->prepareData( \%dataHash ); # 
	return $self->{'dataParser'}->decodeData('statusData', $self->getModuleMessage(), $json_data );
} #---

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


##
# all meminfo data from /proc/meminfo
# @return hash array
sub makeMaminfo {
	$memInfoString = `cat /proc/meminfo`;
	%miR;

	if ( length $memInfoString ) {
	@procmeminfo = split(/\n/, $memInfoString);

	foreach $v (@procmeminfo) { 
		$klucz = $v; $klucz =~ s/:.*$//;
		$wartosc = $v; $wartosc =~ m/\s([0-9]{1,})\s/; $wartosc = $1;
		$miR{$klucz} = $wartosc;
	}
	} else { $self->setError(101, 'Can not read /proc/meminfo'); }

	return %miR;
} #--

##
# get load from 'uptime'
# @return hash array: loads
sub makeLoad {
	( $self ) = @_;
	%lR; $uptimeString = `uptime`;
	if ( $uptimeString =~ /load\ average\:\s*([0-9\,\.\ ]+)\s*/i ) { $uptimeString=$1; }

	if ( length $uptimeString ) {
	@uptime = split /\, /, $uptimeString;
	
	$lR{'load1'} = @uptime[0]; $lR{'load1'} =~ s/\,/\./; $lR{'load1'} =~ s/[^0-9\.]/ /;
	$lR{'load2'} = @uptime[1]; $lR{'load2'} =~ s/\,/\./; $lR{'load2'} =~ s/[^0-9\.]/ /;
	$lR{'load3'} = @uptime[2]; $lR{'load3'} =~ s/\,/\./; $lR{'load3'} =~ s/[^0-9\.]/ /;
	} else { $self->setError(201, 'Can not run uptime'); } 

	return %lR;
} #--




1;
