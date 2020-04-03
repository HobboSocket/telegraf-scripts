#!/usr/bin/env python3

import subprocess

# UPS_NAME should not contain commas, spaces, equals characters
UPS_NAME = "UPSCyberPower"
UPSC_CMD = "/usr/local/bin/upsc"

cmd = UPSC_CMD + " " + UPS_NAME
output = ""
fields = ""
tags = ""

# adjust tag_keys and field_keys according to 'upsc' output
tag_keys = ["battery.type", "device.mfr", "device.model", "device.type", "ups.status"]

# True if field is a value, False otherwise (it's a string)
field_keys = {"battery.charge":True, "battery.runtime":True, "battery.voltage":True,
   "input.voltage":True, "input.voltage.nominal":True, "output.voltage":True, 
   "ups.load":True}

p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)

for line in p.stdout.readlines(): #read and store result in log file
    line = line.decode("utf-8")
    aline = line.split(":")

    key = aline[0].strip()
    value = aline[1].strip()

    if key in field_keys:
       fields += "," if fields != "" else ""
       
       if field_keys[key]:
          # field is a value
          fields += key + "=" + value
       else:
       	 # field is a string
          fields += key + '="' + value + '"'

    elif key in tag_keys:
       tags += "," + key + "=" + value.replace(" ", "\\ ")

    # else:
    	 # key not listed - ignore it

output = "upsc,name=" + UPS_NAME + tags + " " + fields
print(output, end='')
