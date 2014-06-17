#!/usr/bin/perl -w

##
# 
# LOG:
# 
package makeDomainData;

#use List::Util qw( min max );
use Exporter;
#use Async;
require "Async.pm";
use Time::HiRes qw(usleep nanosleep time gettimeofday);
use Data::Dumper;
use vars qw($VERSION @ISA @EXPORT);
use WWW::Curl::Easy;

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
	 'configData' => undef,
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
	%domainsReturnData = $self->runDomainDownloader();
	$json_data = $self->{'dataParser'}->prepareData( \%domainsReturnData ); # 
	return $self->{'dataParser'}->decodeData('domainData', $self->getModuleMessage(), $json_data );
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

sub runDomainDownloader {
	( $self ) = @_;

	if ( $self->{'configData'} != undef && length %$self->{'configData'}{'param'} ) { # what can I do
		$domainsToDo = scalar @{$self->{'configData'}{'param'}};
		%dDat = {};

		%threadsDomain = {};
		foreach $dV ( @{$self->{'configData'}{'param'}} ) {
			$threadsDomain{ $dV->{'domain'} } = Async->new(sub { $self->goDomain($dV); });
			# save all to $self->{'domainsReturn'}
			#async { ($o) = @_; $self->goDomain( $dV ); $dDat{ $dV->{'domain'} } = "ok"; };
		}

	# barrier + save result
	foreach $t (keys %threadsDomain) { #t
		if ( ! length $threadsDomain{$t} ) { next; }
		if ( $threadsDomain{$t}->ready ) { 
			if ($e = $threadsDomain{$t}->error) { $self->setError(201, $e);  }
			$dDat{ $t } = $threadsDomain{$t}->result;
			
		} else { usleep(100); redo; }
		
	} #t

	} else {   } # /* ok = no commands to do */

	return %dDat;
}

## get domain data by CURL
# @param $domainData {domain, script, lastID, type, url}
# @return string: http status \n time (or -1 if error) \n response CURL data "as is"
sub goDomain {
	( $self, $domainData ) = @_;
	$domain = $domainData->{'domain'};
	$script = $domainData->{'script'};
	$lastID = $domainData->{'lastID'};
	$type = $domainData->{'type'}; # not active! only json support
	$url = $domainData->{'url'}; # ends with "readerIG" dir

	$curl = new WWW::Curl::Easy;
	$response_body;
	$curl->setopt(CURLOPT_URL, $url . "getData.php?script=$script&lastID=$lastID&type=json");
        $curl->setopt(CURLOPT_WRITEDATA,\$response_body);

	$time_start = gettimeofday();
	$curl->perform;

	$time_do = gettimeofday()-$time_start;

	$err = $curl->errbuf;
	$httpCode = $curl->getinfo(CURLINFO_HTTP_CODE);

	return "$httpCode\n$time_do\n$response_body";

}

1;
