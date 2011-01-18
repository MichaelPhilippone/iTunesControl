# iTunes Control 

## Chrome Extension

#### Author: Michael Philippone

#### Date: 2011-01-10

#### Purpose:
Allow users to control iTunes from Chrome 

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
your web browser and point it to
		http://localhost/ControliTunes/
If the page that appears controls iTunes, you're all ready to
use the chrome extension!

---

You can download a stable version from the Chrome Web Store: 
	http://goo.gl/2jHUr