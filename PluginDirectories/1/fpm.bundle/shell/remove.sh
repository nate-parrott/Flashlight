#!/bin/bash

NAME=$1

mv "${HOME}/Library/FlashlightPlugins/${NAME}.bundle" "${HOME}/Library/FlashlightPlugins/${NAME}.disabled-bundle"

osascript -e "display notification \"${NAME} has been removed\" with title \"Flashlight Package Manager\""