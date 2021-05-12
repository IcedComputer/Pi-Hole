## Created 25 July 2020
## Updated 12 May 2021
## refresh.sh
## This script simply updates the "updates.sh" script to ensure the local copy on the machine is up to date
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
	curl --tlsv1.2 -o $TEMPDIR/updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/updates.sh'
	
	## download an updated ListUpdater
	curl --tlsv1.2 -o $TEMPDIR/ListUpdater.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ListUpdater.sh'
	
	## download an updated DB_updates.sh
	curl --tlsv1.2 -o $TEMPDIR/DB_Updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/DB_Updates.sh'
}


#move
function move()
{

	## change permisions
	chmod 777 $TEMPDIR/updates.sh
	mv $TEMPDIR/updates.sh $FINISHED/updates.sh
	
	chmod 777 $TEMPDIR/ListUpdater.sh
	mv $TEMPDIR/ListUpdater.sh $FINISHED/ListUpdater.sh
	
	chmod 777 $TEMPDIR/DB_Updates.sh
	mv $TEMPDIR/DB_Updates.sh $FINISHED/DB_Updates.sh
}

download
move
