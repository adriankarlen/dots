#!/bin/sh

DATA=$(media-control get 2>/dev/null)

if [ -z "$DATA" ]; then
  sketchybar -m --set media.name drawing=off
  exit 0
fi

TITLE=$(printf '%s' "$DATA" | jq -r '.title // empty')
ARTIST=$(printf '%s' "$DATA" | jq -r '.artist // empty')
BUNDLE=$(printf '%s' "$DATA" | jq -r '.bundleIdentifier // empty')

# Pick icon based on app: sketchybar-app-font ligatures, SF Symbol (music.note) as fallback
case "$BUNDLE" in
com.spotify.client) ICON=":spotify:" ICON_FONT="sketchybar-app-font:Regular:16.0" ;;
com.apple.Music) ICON=":music:" ICON_FONT="sketchybar-app-font:Regular:16.0" ;;
*) ICON="􀑪" ICON_FONT="SF Pro:Semibold:16.0" ;;
esac

if [ -z "$TITLE" ]; then
  sketchybar -m --set media.name label="Not Playing" icon="$ICON" icon.font="$ICON_FONT" drawing=on
else
  if [ -z "$ARTIST" ]; then
    LABEL="${TITLE}"
  else
    LABEL="${ARTIST} - ${TITLE}"
  fi
  if [ ${#LABEL} -gt 50 ]; then
    LABEL="$(printf '%.47s' "$LABEL")..."
  fi
  sketchybar -m --set media.name label="$LABEL" icon="$ICON" icon.font="$ICON_FONT" drawing=on
fi
