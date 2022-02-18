#!/bin/bash

qemu-system-x86_64 --enable-kvm -m $1G \
-vga qxl -drive file=$2,format=raw \
-spice unix,addr=/tmp/vm_spice_$2.socket,disable-ticketing \
-device virtio-serial-pci \
-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
-chardev spicevmc,id=spicechannel0,name=vdagent \
-daemonize \
&& \
remote-viewer spice+unix:///tmp/vm_spice_$2.socket &
