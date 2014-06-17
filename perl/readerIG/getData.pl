#!/usr/bin/perl

# run: ./getData.pl params: GET or POST:
# [login] = string: username
# [password] = string: plain text
# [configData] = mixed: "moduleName \n param \n {x:y} \n\n module2Name \n param \n {a:b} \n\n"
# 
#/********************** inicjalizacja **********************/
use DBI;
use CGI;
use JSON;
use CGI::Carp qw ( fatalsToBrowser );
use CGI::Cookie;
use Time::HiRes qw/ time gettimeofday /;
 use Data::Dumper;
require "dataParser.pm";
require "makeStatusData.pm";
require "makeDomainData.pm";

$cgi = new CGI;
$dataParser = new dataParser();

#/*************************** argumenty *************************/

$login = $cgi->param('login');
$haslo = $cgi->param('password');

%configData = $dataParser->encodeData( $cgi->param('configData') ); # POST
#/**********************/
$makeStatus = new makeStatusData();
$makeStatus->setConfigData( $configData{'statusData'} );
$makeStatus->setDataParser( $dataParser );

$makeDomain = new makeDomainData();
$makeDomain->setConfigData( $configData{'domainData'} );
$makeDomain->setDataParser( $dataParser );

#/**********************/
#$time_start = gettimeofday();
#$time_words = gettimeofday();
#printf "%.6f", $time_words-$time_start;

# ******************************************************

print $cgi->header('text/plain');
print $makeStatus->getData();
print $makeDomain->getData();

#$d = Data::Dumper->new([$configData{'domainData'}{'param'}]);
#$d->Purity(1);
#print $d->Dump;

