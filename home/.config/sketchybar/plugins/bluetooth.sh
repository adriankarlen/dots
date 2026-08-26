#!/bin/bash

DEVICE="2C:32:6A:E9:07:9C"
CONNECTED_ICON="󰂯"   # Nerd Font Bluetooth icon connected
DISCONNECTED_ICON="󰂲" # Nerd Font Bluetooth icon disconnected
HIGHLIGHT_COLOR="0xffc4a7e7"  # Rosé Pine Iris
DEFAULT_COLOR="0xff908caa"    # Rosé Pine Subtle

is_connected() {
  system_profiler SPBluetoothDataType 2>/dev/null \
    | awk '/Connected:/{c=1; next} /Not Connected:/{c=0} c && /'"$DEVICE"'/{found=1} END{exit !found}'
}

update() {
  if is_connected; then
    sketchybar --set "$NAME" icon="$CONNECTED_ICON" icon.color="$HIGHLIGHT_COLOR"
  else
    sketchybar --set "$NAME" icon="$DISCONNECTED_ICON" icon.color="$DEFAULT_COLOR"
  fi
}

mouse_clicked() {
  if is_connected; then
    osascript -e 'tell application "Spotify" to playpause'
    osascript -e "tell application \"System Events\" to tell process \"ControlCenter\" to click menu bar item \"Bluetooth\" of menu bar 1"
  else
    osascript -e "tell application \"System Events\" to tell process \"ControlCenter\" to click menu bar item \"Bluetooth\" of menu bar 1"
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  *) update ;;
esac
