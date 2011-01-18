/* ************************************************************************************
 * 	OBJECT:		
 * 	AUTHOR:		Michael Philippone
 *	DATE:			05 JAN 2011
 *	UPDATED:	11 JAN 2011
 *	PURPOSE:	
************************************************************************************ */
/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **  */
/**	GLOBAL VARS */
var CmdCats = {"ARTIST":1,"TITLE":1,"ALBUM":1,"VOLUME":0,"POSITION":0,"DURATION":0,"PERCENT":0};
var Cmds = {"play":">","pause":"#","previous":"<--","next":"-->","volup":"Vol +","voldown":"Vol -"};
/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **  */
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
		if(!!Cmds[cmdType] && Cmds[cmdType] != "")  {
			cmd = Cmds[cmdType];
		}		
		$ctrls
			.append( 
				$('<div/>')
					.attr('id',cmdType+'_container')
					.addClass('cmdContainer')
					.addClass('left')
					.attr('title' , cmdType )
					.append(
						$('<img/>')			//img
							.attr('id' , cmdType+'_btn')
							.attr('name' , cmdType )
							.attr('title' , cmdType )
							.attr('src' , 'img/'+ cmdType +'.png' )	//img
							.attr('alt' , cmdType )									//img
							.click(function(e) {
								var val = e.target.name;
								flashMessage( val );
								$.post(	"control.php"
												, { "ajax":true
														, "cachebust": (new Date().getTime().toString())
														, "command": val }
												, function( response , status , xhr ) { // response callback
														localStorage["songData"] = response;
														try {
															window.songData = JSON.parse(localStorage["songData"]);
														} catch(err) { 
															window.songData = localStorage["songData"];
														}
														fillSongData( window.songData );
									}); // end ajax
							}) // end onClick
					) // end prepend
					.append(
						$('<div/>')
							.attr('id',cmdType+'_mask') 
							.addClass('cmdMask')
							.attr('title' , cmdType )
					) // end append mask
				); // end append container
	}
}

/* ================================================================================================ */
