#!/bin/sh
clear
echo "____________________________"
echo ""
echo "  Starter OS-DEPLOY script"
echo ""
echo "____________________________"
echo "IP addresses:"
ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/{split($2,_," ");print _[1]}'

# Find passende disk
BIGGEST_DEVICE=$(lsblk -b -o NAME,SIZE | grep -v NAME | sort -k2 -nr | head -n1 | awk '{print $1}')
DISK="/dev/$BIGGEST_DEVICE"
URL="http://10.25.0.54:8000"

echo "Klargører disk"
sh <(curl -s "$URL"/scripts/format.sh) $DISK
sh <(curl -s "$URL"/scripts/download.sh) $DISK $URL
