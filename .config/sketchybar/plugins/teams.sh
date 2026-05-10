#!/usr/bin/env bash

STATUS_LABEL=$(lsappinfo info -only StatusLabel "Microsoft Teams")
ICON="󰊻"

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"

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
        exit 0
    fi
else
    exit 0
fi

sketchybar --set "$NAME" icon="$ICON" label="${LABEL}" icon.color="${ICON_COLOR}"
