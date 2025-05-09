#!/bin/sh
###############################################################################
######          KEA IT-Teknolog, 4. semester afsluttende projekt         ######
###                               OS-Deploy                                 ###
######                      Jacob Rusch Svendsen                         ######
###############################################################################
#
# Downloader og skriver disk images til disk
#

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
URL="$2"

# Lav forskellige variabler hvis disken er nvme eller ikke
case "$DISK" in
	/dev/sd*)
		EFI_PART="$DISK"1
		MSR_PART="$DISK"2
		NTFS_PART="$DISK"3
		;;
	/dev/nvme*)
		EFI_PART="$DISK"p1
		MSR_PART="$DISK"p2
		NTFS_PART="$DISK"p3
		;;
esac

printf "\n\n${BOLD}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │    Arbejder på ${RESET}${DISK}${BOLD}\n"
printf "    │    Partitioner:                   │\n"
printf "    │    EFI : ${RESET}${EFI_PART}${BOLD}\n"
printf "    │    MSR : ${RESET}${MSR_PART}${BOLD}\n"
printf "    │    NFTS: ${RESET}${NTFS_PART}${BOLD}\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"

#sleep 3
#read -p "Tryk enter for at fortsætte"

printf "\n${BOLD}${GREEN}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │ Downloading EFI partition...      │\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"
curl -s $URL/image/windows_efi2.img.zst | zstd --decompress --stdout | dd of="$EFI_PART" bs=512k

printf "\n${BOLD}${GREEN}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │ Downloading MSR partition...      │\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"
curl -s $URL/image/windows_msr2.img.zst | zstd --decompress --stdout | dd of="$MSR_PART" bs=512k

printf "\n${BOLD}${GREEN}"
printf "    ╭───────────────────────────────────╮\n"
printf "    │ Downloading NTFS partition...     │\n"
printf "    ╰───────────────────────────────────╯\n\n${RESET}"
printf "${BOLD}${CYAN}"
curl -s $URL/image/sysprepped_unattend.ntfs.zst | zstd --decompress --stdout | pv -c --name "Writing Windows partition to disk" --rate --timer -p --size=20G | ntfsclone -f -r -O "$NTFS_PART" /dev/stdin
# Synchronize cached writes
sync

#echo "Creating EFI boot entry"
#efibootmgr --create --disk $DISK --part 1 --label "Windows Boot Manager" --loader "\EFI\Microsoft\Boot\bootmgfw.efi"

printf "\n${BOLD}${GREEN}\n\n"
printf "    ╭───────────────────────────────────╮\n"
printf "    │                                   │\n"
printf "    │               Done!               │\n"
printf "    │      Rebooting in 3 seconds...    │\n"
printf "    │                                   │\n"
printf "    ╰───────────────────────────────────╯\n\n\n\n${RESET}"
printf "${BOLD}$"

sleep 1
printf "    3    "
sleep 1
printf "    2    "
sleep 1
printf "    1    \n\n\n\n\n\n\n\n\n\n\n"
sleep 1
reboot
