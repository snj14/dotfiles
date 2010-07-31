#!/bin/sh

if [ $GNU_SCREEN_STARTUP = true 2>/dev/null ] ; then
    screen -X eval 'echo "ok"'
else
    screen -X eval 'screen "-t Emacs" "emacs -nw"' 'screen "-t ls"' 'setenv "GNU_SCREEN_STARTUP" "true"'
fi

