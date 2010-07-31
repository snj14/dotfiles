#!/bin/sh

screen -X eval "msgminwait 0" "copy" "stuff \"W\"" "at rdic stuff \"\"" "at rdic paste \".\"" "msgminwait 1" "select rdic"
