#!/bin/bash

# Überprüfen, ob die CSV-Datei und der Ordnerpfad als Argumente übergeben wurden
if [ "$#" -lt 2 ]; then
    echo "Bitte geben Sie den Pfad zur CSV-Datei und den Ordnerpfad mit den Bildern an."
    echo "Nutzung: $0 pfad/zur/csvdatei.csv pfad/zum/ordner"
    exit 1
fi

# CSV-Dateipfad aus dem ersten Argument
CSV_DATEI="$1"

# Ordnerpfad aus dem zweiten Argument
BILDER_ORDNER="$2"

# Überprüfen, ob die CSV-Datei existiert
if [ ! -f "$CSV_DATEI" ]; then
    echo "Die angegebene CSV-Datei existiert nicht."
    exit 1
fi

# Überprüfen, ob der Ordner existiert
if [ ! -d "$BILDER_ORDNER" ]; then
    echo "Der angegebene Ordner existiert nicht."
    exit 1
fi

# CSV-Datei Zeile für Zeile einlesen
while IFS=';' read -r DATEINAME NAME ENTFERNUNG GROESSE CREATOR; do
    # Überspringen der Header-Zeile
    if [ "$DATEINAME" == "Dateiname" ]; then
        continue
    fi

    # Vollständigen Pfad zur Datei erstellen
    DATEIPFAD="$BILDER_ORDNER/$DATEINAME"

    # Datei existiert prüfen
    if [ -f "$DATEIPFAD" ]; then
        echo "Schreibe Metadaten für $DATEIPFAD ..."
        if [ "$ENTFERNUNG" != "" ]; then
            ENTFERNUNG="Entfernung: $ENTFERNUNG"
        fi
        if [ "$GROESSE" != "" ]; then
            GROESSE="Größe: $GROESSE"
        fi
        NAME=$(echo "$NAME" | sed 's/–/-/g')
        GROESSE=$(echo "$GROESSE" | sed 's/–/-/g')
        ENTFERNUNG=$(echo "$ENTFERNUNG" | sed 's/–/-/g')
        # Metadaten mit ExifTool schreiben
        exiftool -overwrite_original -XMP-dc:Title="$NAME" -XMP-dc:Description="$ENTFERNUNG" -XMP-dc:Subject="$GROESSE" -XMP-dc:Creator="$CREATOR" "$DATEIPFAD"

    else
        echo "Datei $DATEIPFAD existiert nicht, übersprungen."
    fi
done < "$CSV_DATEI"

echo "Metadaten wurden erfolgreich geschrieben."
