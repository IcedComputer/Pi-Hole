## Last Updated 15 Aug 2020
## updates.sh
## This script is designed to keep the pihole updated and linked to any changes made
##



#!/bin/bash

#Vars
FINISHED=/scripts/Finished
TEMPDIR=/scripts/temp
PIDIR=/etc/pihole
CONFIG=/scripts/Finished/CONFIG
Type=$(<"$CONFIG/type.conf")
test_system=$(<"$CONFIG/test.conf") 

#Some basic functions including updating the box & getting new configuration files
function base()
{
	 apt-get update && apt-get dist-upgrade -y
	 wait
	 apt autoremove -y
	 wait
	 
	 download new cloudflared configs
	curl -o $TEMPDIR/CFconfig 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFconfig'
		
	#download a new refresh.sh
	curl -o $TEMPDIR/security_refresh.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/security_refresh.sh'
	
	#refresh.sh
	chmod 777 $TEMPDIR/refresh.sh
}

function full()
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
	
	## Create Regex 
	cat $TEMPDIR/main.regex $TEMPDIR/country.regex $TEMPDIR/oTLD.regex $TEMPDIR/uslocal.regex | grep -v '#' | sort | uniq > $TEMPDIR/regex.list
}

function security()
{

	#adlists.list 
	curl -o $TEMPDIR/adlists.list 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/adlists/security_basic_adlist.list'

	# Regex Lists
	curl -o $TEMPDIR/basic_security.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Regex%20Files/basic)security.regex'
	wait
	curl -o $TEMPDIR/basic_country.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Regex%20Files/basic_country.regex'
	wait
	curl -o $TEMPDIR/oTLD.regex 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Regex%20Files/oTLD.regex'
	wait
	## Create Regex 
	cat $TEMPDIR/basic_security.regex $TEMPDIR/basic_country.regex $TEMPDIR/oTLD.regex | grep -v '#' | sort | uniq > $TEMPDIR/regex.list
}

function test_list()
{
 curl -o $TEMPDIR/adlists.list.trial.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/adlists/trial.adlist.list'
 cat $TEMPDIR/adlists.list.trial.temp $TEMPDIR/adlists.list | sort | uniq > $TEMPDIR/adlists.list.temp
 mv $TEMPDIR/adlists.list.temp $TEMPDIR/adlists.list
}

function move()
{
	
	mv $TEMPDIR/adlists.list $PIDIR/adlists.list
	mv $TEMPDIR/regex.list  $PIDIR/regex.list
	mv $TEMPDIR/CFconfig $FINISHED/cloudflared
	mv $TEMPDIR/refresh.sh $FINISHED/refresh.sh
	
}

function scripts()
{
 killall -SIGHUP pihole-FTL
 wait
 pihole -g
}

function public_allowlist()
{
	##Get allowlist
	#Public
	curl -o $TEMPDIR/basic.allow.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Allow%20Lists/basic.allow'
	wait
	curl -o $TEMPDIR/adlist.allow.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Allow%20Lists/adlist.allow'
	#On System
	cp $PIDIR/whitelist.txt $TEMPDIR/current.allow.temp
	
}

function security_allowlist()
{
	##Get Whitelists
	#Public
	curl -o $TEMPDIR/security_only.allow.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Allow%20Lists/security_only.allow'
}

#function encrypted_allowlist()
#{

	#curl -o $TEMPDIR/encrypt.allow.temp.gpg 'https://github.com/IcedComputer/Personal-Pi-Hole-configs/raw/master/Allow%20Lists/encrypt.allow.gpg'
	
	#gpg $TEMPDIR/encrypt.allow.temp.gpg
#}

function assemble_allowlist()
{
	cat $TEMPDIR/*.allow.temp  | sort | uniq > $TEMPDIR/final.allow.temp
	mv $TEMPDIR/final.allow.temp $PIDIR/whitelist.txt
}

#cleanup
function clean()
{
 rm -f $TEMPDIR/*.regex
 rm -f $TEMPDIR/*.temp
 rm -f $TEMPDIR/*.gpg
 sudo systemctl restart cloudflared
}


## Main Script
#base

if [ $Type = "security" ]
	then
		security
		security_allowlist
		echo "SECURITY \n\n"
	else
		full
		echo "FULL \n\n"
		if [ $test_system = "yes" ]
			then
				test_list

		fi
fi


move
scripts
public_allowlist
#encrypted_allowlist
assemble_allowlist
clean