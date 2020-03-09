#!/bin/bash

## Updated 09 Mar 2020

#Vars

TEMPDIR=/scripts/temp
PIDIR=/etc/pihole



#whitelist 
wget -O $TEMPDIR/whitelist.temp 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.txt'
cp $PIDIR/whitelist.txt $TEMPDIR/current.wl.temp

cat $TEMPDIR/current.wl.temp $TEMPDIR/whitelist.temp | sort | uniq > $TEMPDIR/final.wl.temp
mv $TEMPDIR/final.wl.temp $PIDIR/whitelist.txt

rm $TEMPDIR/current.wl.temp
rm $TEMPDIR/whitelist.temp