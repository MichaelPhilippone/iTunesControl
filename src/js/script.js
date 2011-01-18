/* ========================================================================================== */
/**	once the page has loaded, assign all the pertinent JS actions */
$('body').ready(function(e_TOP){
/* ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ */	
	
	fillInControls( 'controlPanel' );
	getSongData();
	$('#popOut').click(function(e_click){ activateiTunes(); });
	$('#pageIcon').attr( 'src' , chrome.extension.getURL('img/music.png') );
	$('#pageIcon').fadeIn(2000,'linear',function(){});
	$('#optionsOut').click(function(e_click){ 
		chrome.tabs.create( {url: chrome.extension.getURL('options.html') } ); 
	});
	$('html').height( $('body').height() + 30 );
	$('body').height( $('body').height() );
	$('body').fadeIn(1.5*1000,'linear', function(){} );
	
/* ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ */	
});


