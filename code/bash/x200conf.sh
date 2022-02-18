#!/bin/bash

setxkbmap -layout us,gr && setxkbmap -option grp:rctrl_toggle

sudo rfkill block bluetooth

sudo rmmod pcspkr
