#!/bin/sh

day=$(date '+%e')
month_num=$(date '+%m')
time=$(date '+%H:%M')

# Trim leading space in day
day=$(echo "$day" | sed 's/^ *//')

# Determine suffix
case "$day" in
  1|21|31) suffix="st" ;;
  2|22)    suffix="nd" ;;
  3|23)    suffix="rd" ;;
  *)       suffix="th" ;;
esac

# Month name
case "$month_num" in
  01) month="Jan" ;;
  02) month="Feb" ;;
  03) month="Mar" ;;
  04) month="Apr" ;;
  05) month="May" ;;
  06) month="June" ;;
  07) month="July" ;;
  08) month="Aug" ;;
  09) month="Sept" ;;  # or "Sep" if you prefer
  10) month="Oct" ;;
  11) month="Nov" ;;
  12) month="Dec" ;;
esac

sketchybar --set "$NAME" label="${day}${suffix} of ${month} ${time}"

