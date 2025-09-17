#!/usr/bin/env bash
ASCII_ART="    __                      __     
   / /_  ____ _      ______/ /_  __
  / __ \/ __ \ | /| / / __  / / / /
 / / / / /_/ / |/ |/ / /_/ / /_/ / 
/_/ /_/\____/|__/|__/\__,_/\__, /  
                          /____/   "

USERNAME=$(whoami)
HOSTNAME=$(hostname)

BRIGHT_BLACK="\033[90m"
CYAN="\033[36m"
RED="\033[31m"
MAGENTA="\033[35m"
RESET="\033[0m"

USERICON=" "

echo "${MAGENTA}${ASCII_ART}${RESET}"

BORDER_LENGTH=$(( ${#USERNAME} + ${#HOSTNAME} + ${#USERICON} +3 ))

BORDER=$(printf '%*s' "$BORDER_LENGTH" '' | tr ' ' '─')

echo "${BRIGHT_BLACK}┌${BORDER}┐${RESET}"
echo "${BRIGHT_BLACK}│ ${RESET}${USERICON}${CYAN}${USERNAME}${RESET}${BRIGHT_BLACK}@${RED}${HOSTNAME}${RESET}${BRIGHT_BLACK} │${RESET}"
echo "${BRIGHT_BLACK}└${BORDER}┘${RESET}"
echo ""
