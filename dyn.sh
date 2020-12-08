#!/bin/bash

#Variables
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
payload_extractor="$LOCALDIR/payload/payload_dumper.py"
outdir="$LOCALDIR/cache"
tmpdir="$LOCALDIR/cache/tmp"

#let's start
echo "Create temp and cache dir"
	mkdir -p "$outdir"
	mkdir -p "$tmpdir"

echo "Extracting Required Partitions . . . . "
if [ $1 = "Generic" ]; then
	bash $LOCALDIR/zip2img.sh $2 $outdir
	mv $outdir/system.img $outdir/system-old.img
elif [ $1 = "MIUI" ]; then
	bash $LOCALDIR/zip2img.sh $2 $outdir
	mv $outdir/system.img $outdir/system-old.img
elif [ $1 = "OxygenOS" ]; then
        unzip $2 -d $tmpdir &> /dev/null
        python $payload_extractor --out $outdir $tmpdir/payload.bin &> /dev/null
        mv $outdir/system.img $outdir/system-old.img
elif [ $1 = "Pixel" ]; then
        unzip $2 -d $tmpdir &> /dev/null
	unzip $tmpdir/*/*.zip -d $tmpdir &> /dev/null
	simg2img $tmpdir/system.img $outdir/system-old.img
	simg2img $tmpdir/product.img $outdir/product.img
	simg2img $tmpdir/system_other.img $outdir/system_other.img
 	if [ -f "$tmpdir/system_ext.img" ]; then
	simg2img $tmpdir/system_ext.img $outdir/system_ext.img
	fi
fi
rm -rf $tmpdir
echo "Creating Dummy System Image . . . . "
dd if=/dev/zero of=$outdir/system.img bs=4k count=1048576
mkfs.ext4 $outdir/system.img
tune2fs -c0 -i0 $outdir/system.img
echo "Merging system . . . . "
	mkdir system
	mkdir system-old
	mount -o loop $outdir/system.img system/
	mount -o ro $outdir/system-old.img system-old/
	cp -v -r -p system-old/* system/ &> /dev/null
	sync
	umount system-old
	rm $outdir/system-old.img
        rmdir system-old/
echo "Merging product . . . . "
        rm -rf system/product
        ln -s system/product system/product
        rm -rf system/system/product
        mkdir system/system/product
	mkdir $outdir/product
	mount -o ro $outdir/product.img $outdir/product
	cp -v -r -p $outdir/product/* system/system/product/ &> /dev/null
	sync
	umount $outdir/product
	rmdir $outdir/product/
	rm $outdir/product.img
if [ -f "$outdir/system_ext.img" ]; then
echo "Merging system_ext . . . . "
            mkdir $outdir/system_ext
            mount -o ro $outdir/system_ext.img $outdir/system_ext/
            rm -rf system/system_ext
            rm -rf system/system/system_ext
            mkdir system/system/system_ext
            ln -s system/system_ext system/system_ext
            cp -v -r -p $outdir/system_ext/* system/system/system_ext/ &> /dev/n$
            sync
            umount $outdir/system_ext
            rmdir $outdir/system_ext/
            rm $outdir/system_ext.img
fi
if [ $1 = "OxygenOS" ]; then
     if [ -f "$outdir/opproduct.img" ]; then
	echo "Merging opproduct . . . . "
	sudo mkdir $outdir/opproduct
	mount -o ro $outdir/opproduct.img $outdir/opproduct/
	cp -v -r -p $outdir/opproduct/* system/oneplus/ &> /dev/null
	sync
	umount $outdir/opproduct
	rmdir $outdir/opproduct/
	rm $outdir/opproduct.img
     fi
     if [ -f "$outdir/reserve.img" ]; then
	echo "Merging reserve . . . . "
        rm -rf system/system/reserve
        mkdir system/system/reserve
	mkdir $outdir/reserve
	mount -o ro $outdir/reserve.img $outdir/reserve/
	cp -v -r -p $outdir/reserve/* system/system/reserve/ &> /dev/null
	sync
	umount $outdir/reserve
	rmdir $outdir/reserve/
	rm $outdir/reserve.img
     if [ -f "$outdir/india.img" ]; then
	echo "Merging india . . . . "
        rm -rf system/system/india
        mkdir system/system/india
	mkdir $outdir/india
	mount -o ro $outdir/india.img $outdir/india/
	cp -v -r -p $outdir/india/* system/system/india/ &> /dev/null
	sync
	umount $outdir/india
	rmdir $outdir/india/
	rm $outdir/india.img
     fi
	echo "Merging overlays . . . . "
	mkdir $outdir/vendor
	mount -o ro $outdir/vendor.img $outdir/vendor/
	cp -r $outdir/vendor/overlay $outdir
	rm -rf $outdir/overlay/*.apk
	cp -v -r -p $outdir/overlay/* system/system/product/overlay/ &> /dev/null
	sync
	rm -rf $outdir/overlay
	umount $outdir/vendor
	rmdir $outdir/vendor/
	rm $outdir/vendor.img
elif [ $1 = "Pixel" ]; then
echo "Merging system_other . . . . "
	mkdir $outdir/system_other
	mount -o ro $outdir/system_other.img $outdir/system_other/
	cp -v -r -p $outdir/system_other/* system/system/ &> /dev/null
	sync
	umount $outdir/system_other
	rmdir $outdir/system_other/
	rm $outdir/system_other.img
fi
echo "Finalising "
        cp -r system working/ &> /dev/null
	umount system
        rm -rf cache
	rm -rf system
        rm -rf $outdir/system.img
echo "Generated Dynamic Folder"
