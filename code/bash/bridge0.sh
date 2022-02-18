#!/usr/bin/bash

ip link add br0 type bridge
ip addr add 10.0.0.100/24 dev br0
ip link set br0 up
ip link set net0 up
ip link set net0 master br0
brctl show
