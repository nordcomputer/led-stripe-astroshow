#!/usr/bin/env bash

# Überprüfen, ob genügend Argumente übergeben wurden
if [ "$#" -lt 2 ]; then
    echo "Bitte geben Sie den Pfad zum Ordner und den Pfad zur Ziel-CSV-Datei an."
    echo "Nutzung: $0 /pfad/zum/ordner /pfad/zur/ausgabedatei.csv"
    exit 1
fi

# Argumente
SOURCE_DIR="$1"
OUTPUT_CSV="$2"

# CSV-Header schreiben
echo "Dateiname;Name;Entfernung;Größe;Creator" > "$OUTPUT_CSV"

# Funktion zum Auslesen der Metadaten
extract_metadata() {
    local image_path="$1"
    local relative_path="${image_path#$SOURCE_DIR/}"
    local title=$(exiftool -b -title "$image_path")
    local description=$(exiftool -b -description "$image_path")
    local subject=$(exiftool -b -subject "$image_path")
    local creator=$(exiftool -b -creator "$image_path")

    # Die Metadaten in eine CSV-Zeile schreiben, getrennt durch Semikolons
    echo "\"$relative_path\";\"$title\";\"$description\";\"$subject\";\"$creator\"" >> "$OUTPUT_CSV"
}

# Rekursiv durch alle Bilder im Verzeichnis gehen
find "$SOURCE_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | while IFS= read -r image_path; do
    # Metadaten aus jedem Bild auslesen
    extract_metadata "$image_path"
done

echo "Metadaten wurden in $OUTPUT_CSV geschrieben."
