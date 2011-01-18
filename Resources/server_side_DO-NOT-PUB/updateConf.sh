 #!/usr/bin/bash

# make sure we're running as root:
if [[ $(/usr/bin/id -u) -eq 0 ]]; then
		echo "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "   ! DO NOT RUN THIS SCRIPT AS SUPER USER !"
		echo "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "   (not doing anything and aborting)"
		echo ""
		echo "                                      anything that requires a SUDO "
		echo "		                       will be asked for as-needed"
		echo "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit
fi









# make a list of all the commands that we use in the script here:
#		then, test for them on the executing computer 
#		BEFORE we try anything 
#		this ensures we won't start anything we can't finish :)
REQS="apachectl grep perl cp sed tr rm"
for X in $REQS
do
	if [ -z "`which $X`" ] ; then
		echo "This script requires the application: '$X'."
		echo "Please install it then sudo-run this script again"
		exit
	fi
done

# the TMP vars!
TMPDIR="/tmp/iTunesRemote"
TODAY="`date +%Y-%m-%d`"
if [ ! -d "$TMPDIR" ] ; then
	mkdir "$TMPDIR"
fi
TMP="$TMPDIR/$TODAY.tmp"

# find what file the apache process is using for its conf file
# to do this, we grep the output of the -V option (-V = dump apache server compile info)
# 	then we scrub off the crap we don't need
apachectl -V | grep SERVER_CONFIG_FILE > $TMP
CONF_IN=`perl -ne '/"([^"]*)"/; print $1;' ${TMP}`

# test to make sure we didn't get any false positives on the conf file
#		is the filename non-empty? AND does the file exist? AND is the file's size > 0?
if [ -n "$CONF_IN" -a -a $CONF_IN -a -s $CONF_IN ] ; then
	echo "   - APACHE conf file detected:"
	echo "      conf file: $CONF_IN"
else
	echo "   No APACHE conf file detected."
	echo "   Open System Preferences > Sharing and turn on web sharing"
	exit
fi

# some more vars:
CONF_ORIG="$CONF_IN.$TODAY.BAK"
CONF_NEW="$TMPDIR/httpd.conf"
CONF_TMP1="$TMPDIR/httpd.conf.1.tmp"
CONF_TMP2="$TMPDIR/httpd.conf.2.tmp"


# backup the conf file, just in case
echo "   - Backing up original conf file... (sudo)"
echo "      backup: $CONF_ORIG"
sudo cp $CONF_IN $CONF_ORIG

# first, update the conf file to use the current user of the system
# 	please excuse the crazy hack to comment the old line and add the new one below it:
# 	sed doesn't do '\n' characters :(
	# 1st, replace the User line
	sed s/User\ www/#User\ www˜User\ `whoami`/ < $CONF_IN > $CONF_TMP1
	# 2nd, replace the Group line
	sed s/Group\ www/#Group\ www˜Group\ staff/ < $CONF_TMP1 > $CONF_TMP2
	# last, go back and add newline characters where we used tildas
	tr "˜" "\n" < $CONF_TMP2 > $CONF_NEW
echo "   - Replaced user/group values with current user: "


echo "replacing old conf file with updated version.... (sudo)"
sudo rm $CONF_IN
sudo cp $CONF_NEW $CONF_IN


echo "restarting the webserver.... (sudo)"
sudo apachectl -k graceful

rm -r $TMPDIR
echo "   - removed tmp files"