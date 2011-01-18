/* ------------------------------------------------------------------------------- */
/** */ 
function getSongData() {
	/* make an initial call to get a song's info */
	$.post(	"songinfo.php"
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
/* ------------------------------------------------------------------------------- */

/**	fill in the song data on the page if the necessary 
		info has been passed to the client via PHP */
songDataRefresh=null;
function fillSongData(data) {
		
	if(!!!data || !!!(data.TITLE || data.ARTIST || data.ALBUM || data.VOLUME)) {
		if( $('title') ) {
			$('title').each(function(i,t){ $(t).html("Control iTunes"); });
		}
		$('#songDataContainer').empty();
		clearInterval(songDataRefresh);
		return;
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
		.html( 
			((data['POSITION'].match(/[\d]\:[\d]$/)) ? 
				(data['POSITION'].replace(":",":0")) : 
				(data['POSITION'])) 
			+ ' / ' 
			+ data['DURATION'] 
		);
	
	/* fill in volume info */
	fillInVolume( data['VOLUME']);
		
	/* clear out the song data container */
	$('#songDataContainer').empty();
	
	/* re-populate the song data on the page: */
	for( var x in CmdCats ) { 
		if(!CmdCats[x]) {
			continue;
		}
		
		$('#songDataContainer')
			.append(
				$('<div/>')
					.addClass('dataName')
					.addClass('left')
					.html(x+':'))
			.append(
				$('<div/>')
					.addClass('songData')
					.addClass('left')
					.html( /* get the songs with no seconds in duration (#:0) to look like "#:00" */ 
						(data[x].match(/[\d]*:0$/)) ? 
							(data[x]+'0') : 
							(data[x]) ))
			.append( 
				$('<div/>')
					.addClass('clear') );
	}
		
	if( !!!songDataRefresh ) {
		songDataRefresh = setInterval( getSongData , 1*1000);
	}
}
/* ------------------------------------------------------------------------------- */