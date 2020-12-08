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
echo "Merging system . . . . "
	sudo mkdir system-new
	sudo mkdir system-old
	mount -o ro $outdir/system-old.img system-old/
	cp -v -r -p system-old/* system-new/ &> /dev/null
	umount system-old
	rm -rf $outdir/system-old.img
        rm -rf system-old/
if [ -f "$outdir/product.img" ]; then
echo "Merging product . . . . "
        rm -rf system-new/product
        ln -s system-new/product system-new/product
        rm -rf system-new/system/product
        sudo mkdir system-new/system/product
	sudo mkdir $outdir/product
	mount -o ro $outdir/product.img $outdir/product
	cp -v -r -p $outdir/product/* system-new/system/product/ &> /dev/null
	umount $outdir/product
	rmdir $outdir/product/
	rm $outdir/product.img
fi
if [ -f "$outdir/system_ext.img" ]; then
echo "Merging system_ext . . . . "
            sudo mkdir $outdir/system_ext
            mount -o ro $outdir/system_ext.img $outdir/system_ext/
            rm -rf system-new/system_ext
            rm -rf system-new/system/system_ext
            sudo mkdir system-new/system/system_ext
            ln -s system-new/system_ext system-new/system_ext
            cp -v -r -p $outdir/system_ext/* system-new/system/system_ext/ &> /dev/n$
            umount $outdir/system_ext
            rm -rf $outdir/system_ext/
            rm -rf $outdir/system_ext.img
fi
if [ $1 = "OxygenOS" ]; then
     if [ -f "$outdir/opproduct.img" ]; then
	echo "Merging opproduct . . . . "
	sudo mkdir $outdir/opproduct
	mount -o ro $outdir/opproduct.img $outdir/opproduct/
	cp -v -r -p $outdir/opproduct/* system-new/oneplus/ &> /dev/null
	umount $outdir/opproduct
	rmdir $outdir/opproduct/
	rm $outdir/opproduct.img
     fi
     if [ -f "$outdir/reserve.img" ]; then
	echo "Merging reserve . . . . "
        rm -rf system-new/system/reserve
        sudo mkdir system-new/system/reserve
	sudo mkdir $outdir/reserve
	mount -o ro $outdir/reserve.img $outdir/reserve/
	cp -v -r -p $outdir/reserve/* system-new/system/reserve/ &> /dev/null
	umount $outdir/reserve
	rmdir $outdir/reserve/
	rm $outdir/reserve.img
     if [ -f "$outdir/india.img" ]; then
	echo "Merging india . . . . "
        rm -rf system-new/system/india
        sudo mkdir system-new/system/india
	sudo mkdir $outdir/india
	mount -o ro $outdir/india.img $outdir/india/
	cp -v -r -p $outdir/india/* system-new/system/india/ &> /dev/null
	umount $outdir/india
	rmdir $outdir/india/
	rm $outdir/india.img
     fi
	echo "Merging overlays . . . . "
	sudo mkdir $outdir/vendor
	mount -o ro $outdir/vendor.img $outdir/vendor/
	cp -r $outdir/vendor/overlay $outdir
	rm -rf $outdir/overlay/*.apk
	cp -v -r -p $outdir/overlay/* system-new/system/product/overlay/ &> /dev/null
	rm -rf $outdir/overlay
	umount $outdir/vendor
	rmdir $outdir/vendor/
	rm $outdir/vendor.img
elif [ $1 = "Pixel" ]; then
echo "Merging system_other . . . . "
	sudo mkdir $outdir/system_other
	mount -o ro $outdir/system_other.img $outdir/system_other/
	cp -v -r -p $outdir/system_other/* system-new/system/ &> /dev/null
	umount $outdir/system_other
	rmdir $outdir/system_other/
	rm $outdir/system_other.img
fi
echo "Finalising "
        cp -r system-new working/ &> /dev/null
        rm -rf cache
	rm -rf system-new
echo "Done . . . . "
