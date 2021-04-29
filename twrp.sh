# TWRP
echo "Setting Up Environment"
echo ""
curl https://raw.githubusercontent.com/akhilnarang/scripts/master/setup/android_build_env.sh | bash
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

make clean && make mrproper
rm -rf out
echo "Making Kernel"
make $DEFCONFIG O=out CC=clang
make $DEFCONFIG -j16 O=out CC=clang | tee compile.log

mkdir ~/bin
PATH=~/bin:$PATH

curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

echo ""
echo "syncing sources"
mkdir TWRP ; cd TWRP
repo init -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
repo init --depth=1 -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
repo sync --no-repo-verify -c --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune -j64

echo ""
echo "syncing DT"
git clone https://github.com/neel021000/android_device_samsung_m30sdd.git -b TWRP device/samsung/m30sdd
cd ..
echo ""
echo "Push Latest kernel"
cp -r ./out/arch/arm64/boot/Image ./TWRP/device/samsung/m30sdd/prebuilt/zImage

echo ""
echo "Trigger Build"
cd TWRP
. build/envsetup.sh ; lunch omni_m30sdd-eng ; make recoveryimage

echo ""
echo "upload recovery"
cd ..
cp -r ./TWRP/out/target/product/m30sdd/recovery.img ./output/twrp-9-M30sdd.img
for i in output/twrp-9-M30sdd.img
do
curl -F "document=@$i" --form-string "caption=Latest Recovery for M30s" "https://api.telegram.org/bot${BOT_ID}/sendDocument?chat_id=${CHAT_ID}&parse_mode=HTML"
done