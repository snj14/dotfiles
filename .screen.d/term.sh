#!/bin/sh

if [ $TERM = xterm-256color ]; then
   # erase background with current bg color
   # do not use 'screen-bce'
   screen -X eval "defbce \"on\"" "term xterm-256color"
else
   screen -X eval "echo \"hoge\""
fi
