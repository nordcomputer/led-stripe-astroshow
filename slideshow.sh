#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
MOUNT_BASE="/media/$USER"
DIRECTORY_NAME="Laufschrift"
PID_FILE="$SCRIPT_DIR/send_comments_pid"
TIME_TO_SHOW=5
MATRIX_NAME="Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller"
declare -a TTY_DEVICES=()

[ -f "$PID_FILE" ] && rm "$PID_FILE"

# Funktion zum Finden der Matrix oder mehreren Matrixen
getMatrix() {
    for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        if [[ "$devname" != "bus/"* ]]; then
            ID_SERIAL=""
            eval "$(udevadm info -q property --export -p $syspath)"
            if [[ -n "$ID_SERIAL" ]]; then
                if [[ $ID_SERIAL == *"$MATRIX_NAME"* ]]; then
                    echo "Found ID_SERIAL: $ID_SERIAL"
                    TTY_DEVICE=("/dev/$devname")
                    TTY_DEVICES+=($TTY_DEVICE)
                fi
            fi
          fi
    done
}

# Funktion zum Berechnen der Checksumme
calculate_checksum() {
  local packet=$1
  local xorValue=0

  for (( i=0; i<${#packet}; i++ )); do
    ascii=$(printf "%d" "'${packet:$i:1}")
    xorValue=$((xorValue ^ ascii))
  done

  # Konvertieren der XOR-Checksumme in einen zweistelligen hexadezimalen Wert
  printf "%02X" $xorValue
}

# Funktion zum Erstellen der Nachricht
create_message() {
  local text=$1
  local packet="<L1><PA><FE><MQ><WA><FE>${text}"
  local checksum=$(calculate_checksum "$packet")
  echo -e "<ID00>${packet}${checksum}<E><ID00><BF>01<E>
  "
}

show_image()
{
    image_path=$1
    eog "$image_path" --fullscreen --single-window &
}

send_formated_message()
{
    comment_image_path=$1
    # Extrahieren des Kommentars aus dem Bild
    # Extrahieren des Kommentars aus dem Bild
    title=$(exiftool -b -title "$comment_image_path")
    entfernung=$(exiftool -b -description "$comment_image_path")
    groesse=$(exiftool -b -subject "$comment_image_path")
    if [ "$title" != "" ]; then
      title="$title |"
    fi
    if [ "$entfernung" != "" ] && [ "$groesse" != "" ]; then
      entfernung="$entfernung |"
    fi
    comment="$title $entfernung $groesse"
    # Konvertieren des Kommentars in ISO 8859-1 (Latin-1)
    cleaned_comment=$(echo -n "$comment" | iconv -f UTF-8 -t iso-8859-1)

    # Überprüfen, ob der Kommentar erfolgreich extrahiert und konvertiert wurde
    if [ -z "$cleaned_comment" ]; then
      echo "No valid comment found in the image metadata for $comment_image_path."
      continue
    fi
    # Senden der Nachricht an den COM-Port
    message=$(create_message "$cleaned_comment")
    echo "$comment" && \
    for device in "${TTY_DEVICES[@]}"; do
      if [ -e $device ] ; then
        echo "$message" > $device
        sleep 3
        echo "$message" > $device
      else
          echo "Message was not sent, because LED matrix ($device) is not connected"
      fi
    done
}

# Funktion zum Verarbeiten des Verzeichnisses
process_directory() {
  local directory_path=$1
  getMatrix

  echo "TTY_DEVICES: ${TTY_DEVICES[@]}"
  while true; do
    # Schleife über alle Bilder im Verzeichnis und dessen Unterverzeichnissen
    find "$directory_path" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | while read -r image_path; do
      # Überprüfen, ob die Datei existiert
      if [ -f "$image_path" ]; then
        send_formated_message "$image_path" && \
        show_image $image_path $new_eog_pid && \
        sleep $TIME_TO_SHOW
      fi
    done
  done
}

while true; do
  found=0

  for mount_point in $(find "$MOUNT_BASE" -type d); do
    if [ -d "$mount_point/$DIRECTORY_NAME" ]; then
      found=1
      if [ ! -f "$PID_FILE" ]; then
        echo "Ordner $DIRECTORY_NAME gefunden in $mount_point. Starte das Script."
        process_directory "$mount_point/$DIRECTORY_NAME" &&
        echo $! > "$PID_FILE"
      fi
    fi
  done

  if [ $found -eq 0 ]; then
    if [ -f "$PID_FILE" ]; then
      PID=$(cat "$PID_FILE")
      kill $PID
      rm "$PID_FILE"
      echo "Ordner $DIRECTORY_NAME nicht gefunden. Stoppe das Script."
    fi
  fi
done