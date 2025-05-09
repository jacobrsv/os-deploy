#!/bin/sh
###############################################################################
######          KEA IT-Teknolog, 4. semester afsluttende projekt         ######
###                               OS-Deploy                                 ###
######                      Jacob Rusch Svendsen                         ######
###############################################################################
clear

# tekstfarve
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'       # Reset til alm. tekst
# Styles
BOLD='\033[1m'
UNDERLINE='\033[4m'

printf "${BOLD}${YELLOW}\n\n"
printf "    ╭────────────────────╮\n"
printf "    │                    │\n"
printf "    │ ${UNDERLINE}Starter OS-DEPLOY!${RESET}${BOLD}${YELLOW} │\n"
printf "    │                    │\n"
printf "    ╰────────────────────╯\n"
printf "${RESET}\n\n"

printf "${BOLD}${GREEN}    IP address: ${RESET}${BOLD}"
ip -brief address
printf "\n\n"

### Find passende disk
# List diske med NAME og SIZE som kolonner  |
# inverted match NAME                       |
# sortér på reversed,bytes                  |
# Kun første linje                          |
# awk printer første felt
BIGGEST_DEVICE=$(lsblk -b -o NAME,SIZE | grep -v NAME | sort -k2 -nr | head -n1 | awk '{print $1}')
DISK="/dev/$BIGGEST_DEVICE"
URL="http://osdeploy.internal:8000"
printf "\n\n    ${BOLD}${GREEN}Klargører disk${RESET}\n\n"
sh <(curl -s "$URL"/scripts/format.sh) $DISK
sh <(curl -s "$URL"/scripts/download.sh) $DISK $URL
