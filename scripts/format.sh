#!/bin/sh

#
# Formaterer føste nvme disk til en Windows-installation
# 315MB EFI partition
# 16MB MSR partition
# resten til en NTFS partition
#

### Find nvme disk
NVME_DISK=$(find /dev -name "nvme[0-9]n[0-9]" | head -1)
echo "NVMe disk fundet: $NVME_DISK"

###
echo "⚠ Sletter alle filsystemer, tryk CTRL+C for at afbryde! ⚠"
sleep 1
echo "  3"
sleep 1
echo "  2"
sleep 1
echo "  1"
sleep 1

echo "Wiping $NVME_DISK"
wipefs --all $NVME_DISK
sgdisk --zap-all $NVME_DISK

echo "Creating 3 partitons"
sgdisk --new "1:1m:+315m" --typecode "1:ef00" "$NVME_DISK"
echo "Created EFI partition"

sgdisk --new=2:0:+16M --typecode=2:0C01 --change-name=2:"Microsoft Reserved" "$NVME_DISK"
echo "Created MSR parititon"

sgdisk --new=3:0:0 --typecode=3:0700 --change-name=3:"Microsoft Basic Data" "$NVME_DISK"
echo "Created 'Microsoft Basic Data' partition"

sgdisk --print "$NVME_DISK"

partprobe "$NVME_DISK" 2>/dev/null
