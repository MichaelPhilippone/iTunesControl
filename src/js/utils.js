/* --------------------------------------------- */

/** */
function activateiTunes() {
	
	flashMessage('Pop Out');

	var url = "control.php"
	if (!!localStorage["options"] 
				&& !!JSON.parse(localStorage["options"]) 
				&& !!JSON.parse(localStorage["options"])["Control URL"] 
				&& JSON.parse(localStorage["options"])["Control URL"]["value"])
	{
		url = JSON.parse( localStorage["options"] )["Control URL"]["value"];
	}
	$.post(	url
					, { "ajax":true
							, "cachebust": (new Date().getTime().toString())
							, "command": "activate" }
					, function( response , status , xhr ) { // response callback
							localStorage["songData"] = response;
							try {
								window.songData = JSON.parse(localStorage["songData"]);
							} catch(err) { 
								window.songData = localStorage["songData"];
							}
		}); // end ajax
}
/* --------------------------------------------- */

/** */ 
function getSongData(txt) {
	/* make an initial call to get a song's info */
	var url = "songinfo.php"
	if (!!localStorage["options"] 
				&& !!JSON.parse(localStorage["options"]) 
				&& !!JSON.parse(localStorage["options"])["Info URL"] 
				&& JSON.parse(localStorage["options"])["Info URL"]["value"])
	{
		url = JSON.parse( localStorage["options"] )["Info URL"]["value"];
	}
	
	$.post(	url
					, { "ajax":true , "cachebust": (new Date().getTime().toString()) , "command": "info" }
					, function( response , status , xhr ) { // response callback
							localStorage["songData"] = response;
							try{
								window.songData = JSON.parse(localStorage["songData"]);
							} catch(err) { 
								window.songData = response;
							}
							fillSongData( window.songData );
					});
}
/* ------------------------------------------------------------------------------- */

/**	fill in the volume gradation on the UI 
			PARAMS
				level	-	the (out-of-100) value of the volume level
*/
function fillInVolume(level) {
	vols={"up":"","down":""};
	for( var vol in vols ) 
	{
		if( $('#vol'+vol+'_btn') && $('#vol'+vol+'_mask') && $('#vol'+vol+'_container') ) {			
			var hght = $('#volup_btn').height();
			var wdth = $('#volup_btn').width();
			
			$('#vol'+vol+'_container').width( wdth );
			$('#vol'+vol+'_container').height( hght );
			
			$('#vol'+vol+'_mask').width( wdth-4 )
			$('#vol'+vol+'_mask').height( hght )
			
			$('#vol'+vol+'_mask').css( 'top' , (-1*((level*hght)/100)) )
			
			$('#vol'+vol+'_mask').show();
		}
		else { 
			console.log( "No vol"+vol+" btn found"); 
		}
	}
}
/* --------------------------------------------- */

/**	fill in the song data on the page if the necessary 
		info has been passed to the client via PHP */
songDataRefresh=null;
function fillSongData(data) {

	if( !!!data ) return;
	
	if( data.DURATION ) {
		data['DURATION'] = ((data['DURATION'].match(/[\d]\:[\d]$/)) ? (data['DURATION'].replace(":",":0")) : (data['DURATION']));
	}
	if( data.POSITION ) {
		data['POSITION'] = ((data['POSITION'].match(/[\d]\:[\d]$/)) ? (data['POSITION'].replace(":",":0")) : (data['POSITION']));
	}
				
	if(!!!data || !!!(data.TITLE || data.ARTIST || data.ALBUM || data.VOLUME)) {
		if( $('title') ) {
			$('title').each(function(i,t){ $(t).html("Control iTunes"); });
		}
		$('#songInfo').hide();
		$('#songDataContainer').empty();
		clearInterval(songDataRefresh);
		return;
	}
	else {
		$('#songInfo').show();
	}	
	
	/* change page title: */
	if( $('title') ) {
		$('title').each(function(i,t){ $(t).html( data["TITLE"] + " - " + data["ARTIST"]); });
	}
	
	/* build progress bar... */
	$('#songDataProgBarMask').width(((data['PERCENT'] * $('#songDataProgBar').width())/100) );
	
		/* fill in prog bar metadata */
	$('#songDataProgBarPercent').html( data['PERCENT'] + "%" );
	$('#songDataProgBarInfo')
		.html( data['POSITION'] + ' / ' + data['DURATION'] );
	
	/* fill in volume info */
	fillInVolume( data['VOLUME']);
	
	if (!!localStorage["options"] 
			&& !!JSON.parse(localStorage["options"]) 
			&& !!JSON.parse(localStorage["options"])["Show Percentage"] 
			&& JSON.parse(localStorage["options"])["Show Percentage"]["checked"]) 
	{
		$('#songDataProgBarMask').html( data['PERCENT'] + "%" );
	}
		
	/* clear out the song data container */
	$('#songDataContainer').empty();
	
	/* re-populate the song data on the page: */
	for( var cmd in CmdCats ) { 
		if(!CmdCats[cmd]) {
			continue;
		}
		
		if( data[cmd] != '' ) {
			$('#songDataContainer')
				.append(
					$('<div/>')
						.addClass('dataName')
						.addClass('left')
						.html(cmd+':'))
				.append(
					$('<div/>')
						.addClass('songData')
						.addClass('left')
						.html( /* get the songs with no seconds in duration (#:0) to look like "#:00" */ 
							(data[cmd].match(/[\d]*:0$/)) ? 
								(data[cmd]+'0') : 
								(data[cmd]) ))
				.append( $(document.createElement('br')).addClass('clear') );
		}
	}
		
	if( !!!songDataRefresh ) {
		songDataRefresh = setInterval( getSongData , 1*1000);
	}
}