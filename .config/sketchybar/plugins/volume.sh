#!/bin/bash

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

OUTPUT=$(SwitchAudioSource -c 2>/dev/null)

case "$OUTPUT" in
  *AirPods*)  ICON="󰥰" ;;
  *Speakers*) ICON="󰓃" ;;
  *)          ICON="󰕾" ;;
esac

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  if [ "$VOLUME" = "0" ]; then
    ICON="󰖁"
  fi

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%"
else
  sketchybar --set "$NAME" icon="$ICON"
fi
