# iTunes Control 

## Chrome Extension

#### Author: Michael Philippone

#### Date: 2011-01-10

**Purpose**: Allow users to control iTunes from Chrome 

**Download**:
http://goo.gl/2jHUr
[Stable, via Chrome Web Store]

--------------------------------------------------------------------

#### Set-Up:
1. You'll need to set up your Mac (only OS X for now, sorry!) 
according to the configuration specified here: 
http://www.whatsmyip.org/itunesremote/

2. Once you have Apache set up to handle PHP requests and the
Apache conf edited to change the user/group, install the
collection of PHP and Apple- scripts located in the **SERVER**
directory be sure to drop the "ControliTunes" directory into your
root Apache service directory
		default: /Library/WebServer/Documents

3. After all is installed and prepared, just open
your web browser and point it to:
http://localhost/ControliTunes/
If the page that appears works, you're all ready to
use the chrome extension!
If not, see #4 below


4. Make sure the Options page for the extension has the correct
address for the computer you are trying to control
	* (**MUST** be on the same local network)	
	* **Fix it!**
		* Open the extension popup (click the icon in Chrome)
		* Click the "Options" link in the lower left corner
this should open the Options page for the iTunes Control extension
		* change the IP address in the EACH of the text boxes to your iTunes server
		* **MAKE SURE THE OPTION FIELDS LOOK LIKE THIS:**
				http://<YOUR COMPUTER IP HERE>/ControliTunes/control.php
				and
				http://<YOUR COMPUTER IP HERE>/ControliTunes/songinfo.php

4. If step (4) didn't help, make sure of a few things:
	* you followed the instructions here: http://www.whatsmyip.org/itunesremote/
	* you enabled Web service and PHP on your macintosh
	* you downloaded the PHP site locally to your computer
if all of the above have been completed, continue to #5

--------------------------------------------------------------------