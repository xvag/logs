#!/bin/bash

virt-install --name $1 --memory $2 --vcpus=2,maxvcpus=4 --cpu=host \
--cdrom $4 --disk size=$3,format=qcow2 --network user --network bridge=br0 \
--graphics=spice --virt-type=kvm --os-type=windows
