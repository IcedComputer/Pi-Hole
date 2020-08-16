## Created 25 July 2020
## Updated 15 Aug 2020
## security_refresh.sh
## This script simply updates the "security_updates.sh" script to ensure the local copy on the machine is up to date
##



#!/bin/bash

#Vars
FINISHED=/scripts/Finished
TEMPDIR=/scripts/temp
#CONFIG=/scripts/Finished/CONFIG

#download files
function download()
{

	#download an updated update.sh
	curl -o $TEMPDIR/security_updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/security_updates.sh'
	
	# download an updated ListUpdater
	curl -o $TEMPDIR/ListUpdater.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ListUpdater.sh'
}


#move
function move()
{

	## change permisions
	chmod 777 $TEMPDIR/security_updates.sh
	mv $TEMPDIR/security_updates.sh $FINISHED/security_updates.sh
	
	chmod 777 $TEMPDIR/ListUpdater.sh
	mv $TEMPDIR/ListUpdater.sh $FINISHED/ListUpdater.sh
}

download
move
