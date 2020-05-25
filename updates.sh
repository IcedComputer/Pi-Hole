#!/bin/bash

## Updated 15 Oct 2019

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
	wait
	
	#download an updated update.sh, but keep in temp
	wget -O $TEMPDIR/updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/updates.sh'
	
	#download new cloudflared configs
	wget -O $TEMPDIR/CFconfig 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFconfig'
	

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
	#Wildcards (03-pihole-wildcard.conf)
	mv $TEMPDIR/regex.list  $PIDIR/regex.list
	mv $TEMPDIR/CFconfig /etc/default/cloudflared


}

#cleanup
function clean()
{
 rm -f $TEMPDIR/regex.*
 sudo systemctl restart cloudflared
}

function scripts()
{
 bash /scripts/Finished/ListUpdater.sh
 wait
 killall -SIGHUP pihole-FTL
 wait
 pihole -g
}


function whitelists()
{
	##Get Whitelists
	#Public
	wget -O $TEMPDIR/whitelist.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.txt'
	#On System
	cp $PIDIR/whitelist.txt $TEMPDIR/current.wl.temp
	
		#Private
		#wget -O $TEMPDIR/whitelist.encrypt.gpg 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.encrypt'
	
		#decrypt Private list
		#gpg $TEMPDIR/whitelist.encrypt.gpg

	##make whitelist
		#cat $TEMPDIR/current.wl.temp $TEMPDIR/whitelist.temp $TEMPDIR/whitelist.encrypt| sort | uniq > $TEMPDIR/final.wl.temp
	cat $TEMPDIR/current.wl.temp $TEMPDIR/whitelist.temp | sort | uniq > $TEMPDIR/final.wl.temp
	mv $TEMPDIR/final.wl.temp $PIDIR/whitelist.txt

	#cleanup
	rm $TEMPDIR/*.temp
	rm $TEMPDIR/whitelist.*

}



download
modify
move
clean
scripts
whitelists

