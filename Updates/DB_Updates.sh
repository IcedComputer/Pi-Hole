## Last Updated 08 May 2021
## DB_Updates.sh
## This script is designed to keep the pihole updated and linked to any changes made
##

#!/bin/bash

#Vars
FINISHED=/scripts/Finished
TEMPDIR=/scripts/temp
PIDIR=/etc/pihole


function adlist()
{
# Clears the existing adlist database
sqlite3 "/etc/pihole/gravity.db" "DELETE FROM adlist"

# Preps the adlist
cat $TEMPDIR/adlist.list | grep -v '#' | grep "http" | sort | uniq > $TEMPDIR/formatted_adlist.temp

# Inserts URLs into the adlist database
file='$TEMPDIR/formatted_adlist.temp'
i=1
while read line; do
        sqlite3 "/etc/pihole/gravity.db" "INSERT INTO adlist (id, address, enabled) VALUES($i, $line, 1)"
        i=$((i+1))
done < $file
}

function regex()
{
# Purge existing regex list
pihole --regex --nuke

#adds regex from following file
regex='$TEMPDIR/regex.list'

while read -r regex; do
	pihole --regex -nr $regex
	wait
done < $file
}

function allow()
{
# Purge existing allow list
#pihole -w --nuke

#adds allow list from following file
file='$TEMPDIR/final.allow.temp'

while read allow; do
	pihole -w -nr $allow
	wait
done < $file
}

function allow_regex()
{
# Purge existing allow list
pihole --white-regex --nuke

#adds allow list from following file
file='$TEMPDIR/WL_regex.list'

while read -r WLallow; do
	pihole --white-regex -nr $WLallow
	wait
done < $file
}

## Main Program
allow
#allow_regex
adlist
regex