#!/bin/bash

URL=$1
DEST=$2

CWD=$(mktemp -d /tmp/flashlight.XXXXX)

curl -L $URL -o "${CWD}/${DEST}.zip"
unzip "${CWD}/${DEST}.zip" -d "${CWD}"
cp -r "${CWD}/${DEST}-master" "${HOME}/Library/FlashlightPlugins/${DEST}.bundle"
rm -r $CWD

osascript -e "display notification \"${DEST} has been installed\" with title \"Flashlight Package Manager\""