/* --------------------------------------------- */
/** pop-up a message
			PARAM txt				-	the text for the message
			PARAM duration	-	how long (in seconds) the message should remaing visible */
flashInUse = null;
function flashMessage(txt , duration) {

	if( !!!$('#messages') ) { 
		alert('please make sure you have an HTML element with a "messages" ID');
		return;
	}

	/* make sure we only have AT MOST one flashMessage countdown at any given moment */
	clearTimeout(flashInUse);
	
	/* if nothing was given to flash, then hide the messages panel */	
	if( !!!txt ) {
		$('#messages').fadeTo(2000,0,function(){
			$('#messages_content').html('');
			$('#messages').hide();
		});
		return;
	}

	/* if something was given to flash, then show it and fade in the panel */
	$('#messages_content').html(txt);
	$('#messages').fadeTo(1,0,function(){
		$('#messages').show();
		$('#messages').fadeTo(2000,1,function(){ flashInUse=setTimeout(function(){ flashMessage(); }, (duration*1000) || 5000); });
	});
}