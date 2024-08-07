#!/bin/bash

# Überprüfen, ob ein Verzeichnispfad übergeben wurde
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

directory_path=$1

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

while true; do
  # Schleife über alle Bilder im Verzeichnis
  for image_path in "$directory_path"/*.{jpg,jpeg,png}; do
    # Überprüfen, ob die Datei existiert
    if [ -f "$image_path" ]; then
      message=$(create_message " ")
      echo "$message" > /dev/ttyUSB0
      sleep 3
      echo "Processing $image_path..." && \
      # Öffnen des Bildes in Vollbild mit feh
      feh --fullscreen "$image_path" &
      feh_pid=$!

      # Extrahieren des Kommentars aus dem Bild
      comment=$(exiftool -b -comment "$image_path") && \


      # Konvertieren des Kommentars in ISO 8859-1 (Latin-1)
      cleaned_comment=$(echo -n "$comment" | iconv -f UTF-8 -t iso-8859-1)

      # Überprüfen, ob der Kommentar erfolgreich extrahiert und konvertiert wurde
      if [ -z "$cleaned_comment" ]; then
        echo "No valid comment found in the image metadata for $image_path."
        continue
      fi
      # Senden der Nachricht an den COM-Port
      message=$(create_message "$cleaned_comment")
      echo "Sent message for $image_path: $comment" && \
      echo "$message" > /dev/ttyUSB0
      # Warten für 1 Minute
      sleep 30
      # Schließen des Bildes
      kill $feh_pid
    fi
  done
done


