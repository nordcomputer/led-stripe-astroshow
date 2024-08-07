#!/usr/bin/env bash
MATRIX_NAME="Mouse"
declare -a TTY_DEVICES=()

# Funktion zum Finden der Matrix oder mehreren Matrixen
getMatrix() {
    for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do


          echo "Processing: $sysdevpath"
          syspath="${sysdevpath%/dev}"
          devname="$(udevadm info -q name -p $syspath)"
          echo "Found device name: $devname"
          if [[ "$devname" != "bus/"* ]]; then
                ID_SERIAL=""
                eval "$(udevadm info -q property --export -p $syspath)"
                if [[ -n "$ID_SERIAL" ]]; then
                    if [[ $ID_SERIAL == *"$MATRIX_NAME"* ]]; then
                        echo "Found ID_SERIAL: $ID_SERIAL"
                        TTY_DEVICE=("/dev/$ID_SERIAL:$devname")
                        TTY_DEVICES+=($TTY_DEVICE)
                    fi
                fi

          fi

    done

    echo "TTY_DEVICES: ${TTY_DEVICES[@]}"
}
getMatrix
for i in "${TTY_DEVICES[@]}"
do
   echo "found $i"
done
