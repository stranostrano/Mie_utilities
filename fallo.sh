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
DTBIMAGE="dtb"
DEFCONFIG="msm8974_find7op_defconfig"

# Kernel Details
BASE_DN_VER="StranoStrano"
VER="_OPO_OMNI_ver.1.4"
DN_VER="$BASE_DN_VER$VER"

# Vars
export LOCALVERSION=~`echo $DN_VER`
export CROSS_COMPILE=${HOME}/android/uber/bin/arm-eabi-
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=stranostrano
export KBUILD_BUILD_HOST=build.machine

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/android/AnykernelOMNI"
PATCH_DIR="${HOME}/android/AnykernelOMNI/patch"
# MODULES_DIR="${HOME}/android/AnykernelOMNI/modules"
ZIP_MOVE="${HOME}/android/OUT"
ZIMAGE_DIR="${HOME}/android/stranostrano/arch/arm/boot"

# Functions
function clean_all {
#		rm -rf $MODULES_DIR/*
		cd $REPACK_DIR
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
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

# function make_modules {
#		rm `echo $MODULES_DIR"/*"`
#		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
# }

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm/boot/
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 `echo $DN_VER`.zip *
		mv  `echo $DN_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"

echo "-------------------"
echo "Versione del kernel:"
echo "-------------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$DN_VER"; echo -e "${restore}";

echo -e "${green}"
echo "--------------------------"
echo "Compilazione dello StranoStrano Kernel:"
echo "--------------------------"
echo -e "${restore}"

while read -p "Vuoi eliminare i file della vecchia compilazione (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "Vecchia compilazione eliminata"
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Non valido provare di nuovo!"
		echo
		;;
esac
done

echo

while read -p "Hai già controllato la versione e vuoi compilare il nuovo kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_dtb
#		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Non valido provare di nuovo!"
		echo
		;;
esac
done

echo -e "${green}"
echo "--------------------------"
echo "Compilazione completata in:"
echo "--------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Tempo: $(($DIFF / 60)) minuti e $(($DIFF % 60)) secondi."
echo

