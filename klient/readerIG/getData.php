<?php
/**
 * uruchomienie generatora - klasy dziedziczącej z Script.class.php;
 * przekazanie do generatora zmiennych środowiskowych:
 * "script" : nazwa klasy generatora, konieczna dziedziczenie ze Script!
 * "lastId" : id ostatniego elementu zwróconego w ostatniej udanej próbie. generator wyświetla tylko nowsze elementy
 * "type" : rodzaj wyniku: JSON , XML
 * 
 * sprawdzenie autoryzacji: user= "ig" pass= "readerIG1991"
 * 
 * struktura wyniku:
 * [ id : [integer:*], name : [base64:*], date : [timestamp:*], author : [base64:*], author_mail : [base64:*], link : [base64:*] ]
 * 
 * wywyłanie metody "getData()" generatora, która zwróci gotowy wynik do wyświetlenia
 * 
 * W PRZYPADKU JAKIEGOKOLWIEK BŁĘDU, WYNIK PODAWANY WG SCHEMATU:
 * error
 * error_code
 * error_message
 * 
 * POPRAWNY SCHEMAT DANYCH W PRZYPADKU BRAKU REKORDÓW - PUSTY WYNIK:
 * ok
 * 0
 * 
 * POPRAWNY SCHEMAT DANYCH W PRZYPADKU REKORDÓW:
 * ok
 * count
 * json_text
*/

// ===== PRE INIT =======
include('Script.class.php');
error_reporting(E_ERROR);
ini_set("display_errors", 1);

// ====== FUNCTIONS =======
function parseUrl($param) {
	return preg_replace('/([^a-z0-9\_]+)/i', '', urldecode($param) );
}
function errorData($errorCode, $errorMessage) {
	echo "error\n$errorCode\n$errorMessage";
	exit;
}
function checkAccess() {
	$user = parseUrl( ($_POST['user'])?$_POST['user']:$_GET['user'] );
	$pass = parseUrl( ($_POST['pass'])?$_POST['pass']:$_GET['pass'] );
	return ( $user == "ig" && $pass = "readerIG1991" );
}

// ====== AUTORYZACTION =======
if ( ! checkAccess() ) errorData(403, "PREMISSION DEINED");

// ====== $_GET =======
$script = 'Wordpress';
if ( !empty($_GET['script']) ) $script = parseUrl($_GET['script']);

$lastId = 0;
if ( !empty($_GET['lastId']) ) $lastId = parseUrl($_GET['lastId']);

$type = 'json';
if ( !empty($_GET['type']) ) $type = parseUrl($_GET['type']);

$showPath = false;
if ( !empty($_GET['showPath']) ) $showPath = boolval($_GET['showPath']);

$limit = 10;
$script_class = null;
// ===== CHECKER =======
if ( ! is_file("$script.class.php") ) errorData(100, "file $script.class.php not found");
include("$script.class.php");
if ( class_exists($script) ) {
	$script_class = new $script();
} else errorData(101, "file $script.class.php must contain $script class");
if ( ! is_subclass_of($script_class, 'Script') ) errorData(102, "$script class must extend Script");

// ===== INIT =======
$script_class->setLastId($lastId);
$script_class->setType($type);
$script_class->setLimit($limit);
$script_class->setShowPath($showPath);

// ===== RETURN DATA =======
print( $script_class->getData( $script_class->getResult() ) );

