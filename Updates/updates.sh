## Last Updated 25 July 2020
## updates.sh
## This script is designed to keep the pihole updated and linked to any changes made
## This version is for the full blocking functionality
##



#!/bin/bash

#Vars
FINISHED=/scripts/Finished
TEMPDIR=/scripts/temp
PIDIR=/etc/pihole


#Based update and upgrade on the box
function base()
{
 apt-get update && apt-get dist-upgrade -y
}

#download files
function download()
{

	#adlists.list 
	curl -o $TEMPDIR/adlists.list 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/lists'

	# Regex Lists
	curl -o $TEMPDIR/main.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/regex.list'
	wait
	curl -o $TEMPDIR/country.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/country_regex'
	wait
	curl -o $TEMPDIR/oTLD.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/oTLD_regex'
	wait
	curl -o $TEMPDIR/uslocal.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/uslocal'
	wait
	
		
	#download new cloudflared configs
	curl -o $TEMPDIR/CFconfig 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFconfig'
	
	#download a new refresh.sh
	curl -o $TEMPDIR/refresh.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/refresh.sh'


}


function modify()
{
	## Create Regex 
	cat $TEMPDIR/main.regex $TEMPDIR/country.regex $TEMPDIR/oTLD.regex $TEMPDIR/uslocal.regex | grep -v '#' | sort | uniq > $TEMPDIR/regex.list
	wait
	
	#refresh.sh
	chmod 777 $TEMPDIR/refresh.sh
	
}


#move
function move()
{
	#adlists.list
	mv $TEMPDIR/adlists.list $PIDIR/adlists.list
	mv $TEMPDIR/regex.list  $PIDIR/regex.list
	mv $TEMPDIR/CFconfig $FINISHED/cloudflared
	mv $TEMPDIR/refresh.sh $FINISHED/refresh.sh
	
}


function scripts()
{
 bash $FINISHED/ListUpdater.sh
 wait
 killall -SIGHUP pihole-FTL
 wait
 pihole -g
}


function allowlist()
{
	##Get Whitelists
	#Public
	curl -o $TEMPDIR/basic.allow.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.txt'
	wait
	curl -o $TEMPDIR/adlist.allow.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/addlist_whitelist.txt'
	#On System
	cp $PIDIR/whitelist.txt $TEMPDIR/current.wl.temp
	
		#Private
		#curl -o $TEMPDIR/whitelist.encrypt..temp.gpg 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.encrypt'
	
		#decrypt Private list
		#gpg $TEMPDIR/whitelist.encrypt.temp.gpg

	##make whitelist
		#cat $TEMPDIR/current.wl.temp $TEMPDIR/basic.allow.temp $TEMPDIR/adlist.allow.temp $TEMPDIR/whitelist.encrypt.temp| sort | uniq > $TEMPDIR/final.wl.temp
	cat $TEMPDIR/current.wl.temp $TEMPDIR/basic.allow.temp $TEMPDIR/adlist.allow.temp | sort | uniq > $TEMPDIR/final.wl.temp
	mv $TEMPDIR/final.wl.temp $PIDIR/whitelist.txt


}

#cleanup
function clean()
{
 rm -f $TEMPDIR/*.regex
 rm -f $TEMPDIR/*.temp
 sudo systemctl restart cloudflared
}

base
download
modify
move
allowlist
scripts
clean