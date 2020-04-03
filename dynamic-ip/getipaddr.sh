#!/usr/bin/env sh
#
# Script that calculates current dynamic IP uptime and outputs a measurement suitable
# for the InfluxDB line protocol
#
# The script relies on ddclient cache to get the last IP address modified time. For
# this reason uptime average accuracy is half the ddclient scheduled IP check.
#
# Note:
#	- if you force a ddclient update (i.e.us  "ddclient --force") the cache mtime
# 	is updated, thus resulting in a wrong uptime measurement
#	- ddclient cache has limited read access, that's why root privileges are needed
#
# The script relies on the following tools:
# 	- ddclient
# 	- sudo, sed, grep
#
# ======= Telegraf configuration (/etc/telegraf/telegraf.conf) =======
# [[inputs.exec]]
# 	commands = ["/usr/bin/sudo /etc/telegraf/bin/getipaddr.sh"]
# 	timeout = "5s"
# 	data_format = "influx"
# =======
#
# ======= SUDO configuration (/etc/sudoers.d/telegraf) =======
# Cmnd_Alias      TELEGRAFCMD = /etc/telegraf/bin/getipaddr.sh
#
# telegraf ALL=(root) NOPASSWD: TELEGRAFCMD
# Defaults!TELEGRAFCMD !logfile, !syslog, !pam_session
# =======
#
# Changelog:
# 	2020-03-28: first version
#


DDNSCLIENT_CACHE='/var/cache/ddclient/ddclient.cache'

ipaddr=$(dig @resolver1.opendns.com -4 +short +timeout=3 myip.opendns.com.)

if [ $? -ne 0 ]; then
	# no Internet connection: do not emit metrics
	exit 1
fi

# Get first time that we saw the current IP address through ddnsclient cache
# We need root privileges to read ddnsclient cache
lastTstamp=$(grep -E -s -m 1 -o 'ip='"${ipaddr}"',mtime=[[:digit:]]+,' "$DDNSCLIENT_CACHE" | \
	sed -n -e 's/.*mtime=\([[:digit:]]\+\),.*/\1/p')

# check il lastTstamp is a value, otherwise use 0 as uptime
uptime=0
case "${lastTstamp#[+-]}" in
	''|*[!0-9]*)
		# lastTstamp is not an integer
		;;
	*)
		#lastTstamp is a value
		currtime=$(date +"%s")
		uptime=$((currtime-lastTstamp))
		;;
esac

output="ipaddress,ipv4=${ipaddr} ipv4_addr=\"${ipaddr}\",uptime=${uptime}i"

echo -n "${output}"
