# Description
The script calculates current dynamic IP uptime and outputs a measurement suitable for the InfluxDB line protocol

The script relies on ddclient cache to get the latest IP address modified time. For this reason uptime average accuracy is half the ddclient scheduled IP check.

Note:
	* if you force a ddclient update (i.e.us  "ddclient --force") the cache mtime is updated, thus resulting in a wrong uptime measurement
	* ddclient cache has limited read access, that's why root privileges are needed

The script relies on the following tools:
	* ddclient
	* sudo, sed, grep


## Usage
Call the script from `telegraf.conf` like this:
```
[[inputs.exec]]
	commands = ["/usr/bin/sudo /etc/telegraf/bin/getipaddr.sh"]
	timeout = "5s"
	data_format = "influx"
```

Script needs root privileges to read ddclient cache, so you can add a `sudoers.d/telegraf` configuration file like this:
```
Cmnd_Alias      TELEGRAFCMD = /etc/telegraf/bin/getipaddr.sh

telegraf ALL=(root) NOPASSWD: TELEGRAFCMD
Defaults!TELEGRAFCMD !logfile, !syslog, !pam_session
```
Remember to check script permissions to allow execution and to remove group & others write permissions.


## Metrics:
- ipaddress
	- tags:
		- ipv4, IP address used for indexing
	- fields:
		- ipv4_addr (string)
		- uptime (integer, seconds)
