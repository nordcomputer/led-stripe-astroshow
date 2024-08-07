#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
MOUNT_BASE="/media/$USER"
DIRECTORY_NAME="Laufschrift"
SCRIPT_PATH="$SCRIPT_DIR/laufband.sh"
PID_FILE="$SCRIPT_DIR/send_comments_pid"

while true; do
  found=0

  for mount_point in $(find "$MOUNT_BASE" -mindepth 1 -maxdepth 1 -type d); do
    if [ -d "$mount_point/$DIRECTORY_NAME" ]; then
      found=1
      if [ ! -f "$PID_FILE" ]; then
        echo "Ordner $DIRECTORY_NAME gefunden in $mount_point. Starte das Script."
        $SCRIPT_PATH "$mount_point/$DIRECTORY_NAME" &
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

  sleep 10
done
