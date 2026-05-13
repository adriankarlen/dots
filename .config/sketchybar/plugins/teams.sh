#!/usr/bin/env bash

ICON="󰊻"

if ! pgrep -xq "MSTeams"; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

sketchybar --set "$NAME" drawing=on

STATUS_LABEL=$(lsappinfo info -only StatusLabel "Microsoft Teams")

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"
elif [[ $STATUS_LABEL =~ kCFNULL ]]; then
    LABEL=""
else
    LABEL=""
fi

if [[ $LABEL == "" ]]; then
    # No notifications - Iris (magenta)
    ICON_COLOR="0xffc4a7e7"
elif [[ $LABEL == "•" ]]; then
    # Activity dot - Gold (yellow)
    ICON_COLOR="0xfff6c177"
elif [[ $LABEL =~ ^[0-9]+$ ]]; then
    # Unread count - Love (red)
    ICON_COLOR="0xffeb6f92"
else
    ICON_COLOR="0xffc4a7e7"
fi

sketchybar --set "$NAME" icon="$ICON" label="${LABEL}" icon.color="${ICON_COLOR}"
