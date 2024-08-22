#!/bin/bash

# Überprüfen, ob genügend Argumente übergeben wurden
if [ "$#" -lt 2 ]; then
    echo "Bitte geben Sie den Pfad zu dem Ordner und den Ausgabedateinamen an."
    echo "Nutzung: $0 /pfad/zum/ordner ausgabedatei.csv"
    exit 1
fi

# Ordnerpfad aus dem ersten Argument
ORDNERPFAD="$1"

# Ausgabedatei aus dem zweiten Argument
AUSGABEDATEI="$2"

# Sicherstellen, dass die Ausgabedatei leer ist, falls sie bereits existiert
> "$AUSGABEDATEI"

# CSV-Header schreiben
echo "Dateiname;Name;Entfernung;Größe;Creator" >> "$AUSGABEDATEI"

# Alle PNG- GIF- und JPG-Dateien einlesen und die Dateinamen in die CSV-Datei schreiben
for DATEI in "$ORDNERPFAD"/*.{png,jpg,jpeg,gif}; do
    # Prüfen, ob die Datei existiert (falls keine Dateien gefunden wurden, um Fehlermeldungen zu vermeiden)
    if [ -e "$DATEI" ]; then
        DATEINAME=$(basename "$DATEI")
        echo "$DATEINAME;;;" >> "$AUSGABEDATEI"
    fi
done

echo "Dateinamen wurden in $AUSGABEDATEI geschrieben."
