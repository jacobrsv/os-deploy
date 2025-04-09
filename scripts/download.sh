#!/bin/sh

#
# Downloader og skriver disk images til disk
#
# Læs parameter
DISK="$1"
URL="$2"

echo " Fandt disk $DISK "

case "$DISK" in
	/dev/sd*)
		EFI_PART="$DISK"1
		MSR_PART="$DISK"2
		NTFS_PART="$DISK"3
		;;
	/dev/nvme*)
		echo "Disk type er NVME"
		EFI_PART="$DISK"p1
		MSR_PART="$DISK"p2
		NTFS_PART="$DISK"p3
		;;
esac

echo "EFI partition:  $EFI_PART"
echo "MSR partition:  $MSR_PART"
echo "Data partition: $NTFS_PART"

sleep 3

echo "Downloading EFI partition..."
curl -s $URL/image/windows_efi.img.zst | zstd --decompress --stdout | dd of="$EFI_PART" bs=512k

echo "Downloading MSR partition"
curl -s $URL/image/windows_msr.img.zst | zstd --decompress --stdout | dd of="$MSR_PART" bs=512k

echo "Downloading main data partition"
curl -s $URL/image/win11.ntfs.zst2 | zstd --decompress --stdout | pv --rate --timer -p --size=12G | ntfsclone -f -r -O "$NTFS_PART" /dev/stdin
sync

echo "Creating EFI boot entry"
efibootmgr --create --disk $DISK --part 1 --label "Windows Boot Manager" --loader "\EFI\Microsoft\Boot\bootmgfw.efi"
echo ""
echo "Done!"
echo ""
