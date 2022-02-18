#!/bin/bash

qemu-system-x86_64 --enable-kvm -m $1G \
-vga qxl -drive file=$2,format=raw \
-spice unix,addr=/tmp/vm_spice_$2.socket,disable-ticketing \
-device virtio-serial-pci \
-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
-chardev spicevmc,id=spicechannel0,name=vdagent \
-device ich9-usb-ehci1,id=usb \
-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \
-chardev spicevmc,name=usbredir,id=usbredirchardev1 \
-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \
-chardev spicevmc,name=usbredir,id=usbredirchardev2 \
-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
-daemonize \
&& \
remote-viewer spice+unix:///tmp/vm_spice_$2.socket &
