#!/bin/sh

#
# Formaterer føste nvme disk til en Windows-installation
# 315MB EFI partition
# 16MB MSR partition
# resten til en NTFS partition
#
# Læs parameter
DISK="$1"

echo " Disk fundet: $DISK "
echo ""
echo "████████████████████████████████████████████"
fdisk -l $DISK
echo "████████████████████████████████████████████"
###
echo "⚠ Sletter alle filsystemer, tryk CTRL+C for at afbryde! ⚠"
sleep 1
echo "  3"
sleep 1
echo "  2"
sleep 1
echo "  1"
sleep 1

echo "Wiping $DISK"
wipefs --all $DISK
sgdisk --zap-all $DISK

echo " ███ Creating 3 partitons                        █"
sgdisk --new "1:1m:+315M" --typecode=1:ef00 --change-name=1:"EFI" "$DISK"
echo " ███ Created EFI partition                      ██ "
sgdisk --new "2:0:+16M" --typecode=2:0C01 --change-name=2:"Microsoft Reserved" "$DISK"
echo " ███ Created MSR parititon                      ██ "
sgdisk --new "3:0:0" --typecode=3:0700 --change-name=3:"Microsoft Basic Data" "$DISK"
echo " ███ Created 'Microsoft Basic Data' partition  ███ "
echo " █████████████████████████████████████████████████"
sgdisk --print "$DISK"

# partprobe "$DISK" 2>/dev/null
## Scan diske og partitioner
mdev -s
