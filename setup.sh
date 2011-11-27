#!/bin/sh


cd $(dirname $0)

for dotfile in .?*
do

    if [ ${dotfile} != '..' ] && [ ${dotfile} != '.git' ]
    then
        echo ;
        echo create $PWD/$dotfile ...
        ln -is "$PWD/$dotfile" $HOME/
    fi

done


ln -is "$PWD/bin" $HOME/

