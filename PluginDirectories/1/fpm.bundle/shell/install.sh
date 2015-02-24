#!/bin/bash

URL=$1
DEST=$2

CWD=$(mktemp -d /tmp/flashlight.XXXXX)

curl -L $URL -o "${CWD}/${DEST}.zip"
unzip "${CWD}/${DEST}.zip" -d "${CWD}"
#Install the plugin as disabled at first
cp -r "${CWD}/${DEST}-master" "${HOME}/Library/FlashlightPlugins/${DEST}.disabled-bundle"
#and then enable it
mv "${HOME}/Library/FlashlightPlugins/${DEST}.disabled-bundle" "${HOME}/Library/FlashlightPlugins/${DEST}.bundle"
rm -r $CWD

osascript -e "display notification \"${DEST} has been installed\" with title \"Flashlight Package Manager\""