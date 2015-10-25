#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="zImage"
DEFCONFIG="ak_mako_defconfig"

# Kernel Details
BASE_AK_VER="AK"
VER=".M2.AOSP"
AK_VER="$BASE_AK_VER$VER"

# Vars
export LOCALVERSION=~`echo $AK_VER`
export CROSS_COMPILE=${HOME}/android/AK-Kernel/Toolchains/uber-arm-eabi-4.9/bin/arm-eabi-
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=CallMeAldy
export KBUILD_BUILD_HOST=Codelax

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/android/AK-Kernel/AK-Mako-AnyKernel2"
PATCH_DIR="${HOME}/android/AK-Kernel/AK-Mako-AnyKernel2/patch"
MODULES_DIR="${HOME}/android/AK-Kernel/AK-Mako-AnyKernel2/modules"
ZIP_MOVE="${HOME}/android/AK-Kernel/AK-Releases"
ZIMAGE_DIR="${HOME}/android/AK-Kernel/AK-Mako-M/arch/arm/boot"

# Functions
function clean_all {
		rm -rf $MODULES_DIR/*
		cd $REPACK_DIR
		rm -rf $KERNEL
		git reset --hard > /dev/null 2>&1
		git clean -f -d > /dev/null 2>&1
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 `echo $AK_VER`.zip *
		mv  `echo $AK_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "AK Kernel Creation Script:"

echo "---------------"
echo "Kernel Version:"
echo "---------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$AK_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making AK Kernel:"
echo "-----------------"
echo -e "${restore}"

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
