#
#!/bin/bash

echo "Setting Up Environment"
echo ""

# Check if have gcc/32 & clang folder
if [ ! -d "$(pwd)/gcc/" ]; then
   git clone --depth 1 git://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
fi

if [ ! -d "$(pwd)/clang/" ]; then
   git clone --depth 1 https://github.com/kdrag0n/proton-clang.git clang
fi

export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11.0.0
KERNEL_DIR=$PWD
DATE=$(TZ=Asia/Delhi date +"%Y%m%d-%T")

# Kernel
export DEFCONFIG=m30sdd_defconfig

# Export KBUILD flags
export KBUILD_BUILD_USER=neel0210
export KBUILD_BUILD_HOST=hell

# CCACHE
export CCACHE="$(which ccache)"
export USE_CCACHE=1
ccache -M 50G
export CCACHE_COMPRESS=1

# TC LOCAL PATH
#export CROSS_COMPILE=$(pwd)/gcc/bin/aarch64-linux-android-
#export CLANG_TRIPLE=$(pwd)/clang/bin/aarch64-linux-gnu-
#export CC=$(pwd)/clang/bin/clang
PATH=$KERNEL_DIR/clang/bin/:$KERNEL_DIR/gcc/bin/:$PATH
export CROSS_COMPILE=$KERNEL_DIR/gcc/bin/aarch64-linux-android-
export CC=$KERNEL_DIR/clang/bin/clang
export AR=$KERNEL_DIR/clang/bin/llvm-ar
export NM=$KERNEL_DIR/clang/bin/llvm-nm
export OBJCOPY=$KERNEL_DIR/clang/bin/llvm-objcopy
export OBJDUMP=$KERNEL_DIR/clang/bin/llvm-objdump
export STRIP=$KERNEL_DIR/clang/bin/llvm-strip

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
make $DEFCONFIG O=out CC=clang
BUILD_START=$(date +"%s")
make $DEFCONFIG -j16 O=out CC=clang | tee compile.log
BUILD_END=$(date +"%s")
DIFF=$((BUILD_END - BUILD_START))
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
echo "==========================="
echo "Packing into Flashable zip"
echo "==========================="
./zip.sh
cd ../..
echo "======================="
