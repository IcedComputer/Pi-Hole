while read allow
do
	sudo sqlite3 /etc/pihole/gravity.db "insert or ignore into domainlist (domain, type, enabled) values (\"$allow\", 0, 1);"
	done < /etc/pihole/whitelist.txt