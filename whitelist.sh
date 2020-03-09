#!/bin/bash

## Updated 09 Mar 2020

#Vars

TEMPDIR=/scripts/temp
PIDIR=/etc/pihole



#whitelist 
wget -O $TEMPDIR/whitelist.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.txt'
mv $TEMPDIR/whitelist.temp $PIDIR/whitelist.txt
