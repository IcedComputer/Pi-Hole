## Created 25 July 2020
## Updated 25 July 2020
## security_refresh.sh
## This script simply updates the "security_updates.sh" script to ensure the local copy on the machine is up to date
##



#!/bin/bash

#Vars
FINISHED=/scripts/Finished
TEMPDIR=/scripts/temp


#download files
function download()
{

	#download an updated update.sh
	curl -o $TEMPDIR/security_updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/security_updates.sh'
	
}


#move
function move()
{

	## change permisions
	chmod 777 $TEMPDIR/security_updates.sh
	mv $TEMPDIR/security_updates.sh $FINISHED/security_updates.sh
	
}

download
move
