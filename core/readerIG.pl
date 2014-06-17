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
require "reader.pm";

$cgi = new CGI;
$dataParser = new dataParser();
$reader = new reader();
$mysql = new mysql();
$reader->setDataParser( $dataParser );
$reader->setMysql( $mysql );

#/*************************** argumenty *************************/



# ******************************************************

print $cgi->header('text/plain');

# pobierz domeny, serwery
%domainss = $reader->getDomainList();
%serverss = $reader->getSerwerList();
@serversIds = keys %serverss;

# ustal zależności
%makeDependancy = $reader->makeDependancy(\@serversIds, \%domainss);

# wyślij zbiorcze zapytania do serwerów
foreach $sId (@serversIds) {
	if ( $serverss{$sId}{'domain'} eq "" ) { next; }
	print "perl(". $serverss{$sId}{'domain'} .", ". $serverss{$sId}{'url'} .");\n";
	print "DATA:".$reader->makeServerData($sId, \%makeDependancy, \%domainss)."\n\n";
}

# wyślij zapytanie każdorazowo do domen bez wsparcia "perl"
$it = 0;
foreach $dId (keys %makeDependancy) {
	if ( $makeDependancy{$dId} > 0 ) { next; }
	$reader->runDomain($domainss{$dId});
	if ($it>3) {last;}
++$it;
}

#print "\n\n".Dumper(\%serverss);
#$d = Data::Dumper->new([ $reader->getDomainList() ]);
#$d->Purity(1);
#print $d->Dump;

