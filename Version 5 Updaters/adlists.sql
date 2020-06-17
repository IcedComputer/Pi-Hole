CREATE TEMP TABLE i(txt);
.separator ~
.import /etc/pihole/adlists.list i
INSERT OR IGNORE INTO adlist (address) SELECT txt FROM i;
DROP TABLE i;