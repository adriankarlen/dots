#!/bin/bash

DEVICE="2C:BE:EE:4B:7F:68"
CONNECTED_ICON="󰂯"   # Nerd Font Bluetooth icon connected
DISCONNECTED_ICON="󰂲" # Nerd Font Bluetooth icon disconnected
HIGHLIGHT_COLOR="0xffD27E99"  # Kanagawa SakuraPink
DEFAULT_COLOR="0xff7E9CD8"    # Kanagawa WaveBlue1

update() {
  if [ "$(blueutil --is-connected "$DEVICE")" = "1" ]; then
    sketchybar --set "$NAME" icon="$CONNECTED_ICON" icon.color="$HIGHLIGHT_COLOR"
  else
    sketchybar --set "$NAME" icon="$DISCONNECTED_ICON" icon.color="$DEFAULT_COLOR"
  fi
}

mouse_clicked() {
  if [ "$(blueutil --is-connected "$DEVICE")" = "1" ]; then
    osascript -e 'tell application "Spotify" to playpause'
    blueutil --disconnect "$DEVICE"
  else
    blueutil --connect "$DEVICE"
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  *) update ;;
esac
