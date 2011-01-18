<?
/* ================================================================================ */

/* TEST if this page's request includes an ajax signifier 
		in the GET or POST SuperGlobals: */
$AJAX = ( (isset($_GET['ajax']) && ( $_GET['ajax'] == 'true' || $_GET['ajax'] == true ))
				|| ( isset($_POST['ajax']) && ( $_POST['ajax'] == 'true' || $_POST['ajax'] == true ) ) );

/* ================================================================================ */

/* Get the value of the redirect param (if given): */
if ( isset($_GET['redirect']) && $_GET['redirect'] != '' ) {
		$REDIRECT = $_GET['redirect'];
} else if ( isset($_POST['redirect']) && $_POST['redirect'] != '' ) {
	$REDIRECT = $_POST['redirect'];
}

/* ================================================================================ */

/* set up the global var for where to run applescripts */
$ScriptsPath = "./applescripts/";

/* ================================================================================ */

/* was it a POST method or GET? */
if( isset($_GET['command']) ) 
	$command = $_GET['command'];
else if( isset($_POST['command']) )
	$command = $_POST['command'];
	
/* ================================================================================ */
?>