#!/bin/sh

echo "Trash Before:"
du -sh ~/.local/share/Trash
rm -rf ~/.local/share/Trash/*
echo
echo "Trash After:"
du -sh ~/.local/share/Trash
echo
echo
echo "Pacman Cache Before:"
ls /var/cache/pacman/pkg/ | wc -l
du -sh /var/cache/pacman/pkg/
paccache -rk1
paccache -ruk0
echo
echo "Pacman Cache After:"
ls /var/cache/pacman/pkg/ | wc -l
du -sh /var/cache/pacman/pkg/
echo
echo
echo "Chromium Cache Before:"
du -sh ~/.cache/chromium/Default/
du -sh ~/.config/chromium/Default/
rm -rf ~/.config/chromium/Default/
rm -rf ~/.cache/chromium/Default/
echo
echo "Chromium Cache After:"
du -sh ~/.cache/chromium/Default/
du -sh ~/.config/chromium/Default/
echo
echo
echo "Firefox Cache Before:"
du -sh ~/.mozilla/firefox/*.default/*.sqlite
du -sh ~/.cache/mozilla/firefox/*.default
#rm ~/.mozilla/firefox/*.default/*.sqlite
#rm -r ~/.cache/mozilla/firefox/*.default/*
echo
echo "Firefox Cache After:"
du -sh ~/.mozilla/firefox/*.default/*.sqlite
du -sh ~/.cache/mozilla/firefox/*.default
echo
