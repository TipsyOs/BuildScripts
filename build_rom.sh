#!/bin/bash

# Colorize and add text parameters
grn=$(tput setaf 2)             #  green
txtbld=$(tput bold)             # Bold
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
MODE="$2"

# Time of build startup
res1=$(date +%s.%N)

# Reading mode
if [ ! -z $MODE ]; then
    if [ $MODE == "r" ] || [ $MODE == "cr" ]; then
        echo -e "${bldblu}Set release build flag ${txtrst}"
        export IS_RELEASED_BUILD=true
    else
        export IS_RELEASED_BUILD=
    fi

    if [ $MODE == "c" ] || [ $MODE == "cr" ]; then
       echo -e "${bldblu}Cleaning up out folder ${txtrst}"
       make clobber;
    fi
else
    export IS_RELEASED_BUILD=
fi

# Setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

# Prebuilt chromium
# export USE_PREBUILT_CHROMIUM=1

# Lunch device
echo -e "${bldblu}Lunching device... ${txtrst}"
lunch "tipsy_$DEVICE-userdebug"

#copy bootanimation if needed
if [ ! -f "prebuilts/chromium/$1/media/bootanimation.zip" ]; then
	echo "${bldblu}let's copy the bootanimation to the prebuilts directory if needed ${txtrst}"
	mkdir -p prebuilts/chromium/$1/media
	cp vendor/tipsy/config/media/bootanimation.zip prebuilts/chromium/$1/media/bootanimation.zip
	echo "${bldblu}Bootanimation copied ${txtrst}"
    else
	echo "${bldblu}Bootanimation exists ${txtrst}"
fi

# Remove previous build info
echo -e "${bldblu}Removing previous build.prop and zip ${txtrst}"
make dirty

# Start compilation
echo -e "${bldblu}Starting build for $DEVICE ${txtrst}"
mka tipsy

# Get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"

