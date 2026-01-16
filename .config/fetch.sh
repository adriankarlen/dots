#!/usr/bin/env bash
USERNAME=$(whoami)
HOSTNAME=$(hostname)

BRIGHT_BLACK="\033[90m"
CYAN="\033[36m"
RED="\033[31m"
MAGENTA="\033[35m"
YELLOW="\033[33m"
RESET="\033[0m"

USERICON=" "
BORDER_LENGTH=$((${#USERNAME} + ${#HOSTNAME} + ${#USERICON} + 3))

BORDER=$(printf '%*s' "$BORDER_LENGTH" '' | tr ' ' '─')

echo "${BRIGHT_BLACK}┌${BORDER}┐"
echo "│ ${RESET}${USERICON}${YELLOW}${USERNAME}${BRIGHT_BLACK}@${RED}${HOSTNAME}${RESET}${BRIGHT_BLACK} │"
echo "└${BORDER}┘${RESET}"
