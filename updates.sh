#!/bin/bash

## Updated 17 June 2020

#Vars
FINISHED=/scripts/Finished
TEMPDIR=/scripts/temp
PIDIR=/etc/pihole

#download files
function download()
{

	#adlists.list 
	curl -o $TEMPDIR/adlists.list 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/lists'

	# Regex Lists
	curl -o $TEMPDIR/regex.download 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/regex.list'
	wait
	curl -o $TEMPDIR/regex.country 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/country_regex'
	wait
	curl -o $TEMPDIR/regex.oTLD 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/oTLD_regex'
	wait
	curl -o $TEMPDIR/regex.uslocal 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/uslocal'
	wait
	
	#download an updated update.sh, but keep in temp
	curl -o $TEMPDIR/updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/updates.sh'
	
	#download new cloudflared configs
	curl -o $TEMPDIR/CFconfig 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFconfig'
	

}

function download_additional()
{
	#for v5
	
	# Get Updaters
	curl -o $FINISHED/regex_db_updater.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Version%205%20Updaters/regex_db_updater.sh'
	wait
	curl -o $FINISHED/whitelist_db_update.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Version%205%20Updaters/whitelist_db_update.sh'
	wait
	curl -o $FINISHED/adlists.sql 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Version%205%20Updaters/adlists.sql'
	wait
}

function modify()
{
	## Create Regex 
	cat $TEMPDIR/regex.download $TEMPDIR/regex.country $TEMPDIR/regex.oTLD $TEMPDIR/regex.uslocal | grep -v '#' | sort | uniq > $TEMPDIR/regex.list
	wait
	
}


#move
function move()
{
	#adlists.list
	mv $TEMPDIR/adlists.list $PIDIR/adlists.list
	mv $TEMPDIR/regex.list  $PIDIR/regex.list
	mv $TEMPDIR/CFconfig $FINISHED/cloudflared
	
}

#cleanup
function clean()
{
 rm -f $TEMPDIR/regex.*
 sudo systemctl restart cloudflared
}

function scripts()
{
 bash $FINISHED/ListUpdater.sh
 wait
 killall -SIGHUP pihole-FTL
 wait
 pihole -g
}


function whitelists()
{
	##Get Whitelists
	#Public
	curl -o $TEMPDIR/whitelist.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.txt'
	wait
	curl -o $TEMPDIR/adlist_whitelist.txt.tmp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/addlist_whitelist.txt'
	#On System
	cp $PIDIR/whitelist.txt $TEMPDIR/current.wl.temp
	
		#Private
		#curl -o $TEMPDIR/whitelist.encrypt.gpg 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.encrypt'
	
		#decrypt Private list
		#gpg $TEMPDIR/whitelist.encrypt.gpg

	##make whitelist
		#cat $TEMPDIR/current.wl.temp $TEMPDIR/whitelist.temp $TEMPDIR/whitelist.encrypt| sort | uniq > $TEMPDIR/final.wl.temp
	cat $TEMPDIR/current.wl.temp $TEMPDIR/whitelist.temp $TEMPDIR/adlist_whitelist.txt.tmp | sort | uniq > $TEMPDIR/final.wl.temp
	mv $TEMPDIR/final.wl.temp $PIDIR/whitelist.txt

	#cleanup
	rm $TEMPDIR/*.temp

}

function updates_additional()
{
	sqlite3 $PIDIR/gravity.db < $FINISHED/adlists.sql
	bash $FINISHED/whitelist_db_update.sh
	bash $FINISHED/regex_db_updater.sh
}

download
download_additional
modify
move
whitelists
updates_additional
scripts
clean