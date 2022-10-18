#!/bin/sh
 
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

setxkbmap -layout us,gr -option grp:alt_shift_toggle

xbindkeys

exec i3

