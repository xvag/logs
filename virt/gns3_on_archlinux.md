##		{--- Dynamips ---}

#### [01] Get and install the dependencies for Dynamips.

`$ sudo pacman -S libelf libpcap cmake`

#### [02] Get and install Dynamips.

I will download and install the latest release (at the date of this post) for my example.<br>
Refer to dynamips (https://github.com/GNS3/dynamips/releases) for specific versions and release notes.
```
$ cd /tmp
$ curl -L https://github.com/GNS3/dynamips/archive/v0.2.17.tar.gz | tar -xz
$ cd dynamips*
$ mkdir build && cd $_
$ cmake ..
$ sudo make install
$ sudo setcap cap_net_admin,cap_net_raw=ep $(which dynamips)
```
#### [03] Verify the version and capabilities for Dynamips.
```
$ cd $HOME
$ dynamips 2> /dev/null | grep version
Cisco Router Simulation Platform (version 0.2.17-amd64/Linux stable)
$ getcap $(which dynamips)
/usr/local/bin/dynamips = cap_net_admin,cap_net_raw+ep
```

##		{--- VPCS ---}

#### [04] Get and install VPCS.

I will perform a Subversion (SVN) (https://subversion.apache.org/) checkout from the main trunk for my example.<br>
Refer to the Virtual PC Simulator project site (http://sourceforge.net/projects/vpcs/) for more information.
```
$ sudo pacman -S subversion
$ cd /tmp
$ svn checkout svn://svn.code.sf.net/p/vpcs/code/trunk vpcs-code
$ cd vpcs-code/src
$ rgetopt='int getopt(int argc, char *const *argv, const char *optstr);'
$ sed -i "s/^int getopt.*/$rgetopt/" getopt.h
$ unset -v rgetopt
$ sed -i 's/i386/x86_64/' Makefile.linux
$ sed -i 's/-s -static//' Makefile.linux
$ make -f Makefile.linux
$ strip --strip-unneeded vpcs
$ sudo mv vpcs /usr/local/bin
```
#### [05] Verify the location and version for VPCS.
````
$ cd $HOME
$ type vpcs
vpcs is /usr/local/bin/vpcs
$ vpcs -v | grep version
Welcome to Virtual PC Simulator, version 0.8c
````

##		{--- IOUYAP ---}

#### [06] Get and install iniparser for IOUYAP.

`$ sudo pacman -S iniparser`

#### [07] Get and install IOUYAP.

I will download and install the latest release (at the date of this post) for my example.<br>
Refer to iouyap (https://github.com/GNS3/iouyap/releases) for specific versions and release notes.
```
$ cd /tmp
$ curl -L https://github.com/GNS3/iouyap/archive/v0.97.tar.gz | tar -xz
$ cd iouyap*
$ bison -ydv netmap_parse.y
$ flex netmap_scan.l
$ gcc -Wall -g *.c -o iouyap -liniparser -lpthread
$ strip --strip-unneeded iouyap
$ sudo mv iouyap /usr/local/bin
```
#### [08] Set capabilities for IOUYAP.
```
$ cd $HOME
$ sudo setcap cap_net_admin,cap_net_raw=ep $(which iouyap)
```
#### [09] Verify the version and capabilities for IOUYAP.
```
$ iouyap -V
iouyap version 0.97.0
$ getcap $(which iouyap)
/usr/local/bin/iouyap = cap_net_admin,cap_net_raw+ep
```

##		{--- IOS on Linux (IOL) aka IOS on Unix (IOU) ---}

Disclaimer: The inclusion of references to IOL is intended for educational and/or informational purposes only.

#### [10] Enable the multilib repository (if not already enabled).
Refer to Multilib (https://wiki.archlinux.org/index.php/Multilib) for more information.
```
$ sudo vi /etc/pacman.conf
...
[multilib]
Include = /etc/pacman.d/mirrorlist
...
```
Refresh the master package list.
`$ sudo pacman -Sy`

#### [11] Get and install IOL dependencies.
`$ sudo pacman -S lib32-openssl lib32-gcc-libs`<br>
`$ sudo ln -s /usr/lib32/libcrypto.so.1.0.0 /usr/lib32/libcrypto.so.4`

#### [12] Prevent EXCESSCOLL IOL error.
Get the current value for the datagram queue length for Unix domain sockets.
```
$ sysctl net.unix.max_dgram_qlen
net.unix.max_dgram_qlen = 512
```
Increase the value to 10000.<br>
`$ sudo sysctl net.unix.max_dgram_qlen=10000`

We also need to make the modification persistent.
```
$ sudo tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null << EOL
> # Prevent EXCESSCOLL error for IOL
> net.unix.max_dgram_qlen=10000
> EOL
```
Verify the new configuration by running the following commands and take note of the output:
```
$ sysctl net.unix.max_dgram_qlen
net.unix.max_dgram_qlen = 10000
$ tail -2 /etc/sysctl.d/99-sysctl.conf
# Prevent EXCESSCOLL error for IOL
net.unix.max_dgram_qlen=10000
```
#### [13] E.T. No Phone Home.
Add an entry to the hosts file.<br>
`$ sudo sed -i '/127.0.1.1/a 127.0.0.84\txml.cisco.com' /etc/hosts`

Verify the new entry has been added.
```
$ cat /etc/hosts
#
# /etc/hosts: static lookup table for host names
#

#<ip-address> <hostname.domain.org> <hostname>
127.0.0.1 localhost.localdomain localhost
::1  localhost.localdomain localhost
127.0.1.1 arch-gns3.localdomain arch-gns3
127.0.0.84 xml.cisco.com

# End of file
```
#### [14] Set the hostid to '00000000'.
```
$ cd $HOME
$ hostid
$ curl -Lo set-hostid.sh https://goo.gl/7dDf9S
$ chmod u+x set-hostid.sh
$ sudo ./set-hostid.sh 00000000
$ hostid
```
#### [15] Create a sample IOL license file.
```
$ curl -Lo iou4u.py https://goo.gl/fpzYbY
$ chmod u+x iou4u.py
$ ./iou4u.py
$ cat iourc
```

##		{--- uBridge ---}

#### [16] Get and install uBridge.
I will download and install the latest release (at the date of this post) for my example. <br>
Refer to ubridge (https://github.com/GNS3/ubridge/releases) for specific versions and release notes.
```
$ cd /tmp
$ curl -L https://github.com/GNS3/ubridge/archive/v0.9.13.tar.gz | tar -xz
$ cd ubridge*
$ make
$ sudo make install
```
#### [17] Verify the version and capabilities for uBridge.
```
$ cd $HOME
$ ubridge -v
ubridge version 0.9.13
$ getcap $(which ubridge)
/usr/local/bin/ubridge = cap_net_admin,cap_net_raw+ep
```

##		{--- QEMU ---}

#### [18] Get and install QEMU.
`$ sudo pacman -S qemu`<br>
Note: It's highly recommended to enable KVM for QEMU. Refer to Enabling KVM and KVM for more information.


##		{--- Docker ---}

#### [19] Get and install Docker.
`$ sudo pacman -S docker`

#### [20] Start and enable 'docker.service'.
`$ sudo systemctl enable docker.service`<br>
`$ sudo systemctl start docker.service`

#### [21] Add yourself to the 'docker' group.
`$ sudo gpasswd -a $(id -un) docker`

#### [22] Log out and back in for the new group membership to take effect.

#### [23] Verify the new group membership.
```
$ id -Gn
marc wheel docker  
```
#### [24] Display system-wide information for Docker.
`$ docker info`


##		{--- Wireshark ---}

#### [25] Get and install Wireshark (with the GTK frontend).
`$ sudo pacman -S wireshark-gtk`

#### [26] Add yourself to the 'wireshark' group.
`$ sudo gpasswd -a $(id -un) wireshark`

#### [27] Log out and back in for the new group membership to take effect.

#### [28] Verify the new group membership.
```
$ id -Gn
marc wheel wireshark docker
```

##		{--- GNS3 ---}

#### [29] Get and install GNS3 dependencies.
`$ sudo pacman -S qt5-svg qt5-websockets python-pip python-pyqt5 python-sip`


#### [30] Install Git and create/set a working directory.
The GNS3 Server and GUI can be installed via pip(https://en.wikipedia.org/wiki/Pip_(package_manager)),<br>
but I prefer the Git method in case I need to modify source files before installation.
```
$ sudo pacman -S git
$ mkdir -p $HOME/GNS3-Dev && cd $_
```
#### [31] Get and install GNS3 Server from GitHub.
```
$ git clone https://github.com/GNS3/gns3-server.git
$ cd gns3-server
$ git tag --list 'v2.1.*'
$ git checkout v2.1.0
$ sudo pip3 install -r requirements.txt
$ sudo python3 setup.py install
```
#### [32] Get and install GNS3 GUI from GitHub.
```
$ cd $HOME/GNS3-Dev
$ git clone https://github.com/GNS3/gns3-gui.git
$ cd gns3-gui
$ git tag --list 'v2.1.*'
$ git checkout v2.1.0
$ sudo pip3 install -r requirements.txt
$ sudo python3 setup.py install
```
#### [33] Verify the GNS3 packages have been installed.
```
$ pip3 list | grep gns3
gns3-gui (2.1.0)
gns3-server (2.1.0)
```

source: http://binarynature.blogspot.gr/2015/11/install-configure-gns3-arch-linux.html
