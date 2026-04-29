#!/bin/sh

next() {
  osascript -e 'tell application "Spotify" to play next track'
}

back() {
  osascript -e 'tell application "Spotify" to play previous track'
}

play() {
  osascript -e 'tell application "Spotify" to playpause'
}

repeat() {
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar -m --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else
    sketchybar -m --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}

shuffle() {
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar -m --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else
    sketchybar -m --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

update() {
  # Check if Spotify is running
  SPOTIFY_RUNNING=$(osascript -e 'application "Spotify" is running')

  if [ "$SPOTIFY_RUNNING" = "false" ]; then
    # Hide widget if Spotify is closed
    sketchybar -m --set spotify.name drawing=off popup.drawing=off
    exit 0
  fi

  # Default values
  TRACK=""
  ARTIST=""
  ALBUM=""
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  STATE=$(osascript -e 'tell application "Spotify" to player state')

  if [ "$STATE" = "playing" ]; then
    TRACK=$(osascript -e 'tell application "Spotify" to name of current track' )
    ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track')
    ALBUM=$(osascript -e 'tell application "Spotify" to album of current track')
  fi

  args=()

  # Always show the widget if Spotify is running
  if [ "$TRACK" = "" ]; then
    args+=(--set spotify.name label="Not Playing" drawing=on)
  else
    args+=(--set spotify.name label="${TRACK} - ${ARTIST}" drawing=on)
  fi

  if [ "$STATE" = "playing" ]; then
    args+=(--set spotify.play icon=􀊆)
  else
    args+=(--set spotify.play icon=􀊄)
  fi

  args+=(--set spotify.shuffle icon.highlight="$SHUFFLE")
  args+=(--set spotify.repeat icon.highlight="$REPEAT")

  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  case "$NAME" in
    "spotify.next") next ;;
    "spotify.back") back ;;
    "spotify.play") play ;;
    "spotify.shuffle") shuffle ;;
    "spotify.repeat") repeat ;;
    *) exit ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "forced") exit ;;
  *) update ;;
esac
