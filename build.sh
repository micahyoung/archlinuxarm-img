#!/bin/bash

set -ex

outdir=$1
size_mbytes=${2:-2000} #2GB default
tmpdir=tmp/
latest_url=http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
sector_bytes=512
mbr_sectors=2048
boot_start_sectors=2048
boot_sectors=204800
root_start_sectors=206848
#root_sectors=3889152
root_sectors=$((($size_mbytes * 1000000 / $sector_bytes) - $boot_start_sectors))
boot_start_bytes=$(($boot_start_sectors * $sector_bytes))
root_start_bytes=$(($root_start_sectors * $sector_bytes))

if [ ! -d "$outdir" ]; then 
  echo "usage: build.sh out_dir [size_mbs]"
  exit 1
fi

if [ $size_mbytes -lt 2000 ]; then 
  echo "Size $size_mbytes must be greater than 2,000MB"
  exit 1
fi

if [ ! -d "$tmpdir" ]; then 
  mkdir $tmpdir
fi

pushd $tmpdir/
	wget --timestamping $latest_url -O alarpmi.tgz

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

	tar -xzpf alarpmi.tgz -C ./root

	mv ./root/boot/* ./boot

	sync

	umount ./boot ./root
popd

mv $tmpdir/archlinux.img $outdir/
