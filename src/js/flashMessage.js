/* --------------------------------------------- */
/** pop-up a message
			PARAM txt				-	the text for the message
			PARAM duration	-	how long (in seconds) 
												the message should remaing visible */
flashInUse = null;
function flashMessage(txt , duration) {

	var $fm = $( '#flash_messages' );
	
	if( !!!$fm ) { 
		alert('please make sure you have an HTML element with a "messages" ID');
		return;
	}
	/* make sure we only have AT MOST one flashMessage 
			countdown at any given moment */
	clearTimeout(flashInUse);
	/* if nothing was given, then hide the messages panel */	
	if( !!!txt ) {
		$fm.fadeTo(2000,0,function(){
			$fm.html('');
			$fm.hide();
		});
		return;
	}
	/* if something was given, then show it and fade in the panel */
	$fm.html(txt);
	$fm.fadeTo(1,0,function(){
		$fm.show();
		$fm.fadeTo(2000,1,function(){ 
			flashInUse=setTimeout(function(){ 
				flashMessage(); 
			}, (duration*1000) || 5000); 
		});
	});
}
