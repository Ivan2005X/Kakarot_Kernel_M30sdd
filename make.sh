#
#!/bin/bash

echo "Setting Up Environment"
echo ""
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11.0.0

# Export KBUILD flags
export KBUILD_BUILD_USER=neel0210
export KBUILD_BUILD_HOST=hell

# CCACHE
export CCACHE="$(which ccache)"
export USE_CCACHE=1
ccache -M 50G
export CCACHE_COMPRESS=1

# TC LOCAL PATH
export CROSS_COMPILE=$(pwd)/gcc/bin/aarch64-linux-android-
export CLANG_TRIPLE=$(pwd)/clang/bin/aarch64-linux-gnu-
export CC=$(pwd)/clang/bin/clang

# Check if have gcc/32 & clang folder
if [ ! -d gcc ]; then
   git clone --depth 1 git://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
fi

if [ ! -d clang ]; then
   git clone --depth 1 https://github.com/kdrag0n/proton-clang.git clang
fi

echo "======================="
echo "Making kernel with ZIP"
echo "======================="
make clean && make mrproper
rm -rf out
rm ./arch/arm64/boot/Image
rm ./arch/arm64/boot/Image.gz
rm ./Image
rm ./output/*.zip
rm ./PRISH/AIK/image-new.img
rm ./PRISH/AIK/ramdisk-new.cpio.empty
rm ./PRISH/AIK/split_img/boot.img-zImage
rm ./PRISH/AK/Image
rm ./PRISH/ZIP/PRISH/D/M30S/boot.img
rm ./PRISH/AK/*.zip
clear
echo "======================="
echo "Making kernel with ZIP"
echo "======================="
. usr/magisk/update_magisk.sh
make m30sdd_defconfig O=out CC=clang
make -j16 O=out CC=clang
echo "Kernel Compiled"
echo ""
echo "======================="
echo "Packing Kernel INTO ZIP"
echo "======================="
echo ""
cp -r ./out/arch/arm64/boot/Image ./PRISH/AIK/split_img/boot.img-zImage
cp -r ./out/arch/arm64/boot/Image ./PRISH/AK/Image
./PRISH/AIK/repackimg.sh
cp -r ./PRISH/AIK/image-new.img ./PRISH/ZIP/PRISH/D/M30S/boot.img
cd PRISH/ZIP
echo "=========================="
echo "Packing and uploading zip"
echo "=========================="
./zip.sh
cd ../..
if [ ! True ]; then
set -o pipefail
fi

changelog=`cat PRISH/changelog.txt`
for i in output/*.zip
do
curl -F "document=@$i" --form-string "caption=$changelog" "https://api.telegram.org/bot${BOT_ID}/sendDocument?chat_id=${CHAT_ID}&parse_mode=HTML"
done

echo ""
echo "Cleaning"
echo ""
rm -rf PRISH/AIK/image-new.img
rm -rf PRISH/AIK/split_img/boot.img-zImage
rm -rf PRISH/AK/Image
rm -rf PRISH/ZIP/PRISH/D/M30S/boot.img
echo ""