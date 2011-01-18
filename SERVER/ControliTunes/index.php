<html>
<head>
	<title>Control iTunes</title>
	<link href="/favicon.ico" rel="shortcut icon" />
	<script type="text/javascript" src="js/jquery-1.4.4.min.js"></script>
	<script type="text/javascript" src="js/flashMessage.js"></script>
	<script type="text/javascript" src="js/iTunesCtrl.js"></script>
	<script type="text/javascript" src="js/index.js"></script>
	
	<link href="css/styles.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<? displayCurrentsongInfo(); ?>
	
	<div id="GET_controls"></div>
	
	<form method="post" action="<? echo $_SERVER['SCRIPT_NAME'];?>" id="POST_form">
		<input id="command" type="hidden" name="command" value="" />
		<div id="POST_controls"></div>
	</form>

	<div id="AJAX_controls"></div>
	
	
	<div class="clear"></div>
	<br/>
	<!-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** -->
	<div class="yellow_roundedcornr_box" id="messages">
		<div class="yellow_roundedcornr_top"><div></div></div>
		<div class="yellow_roundedcornr_content">
			<div id="messages_content">&nbsp;</div>
		</div>
		<div class="yellow_roundedcornr_bottom"><div></div></div>
	</div>
	<div class="clear"></div>
	<!-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** -->
	
	
	<div id="songDataContainer"></div>
	
</body>
</html>