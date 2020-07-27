## Last Updated 27 July 2020
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
 wait
 apt autoremove -y
 wait
}

#download files
function download()
{

	#adlists.list 
	curl -o $TEMPDIR/adlists.list 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/adlists/main.adlist.list'

	# Regex Lists
	curl -o $TEMPDIR/main.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Regex%20Files/main.regex'
	wait
	curl -o $TEMPDIR/country.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Regex%20Files/country.regex'
	wait
	curl -o $TEMPDIR/oTLD.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Regex%20Files/oTLD.regex'
	wait
	curl -o $TEMPDIR/uslocal.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Regex%20Files/uslocal.regex'
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
	curl -o $TEMPDIR/basic.allow.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Allow%20Lists/basic.allow'
	wait
	curl -o $TEMPDIR/adlist.allow.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Allow%20Lists/adlist.allow'
	#On System
	cp $PIDIR/whitelist.txt $TEMPDIR/current.wl.temp
	
	#Private
	#curl -o $TEMPDIR/encrypt.allow.temp.gpg 'https://github.com/IcedComputer/Personal-Pi-Hole-configs/raw/master/Allow%20Lists/encrypt.allow.gpg'
	
	#decrypt Private list
	#gpg $TEMPDIR/encrypt.allow.temp.gpg

	##make whitelist
	#cat $TEMPDIR/current.wl.temp $TEMPDIR/basic.allow.temp $TEMPDIR/adlist.allow.temp $TEMPDIR/encrypt.allow.temp | sort | uniq > $TEMPDIR/final.wl.temp
	cat $TEMPDIR/current.wl.temp $TEMPDIR/basic.allow.temp $TEMPDIR/adlist.allow.temp | sort | uniq > $TEMPDIR/final.wl.temp
	mv $TEMPDIR/final.wl.temp $PIDIR/whitelist.txt


}

#cleanup
function clean()
{
 rm -f $TEMPDIR/*.regex
 rm -f $TEMPDIR/*.temp
 rm -f $TEMPDIR/*.gpg
 sudo systemctl restart cloudflared
}

base
download
modify
move
allowlist
scripts
clean