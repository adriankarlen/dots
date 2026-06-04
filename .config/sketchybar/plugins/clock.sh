#!/bin/sh

datetime=$(date '+%Y-%m-%d • %H:%M')

sketchybar --set "$NAME" label="${datetime}"
