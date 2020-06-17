while read regex
do
	sudo sqlite3 /etc/pihole/gravity.db "insert or ignore into domainlist (domain, type, enabled) values (\"$regex\", 3, 1);"
	done < /etc/pihole/regex.list