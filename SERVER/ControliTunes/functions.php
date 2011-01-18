<? 
/* ================================================================================ */
function passMessage( $control ) {
	global $ScriptsPath, $AJAX;
	/* This is our rudimentary query string sanitizing:
		Basically, it is TERRIBLY UNSAFE to just pass a query string value directly 
		to a command line on the server, so to avoid that, we use the query string command
		and to signal which DIFFERENTLY-NAMED applescript to run */
	switch($control) {
		case "play":
			$scpName = $ScriptsPath . "PlayCurrentTrack.applescript";
		break;
		
		case "pause":
			$scpName = $ScriptsPath . "PauseCurrentTrack.applescript";
		break;
		
		case "next":
			$scpName = $ScriptsPath . "NextTrack.applescript";
		break;
		
		case "prev":
		case "previous":
			$scpName = $ScriptsPath . "PreviousTrack.applescript";
		break;
		
		case "volup":
			$scpName = $ScriptsPath . "VolumeUp.applescript";
		break;
		
		case "voldown":
			$scpName = $ScriptsPath . "VolumeDown.applescript";
		break;
		
		case "activate":
			$scpName = $ScriptsPath . "ActivateiTunes.applescript";
		break;
		
		case "info":
			// this query command only exists to get the playing info
			displayCurrentsongInfo();
			die();
		break;
		
		default:
			echo "INVALID QUERY PARAMETER.  ABORTING.";
			die();
		break;
	}
	exec("osascript $scpName");
	/* if the page is being called via AJAX, then we should NOT force the reload */
	if( !$AJAX )
		echo "<script>location.href ='{$_SERVER['SCRIPT_NAME']}';</script>";
}
/* ================================================================================ */

function displayCurrentsongInfo() {
	global $ScriptsPath, $AJAX;
	$scpName = $ScriptsPath .  "CurrentSongInfo.applescript";
	$results = exec("osascript $scpName");	
	if( $AJAX )
		echo $results."\n";
	else
		echo "<script> window.songData=" . (($results=="")?("null"):($results)) . "; </script>";
}
/* ===================================================================================== */
?>