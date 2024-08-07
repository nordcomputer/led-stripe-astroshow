#!/usr/bin/env bash

for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
    (
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        [[ "$devname" == "bus/"* ]] && exit
        eval "$(udevadm info -q property --export -p $syspath)"
        [[ -z "$ID_SERIAL" ]] && exit
        echo "$ID_SERIAL :/dev/$devname"
        if [[ $ID_SERIAL == *""* ]]; then
            echo $ID_SERIAL
            echo "/dev/$devname"
        fi
    )
done