#!/bin/sh
###############################################################################
######          KEA IT-Teknolog, 4. semester afsluttende projekt         ######
###                               OS-Deploy                                 ###
######                      Jacob Rusch Svendsen                         ######
###############################################################################
#
# Formaterer føste nvme disk til en Windows-installation
# 315MB EFI partition
# 16MB MSR partition
# resten til en NTFS partition
#
set -e

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

# Læs parameter
DISK="$1"

printf "\n\n${BOLD}${GREEN}"
printf "    ╭──────────────────────╮\n"
printf "    │ Disk fundet: $DISK \n"
printf "    ╰──────────────────────╯\n\n${RESET}"

printf "${BOLD}====================================================================================${RESET}\n"
# Vis nuværende disklayout til brugeren
fdisk -l $DISK
printf "${BOLD}====================================================================================${RESET}\n\n"
###
printf "${BOLD}${RED}${UNDERLINE}⚠ Sletter alle filsystemer, tryk CTRL+C for at afbryde! ⚠${RESET}\n${BOLD}"
sleep 1
printf "    3    "
sleep 1
printf "    2    "
sleep 1
printf "    1    \n\n"
sleep 1

printf "${BOLD}${GREEN}Wiping $DISK${RESET}\n\n"
printf "${BOLD}====================================================================================${RESET}\n"
# Slet alle filsystmer med wipefs og sgdisk.
wipefs --all $DISK
sgdisk --zap-all $DISK
printf "${BOLD}====================================================================================${RESET}\n\n"
printf "\n\n${BOLD}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │ Creating 3 partitions             │\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"
sgdisk --new "1:1m:+315M" --typecode=1:ef00 --change-name=1:"EFI" "$DISK"
printf "\n${BOLD}${GREEN}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │ Created EFI partition             │\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"
sgdisk --new "2:0:+16M" --typecode=2:0C01 --change-name=2:"Microsoft Reserved" "$DISK"
printf "\n${BOLD}${GREEN}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │ Created MSR partition             │\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"
sgdisk --new "3:0:0" --typecode=3:0700 --change-name=3:"Microsoft Basic Data" "$DISK"
printf "\n${BOLD}${GREEN}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │ Created Microsoft NTFS partition  │\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"
printf "${BOLD}====================================================================================${RESET}\n"
fdisk -l $DISK
printf "${BOLD}====================================================================================${RESET}\n\n"


# partprobe "$DISK" 2>/dev/null
## Scan diske og partitioner
mdev -s
