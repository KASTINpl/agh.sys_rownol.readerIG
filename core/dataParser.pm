#!/usr/bin/perl -w

##
# 
# LOG:
# 
package dataParser;

use JSON;
use MIME::Base64;
use Scalar::Util qw(looks_like_number);
use Exporter;
use vars qw($VERSION @ISA @EXPORT);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();

##
# __construct()
sub new {
	$class = shift;
	$self = {};
	bless $self, $class;
	return $self;
}

## parse input
# @return hash array of modules
sub encodeData {
	( $self, $data ) = @_;
	@modules = split "\n\n", $data;
	%mR = {};
	foreach $m (@modules) {
		@tmpLines = split "\n", $m; $modsValues = scalar(@tmpLines)-1;
		%tmpParam = {}; %tmpRow = {};

		for ($i=1;$i<$modsValues;$i+=2) {
			$tmpLines[$i] =~ s/^\s+|\s+$//g;
			$tmpRow{ $tmpLines[$i] } = decode_json( $tmpLines[$i+1] );
		}
		
		$tmpLines[0] =~ s/^\s+|\s+$//g;
		$mR{ $tmpLines[0] } = {%tmpRow};
	}
	return %mR;
} #---

## generate output
sub decodeData {
	( $self, $name, $status, $data ) = @_;
	return "$name\n$status\n$data\n\n";
} #---

## parse value to {type, content} mode, next do JSON encoding
sub prepareData {
	( $self, $data ) = @_;
	%r = ();
	foreach $k ( keys %$data ) {
		if ( ! length $data->{$k} ) { next; }
		if ( looks_like_number($data->{$k}) ) {
			$r{$k} = $self->encodeDefault( $data->{$k} );
		} else {
			$r{$k} = $self->encodeString( $data->{$k} );
		}
	}
	return encode_json(\%r);
} #---


sub encodeDefault {
	( $self, $content ) = @_;
	return {'type'=>'none','content'=>$content};
} #---
sub encodeString {
	( $self, $content ) = @_;
	return {'type'=>'base64','content'=>encode_base64($content)}; #encode_base64
} #---

sub decodeValue {
	( $self, $param ) = @_;
	$rV = "";
	if ( $param->{'type'} eq "base64" ) { $rV = decode_base64($param->{'content'}); }
	else { $rV = $param->{'content'}; }
	return $rV;
} #---

##
sub array_uniqe {
	( $self, $arr ) = @_;
	return keys %{{ map { $_ => 1 } @$arr }};
} #---
1;
