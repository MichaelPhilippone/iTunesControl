/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **  */
/**	GLOBAL VARS */
var CmdCats = {"ARTIST":true,"TITLE":true,"ALBUM":true,"VOLUME":true};

var Cmds = {"play":">","pause":"#","next":"-->","previous":"<--","volup":"Vol +","voldown":"Vol -"};
/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **  */
/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **  */

/**	fill in the song data on the page if the necessary 
		info has been passed to the client via PHP */
songDataRefresh=null;
songDataRefreshIX=0;
function fillSongData(data) {
		
	if(!!!data || !!!(data.TITLE || data.ARTIST || data.ALBUM || data.VOLUME)) {
		$('title').each(function(i,t){ $(t).html("Control iTunes"); });
		$('#songDataContainer').empty();
		clearInterval(songDataRefresh);
		return;
	}
	
	/* change page title: */
	$('title').each(function(i,t){ $(t).html( data["TITLE"] + " - " + data["ARTIST"]); });

	/* clear out, then re-populate the song data on the page: */
	$('#songDataContainer').empty();
	for( var x in CmdCats ) { if(!CmdCats[x]) continue;
		$('#songDataContainer')
			.append(
				$('<div/>')
					.addClass('dataName')
					.html(x+':'))
			.append(
				$('<div/>')
					.addClass('songData')
					.html( data[x] ))
			.append( $(document.createElement('br')).addClass('clear') );
	}

	
	if( !!!songDataRefresh ) 
		songDataRefresh = setInterval( function(){ fillSongData( window.songData ); } , 5*1000);

}
/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **  */

/**	once the page has loaded, assign all the pertinent JS actions 
			PARAM target					-	the element to fill in
			PARAM submissionType	-	GET or POST			
*/
function fillInControls( target , submissionType ){
	submissionType =  submissionType.toLowerCase(); 
 
	$('#'+target).addClass('controller box');

	var $ctrls = 
		$('#'+target)
			.append( $('<div/>') );
			
	for( var cmdType in Cmds ) {  
		var cmd = cmdType;
		if(!!Cmds[cmdType] && Cmds[cmdType] != "") 
			cmd = Cmds[cmdType];
		
		$ctrls
			.append( 
				$('<img/>')
					.attr('id','formSubmit_manual_'+cmdType+'-'+ submissionType)
					.attr('name' , cmdType )
					.attr('title' , cmdType )
					.attr('src' , 'img/'+ cmdType +'.png' )
					.attr('alt' , cmdType )
					.click(function(e) {
						if( submissionType == 'get' ) {
							location.href= location.href + "?command=" + e.target.value ;
						} else if ( submissionType == 'post' ) {
							$('#command').attr('value', e.target.value ); 
							$('#POST_form').submit();
						} else if ( submissionType == 'ajax' ) {
							var now = new Date().getTime().toString();
							var val = e.target.name;
							flashMessage( val );
							$.post(
								"control.php"
								, { "ajax":true
										, "cachebust": now
										, "command": val }
								, function( response , status , xhr ) { // response callback
										try {
											window.songData = JSON.parse(response);
										} catch(err) { 
											window.songData = response;
										}
										fillSongData( window.songData );
								});
						}
					})
				);
	}
	
	$('#'+target).append( $('<br/>') );
}
/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **  */

/**	once the page has loaded, assign all the pertinent JS actions */
$('body').ready(function(e_TOP){

	/* fill in controller buttones where necessary: */
	fillInControls( 'AJAX_controls' , 'AJAX' );

	/* populate song data through page, then set it up to keep populating every 5 secs */
	fillSongData( window.songData );
	
});