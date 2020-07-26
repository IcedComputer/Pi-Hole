## Created 25 July 2020
## Updated 25 July 2020
## refresh.sh
## This script simply updates the "updates.sh" script to ensure the local copy on the machine is up to date
##



#!/bin/bash

#Vars
FINISHED=/scripts/Finished
TEMPDIR=/scripts/temp


#download files
function download()
{

	#download an updated update.sh
	curl -o $TEMPDIR/updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/updates.sh'
	
}


#move
function move()
{

	## change permisions
	chmod 777 $TEMPDIR/updates.sh
	mv $TEMPDIR/updates.sh $FINISHED/updates.sh
	
}

download
move
