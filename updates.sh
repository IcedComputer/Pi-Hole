#!/bin/bash

#Vars

TEMPDIR=/scripts/temp
PIDIR=/etc/pihole

#download files
function download()
{

#adlists.list 
sudo wget -O $TEMPDIR/adlists.list 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/lists'

# Regex Lists

sudo wget -O $TEMPDIR/regex.download 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/regex.list'
wait
sudo wget -O $TEMPDIR/regex.country 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/country_regex'
wait
sudo wget -O $TEMPDIR/regex.oTLD 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/oTLD_regex'
wait
}

function modify()
{

sudo cat $TEMPDIR/regex.download $TEMPDIR/regex.country $TEMPDIR/regex.oTLD | grep -v '#' | sort | uniq > $TEMPDIR/regex.list
wait
}


#move
function move()
{
#adlists.list
sudo mv $TEMPDIR/adlists.list $PIDIR/adlists.list
#Wildcards (03-pihole-wildcard.conf)
sudo mv $TEMPDIR/regex.list  $PIDIR/regex.list

}

#cleanup
function clean()
{
sudo rm -f $TEMPDIR/regex.download
sudo rm -f $TEMPDIR/regex.country
sudo rm -f $TEMPDIR/regex.oTLD
}

function scripts()
{
sudo bash /scripts/Finished/ListUpdater.sh
wait
sudo killall -SIGHUP pihole-FTL
wait
sudo pihole -g
}

download
modify
move
clean
scripts


