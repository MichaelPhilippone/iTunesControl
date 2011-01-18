
/* --------------------------------------------- */
/** load settings from JSON file using ajax call */
function initOptions() {
	$.ajax({	url: "settings.json?cachebust="+(new Date()).getTime().toString()
						, complete:function(xhr, status) {
								if(!!xhr.responseText) {
									localStorage["options"] = xhr.responseText;
									loadOptions(false);
								}}});
}

/* --------------------------------------------- */
/** load options from localStorage or call initOptions() if none are preset 
	PARAM - skipInit [boolean] - 
		should the initOptions() call be forced to NOT occurr
*/
function loadOptions( skipInit ) {
	console.log('LOAD OPTIONS');
	
	if(!!!localStorage['options'] && !!!skipInit) {
		initOptions();
		return;
	}

	var $ul = $(document.createElement('ul'));

	var options = JSON.parse( localStorage["options"] );
	
	if( !!options ) { 
		for( var optNm in options ) {
			var opt = options[optNm];
			opt.available = ((opt.available == undefined)?(true):(!!opt.available));
			if( !opt.available ) {
				continue;
			}
			var $li = $( document.createElement('li') );
			var $field = $( document.createElement('input') );
			var $lbl = $( document.createElement('label') );
			$lbl.addClass('cheat-left');
			$lbl.html('');
			for( var attr in opt) {
				$field.attr( attr , opt[attr] );
			}				
			if( opt.exclude ) {
				$field.attr('exclude', opt.exclude);
				$field.click(function(event) {
					if( $(event.currentTarget).is(':checked') ) {
						$('input[name='+$(event.currentTarget).attr('exclude')+']').attr('checked',false);
						flashMessage(
							'Please note, "'+ 
								$(event.currentTarget).attr('name') +'" excludes "'+ 
								$(event.currentTarget).attr('exclude') +'".' );
					}
				});
			}
			$field.attr('class', 'option' );
			$lbl.html( opt.name );
			$lbl.attr('for', (!!!opt.name)?('unspecified'):(opt.name) );
			$field.attr('length', 30 );
			$li.append( $field );
			$li.append( $lbl );			
			$ul.append( $li );
		}
	}
	if( $('#options') ) {
		$('#options').append( $ul );
	}
}

/* --------------------------------------------- */
/** saves all options present on the page into localStorage JSON string */
function saveOptions() {
	var optionsToSave = {};
	
	$('.option').each(function(i,opt){
		
		var saveMe={};
		$( $(opt)[0].attributes ).each(function(i,attr){
			saveMe[ attr.name ] = attr.value;
		});
		
		if( opt.type != 'checkbox') {
			saveMe['value'] = $(opt).attr('value');
		} else {
			saveMe['checked'] = $(opt).attr('checked');
		}
		optionsToSave[saveMe.name]= saveMe;
	});
	
	optionsToSave = JSON.stringify( optionsToSave );
	localStorage["options"] = optionsToSave;
	
	flashMessage('Settings Saved.');
}

/* --------------------------------------------- */
/** erases all options from localStorage JSON string, 
	* then reloads page to force initOptions() call 
	*/
function eraseOptions() {
	localStorage.removeItem( "options" );
	flashMessage('Settings Erased.<br/><small>(Defaults will be applied at next load)</small>');
	setTimeout(function(){ location.reload(); },2500);
}


/* ------------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------------ */
/** once the body element has loaded, load the options */
$('body').ready(function(e_TOP){ 
/* ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ */
	loadOptions();
	
	$('#saveOptionsBtn').click(function(){ saveOptions(); });
	$('#eraseOptionsBtn').click(function(){
		if( confirm('Are you sure?\n(This action will overwrite currenty settings)') ) {
			eraseOptions();
		}
	});
	
	$('body').fadeIn(1.5*1000,'linear',function(){});
/* ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ ++ */
});

/* ------------------------------------------------------------------------------------------ */
$(window).unload(function(e_TOP){  });