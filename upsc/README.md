# Description
Get data from USB-connected UPS into InfluxDB using Telegraf. This script is based on https://github.com/vkorobov/ups-telegraf work.

Transforms `upsc` output like this:
```
battery.charge: 100
battery.charge.low: 10
battery.charge.warning: 20
battery.mfr.date: CPS
battery.runtime: 3133
battery.runtime.low: 300
battery.type: PbAcid
battery.voltage: 13.1
battery.voltage.nominal: 12
```
..into InfluxDB Line Protocol like this:
```
upsc,name=UPSCyberPower,battery.type=PbAcid,device.mfr=CPS,device.model=CP900EPFCLCD,device.type=ups,ups.status=OL battery.charge=100,battery.runtime=3150,battery.voltage=24.0,input.voltage=242.0,input.voltage.nominal=230,output.voltage=260.0,ups.load=9
```
using both tags and fields for better InfluxDB indexing and searching.


## Usage
Edit the script `UPS_NAME` and `UPSC_CMD` variables to reflect your setup. Specifically, change 'UPSCyberPower' to whatever you named your UPS in `NUT` or `upsd`.

Add any upsc output peculiar to your environment to the `tag_keys` and `field_keys` variables.

Call the script from `telegraf.conf` like this
```
[[inputs.exec]]
   commands = ["/path/to/getUpsData.py"]
   timeout = "5s"
   data_format = "influx"
```
For an UPS Grafana dashboards look at https://github.com/vkorobov/ups-telegraf


## Compatibility
Tested on:
* Cyberpower CP1000AVRLCDa
* APC Back-UPS
* Cyberpower CP900EPFCLCD

If you're using this with a different UPS, please let me know so I can add it to the list
