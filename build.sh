#!/bin/bash

set -ex

outdir=$1
tmpdir=tmp/
latest_url=http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
sector_bytes=512
mbr_sectors=2048
boot_start_sectors=2048
boot_sectors=204800
root_start_sectors=206848
root_sectors=3889152
boot_start_bytes=$(($boot_start_sectors * $sector_bytes))
root_start_bytes=$(($root_start_sectors * $sector_bytes))

if [ ! -d "$outdir" ]; then 
  echo "outdir required"
  exit 1
fi

if [ ! -d "$tmpdir" ]; then 
  mkdir $tmpdir
fi

pushd $tmpdir/
	dd if=/dev/zero of=mbr.img  bs=$sector_bytes count=$mbr_sectors
	dd if=/dev/zero of=boot.img bs=$sector_bytes count=$boot_sectors
	dd if=/dev/zero of=root.img bs=$sector_bytes count=$root_sectors

	mkfs.vfat boot.img
	mkfs.ext4 root.img

	cat mbr.img boot.img root.img > archlinux.img

	sfdisk archlinux.img <<EOF
label: dos
label-id: 0x02fc30b8
device: archlinux.img
unit: sectors

archlinux.img1 : start=$boot_start_sectors, size=$boot_sectors, type=c
archlinux.img2 : start=$root_start_sectors, size=$root_sectors, type=83
EOF

	mkdir ./boot ./root

	mount -o loop,offset=$boot_start_bytes archlinux.img ./boot
	mount -o loop,offset=$root_start_bytes archlinux.img ./root

	wget --timestamping $latest_url
	tar -xzpf ArchLinuxARM-rpi-latest.tar.gz -C ./root

	mv ./root/boot/* ./boot

	sync

	umount ./boot ./root
popd

mv $tmpdir/archlinux.img $outdir/
