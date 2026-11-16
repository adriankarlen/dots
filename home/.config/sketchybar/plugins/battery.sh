#!/usr/bin/env bash

PERCENTAGE="$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

[ -z "$PERCENTAGE" ] && exit 0

# SF Symbols: battery.100 / .75 / .50 / .25 / .0 and battery.100percent.bolt
case "${PERCENTAGE}" in
  9[0-9] | 100) ICON="􀛨" ;;
  [6-8][0-9]) ICON="􀺸" ;;
  [3-5][0-9]) ICON="􀺶" ;;
  [1-2][0-9]) ICON="􀛩" ;;
  *) ICON="􀛪" ;;
esac

[ -n "$CHARGING" ] && ICON="􀢋"

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
