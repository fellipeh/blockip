#!/bin/bash
###############################################
### Developed by Fellipe Henrique < fellipeh[a]gmail[.]com >
### Create Date: 05-1-2011
#############
### Country blocker Script ###
### Please use ISO code for the countries ##

ISO="af cn ru ua by bg cz ro lv ee kz md pl rs sk sl az hu tr ir"

### Set PATH ###
IPT=/sbin/iptables
WGET=/usr/bin/wget
EGREP=/bin/egrep

### No editing below ###
SPAMLIST="countrydrop"
ZONEROOT="/root/iptables"
DLROOT="http://www.ipdeny.com/ipblocks/data/countries"

cleanOldRules(){
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT
}

# create a dir
[ ! -d $ZONEROOT ] && /bin/mkdir -p $ZONEROOT

# clean old rules
cleanOldRules

# create a new iptables list
$IPT -N $SPAMLIST

for c  in $ISO
do
  # local zone file
	tDB=$ZONEROOT/$c.zone

	# get fresh zone file
	$WGET -O $tDB $DLROOT/$c.zone

	# country specific log message
	SPAMDROPMSG="$c Country Drop"

	# get 
	BADIPS=$(egrep -v "^#|^$" $tDB)
	for ipblock in $BADIPS
	do
	   $IPT -A $SPAMLIST -s $ipblock -j LOG --log-prefix "$SPAMDROPMSG"
	   $IPT -A $SPAMLIST -s $ipblock -j DROP
	done
done

# Drop everything
$IPT -I INPUT -j $SPAMLIST
$IPT -I OUTPUT -j $SPAMLIST
$IPT -I FORWARD -j $SPAMLIST

iptables -A INPUT -s 112.111.0.0/16 -j DROP
iptables -A INPUT -s 188.165.0.0/16 -j DROP

# call my others iptable script
/etc/myserver/iptables_script.sh

exit 0
