#!/bin/sh

if [ $GNU_SCREEN_MULTIUSER = true 2>/dev/null ] ; then
    screen -X eval 'multiuser off' 'echo "Multiuser mode disable"' 'setenv "GNU_SCREEN_MULTIUSER" "false"'
else
    screen -X eval 'multiuser on' 'echo "Multiuser mode enable"' 'setenv "GNU_SCREEN_MULTIUSER" "true"'
fi
