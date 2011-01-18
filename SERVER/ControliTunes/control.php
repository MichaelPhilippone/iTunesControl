<? 
include('globals.php');
include('functions.php');

/* get the command string */
if( isset($command) ) 
	passMessage( $command );			

/* if we are 'looking' at the page via and AJAX request, 
	then just print out the JSON and stop rendering */
if($AJAX) { 
	displayCurrentsongInfo();
	die();
}
else if( isset($REDIRECT) && $REDIRECT != "") {
	echo "<script type='text/javascript'>location.href='$REDIRECT';</script>";
	echo "<noscript>";
	echo "Please follow the link if your browser does not automatically redirect you:";
	echo "<a href='$REDIRECT'>$REDIRECT</a>";
	echo "</noscript>";
}
else {
	echo "ERROR<br/>No redirect URL specified";
}
?>