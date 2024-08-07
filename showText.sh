#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
TTY_DEVICE="/dev/ttyUSB0"


[ -f "$PID_FILE" ] && rm "$PID_FILE"

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
  echo -e "<ID00>${packet}${checksum}<E><ID00><BF>06<E>"
}

send_formated_message()
{
    text_to_show=$1
    message=$(create_message " ")
    if [ -e $TTY_DEVICE ] ; then
      echo "$message" > $TTY_DEVICE
    fi
    # Extrahieren des Kommentars aus dem Bild

    # Konvertieren des Kommentars in ISO 8859-1 (Latin-1)
    cleaned_text=$(echo -n "$text_to_show" | iconv -f UTF-8 -t iso-8859-1)

    # Überprüfen, ob der Kommentar erfolgreich extrahiert und konvertiert wurde
    if [ -z "$cleaned_text" ]; then
      echo "No valid comment found in the image metadata for $text_to_show."
      continue
    fi
    # Senden der Nachricht an den COM-Port
    message=$(create_message "$cleaned_text")
    echo "$text_to_show" && \
    if [ -e $TTY_DEVICE ] ; then
      echo "$message" > $TTY_DEVICE
    else
        echo "Message was not sent, because LED stripe is not connected."
    fi
}

send_formated_message "$1"
