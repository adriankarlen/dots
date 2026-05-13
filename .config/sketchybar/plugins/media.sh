#!/bin/sh

DATA=$(media-control get 2>/dev/null)

if [ -z "$DATA" ]; then
  sketchybar -m --set media.name drawing=off
  exit 0
fi

TITLE=$(printf '%s' "$DATA" | jq -r '.title // empty')
ARTIST=$(printf '%s' "$DATA" | jq -r '.artist // empty')
BUNDLE=$(printf '%s' "$DATA" | jq -r '.bundleIdentifier // empty')

# Pick icon based on app
case "$BUNDLE" in
  com.spotify.client) ICON="󰓇" ;;
  com.apple.Music)    ICON="󰎆" ;;
  *)                  ICON="󰎈" ;;
esac

if [ -z "$TITLE" ]; then
  sketchybar -m --set media.name label="Not Playing" icon="$ICON" drawing=on
else
  LABEL="${ARTIST} - ${TITLE}"
  if [ ${#LABEL} -gt 50 ]; then
    LABEL="$(printf '%.47s' "$LABEL")..."
  fi
  sketchybar -m --set media.name label="$LABEL" icon="$ICON" drawing=on
fi
