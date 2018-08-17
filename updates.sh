#!/bin/bash

#Vars

TEMPDIR=/scripts/temp
PIDIR=/etc/pihole

#download files
function download()
{

	#adlists.list 
	wget -O $TEMPDIR/adlists.list 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/lists'

	# Regex Lists

	wget -O $TEMPDIR/regex.download 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/regex.list'
	wait
	wget -O $TEMPDIR/regex.country 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/country_regex'
	wait
	wget -O $TEMPDIR/regex.oTLD 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/oTLD_regex'
	wait
	wget -O $TEMPDIR/regex.uslocal 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/uslocal'
}

function modify()
{

	cat $TEMPDIR/regex.download $TEMPDIR/regex.country $TEMPDIR/regex.oTLD $TEMPDIR/regex.uslocal | grep -v '#' | sort | uniq > $TEMPDIR/regex.list
	wait
}


#move
function move()
{
	#adlists.list
	mv $TEMPDIR/adlists.list $PIDIR/adlists.list
	#Wildcards (03-pihole-wildcard.conf)
	mv $TEMPDIR/regex.list  $PIDIR/regex.list

}

#cleanup
function clean()
{
 rm -f $TEMPDIR/regex.download
 rm -f $TEMPDIR/regex.country
 rm -f $TEMPDIR/regex.oTLD
 rm -f $TEMPDIR/regex.uslocal
}

function scripts()
{
 bash /scripts/Finished/ListUpdater.sh
 wait
 killall -SIGHUP pihole-FTL
 wait
 pihole -g
}

download
modify
move
clean
scripts


