# USB-Monitor und Bildershow-Skript

Dieses Projekt besteht aus zwei Bash-Skripten:

1. `usb_monitor.sh`: Dieses Skript überwacht einen USB-Stick, erkennt einen bestimmten Ordner und startet eine Bildershow, während serielle Befehle an ein anderes USB-Gerät gesendet werden.
2. `showText.sh`: Dieses Skript sendet einfachen Text an ein LED-Laufband.

## Voraussetzungen

### Systemanforderungen

- Ein Linux-basiertes Betriebssystem (getestet auf Ubuntu, Debian)
- Ein Benutzerkonto mit ausreichenden Berechtigungen zum Zugriff auf `/media/$USER` und zum Ausführen von Skripten

### Software-Abhängigkeiten

- **bash**: Die Bash-Shell ist erforderlich, um die Skripte auszuführen. In den meisten Linux-Distributionen ist Bash standardmäßig installiert.
- **eog (Eye of GNOME)**: Bildbetrachter, der die Bilder im Vollbildmodus anzeigt.
- **exiftool**: Ein Werkzeug zum Extrahieren von Metadaten aus Bildern.
- **iconv**: Ein Werkzeug zur Konvertierung von Zeichencodierungen.
- **find**: Zum Durchsuchen von Verzeichnissen und Suchen nach bestimmten Dateien.
- **echo**: Zum Ausgeben von Text in die Konsole und zum Senden von Nachrichten an den seriellen Port.

### Hardware

- Ein USB-Stick mit dem Ordner `Laufschrift`
- Ein serielles USB-Gerät, das unter `/dev/ttyUSB0` verfügbar ist

## Installation

### Software-Abhängigkeiten installieren

Stellen Sie sicher, dass die folgenden Pakete installiert sind. Verwenden Sie dazu den Paketmanager Ihrer Distribution (z.B. `apt` für Debian-basierte Distributionen):

```sh
sudo apt update
sudo apt install eog exiftool iconv findutils
