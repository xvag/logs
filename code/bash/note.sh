du -sch /path/ | sort -h

cat file | uniq -c -w 6
cat file | cut -d: -f1 | sort | uniq

ps -eo pid,ppid,cmd,%cpu,%mem --sort=%cpu | head
ps -ef | grep defunct

for i in ./*; do file $i | grep -iq png; if [ $? -eq 0 ]; then echo $i; fi; done;

for c in $(ls /proc/*/cmdline); do echo $c ; cat $c ; echo ; done

grep -i username /etc/passwd
ls -l /etc | grep rc[0..9]

cat file | tr [:lower:] [:upper:]

ls -l | tr -s ' '

mkdir -p folder/{sub1,sub2}/{sub1,sub2,sub3}

last | grep username | tr -s ' ' | cut -d' ' -f1,3 | sort -k2 | uniq

scsiadd -p
scisadd -r 0 0 0 0

dd if=/path/to/.iso of=/dev/sdX bs=4M status=progress oflag=sync
dd if=/path/to/FBSD.img of=/dev/da0 bs=1M conv=sync

# change interface name:
vim /etc/udev/rules.d/10-network.rules
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="aa:bb:cc:dd:ee:ff", NAME="net1"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ab:bc:cd:de:ef:fg", NAME="net2"

# configure metrics:
ip route
ip route del default .... metric X
ip route add default .... metric Y

# monitor traffic on a specific port:
tcpdump -i eth0 -s 1500 port 3306

wget -np -r -k 'http://your-url-here'

diff <(command1) <(command2)

# get full path of a file:
readlink -f filename

# get basename from full path:
basename /path/to/file/or/dir

# list grub entries:
# awk -F\' '$1=="menuentry " {print $2}' /boot/grub2/grub.cfg

# sync test dirs:
rsync -arvzh --delete --progress --dry-run /source/ /destination/

# create a super fast ram disk:
mkdir -p /mnt/ram
mount -t tmpfs tmpfs /mnt/ram -o size=8192M

# fix a really long command that you messed up:
$ fc

# tunnel with ssh (local port 3337 -> remote host 127.0.0.1 on port 6379):
ssh -L 3337:127.0.0.1:6379 root@emkc.org -N

# intercept stdout and log to file:
cat file | tee -a log | cat > /dev/null

# exit terminal but leave all processes running:
disown -a && exit

# ways to delete/wipe stuff:
shred -zvu -n 5 filetodel
wipe -rfi dirtodel/ (for magnetic memory)
srm -vz dirtodel/ (install secure-delete)
sfill -v /dirtodel/ (secure-delete)
sswap /dev/sdXy (after swapoff)
sdmem -f -v (remove data in RAM)

# recover rm-ed files:
foremost -t jpg -i /dev/sdXy -o /dir/to/store

# data recovery:
https://www.cgsecurity.org/wiki/TestDisk

# find examples:
find . -maxdepth 3-type f -size +2M
find /home/user -perm 777 -exec rm '{}' +
       -iname "*.conf"
       -mtime -180 = modified time
       -atime +180 = accessed time
       -print
find /dir/to/search/ -type [d|f] -[empty|executable] -[delete|print0]
# find files and sort by line-count:
find /dir/ -type f -exec wc -l {} + | sort -rn

# find files containing specific text, with grep:
grep -rnw '/path/to/somewhere/' -e 'pattern'
grep --include=\*.{c,h} -rnw '/path/to/somewhere/' -e "pattern"
grep --exclude=*.o -rnw '/path/to/somewhere/' -e "pattern"
grep --exclude-dir={dir1,dir2,*.dst} -rnw '/path/to/somewhere/' -e "pattern"

# cd/dvd:
cdrecord -v dev=/dev/sr0 blank=fast
# for cd:
cdrecord -v -dao dev=/dev/sr0 isoimage.iso
# for dvd:
growisofs -dvd-compat -Z /dev/sr0=isoimage.iso

# Display Power Management Signaling (DPMS)
xset q
xset dpms force off
xset [+/-]dpms
https://wiki.archlinux.org/index.php/Display_Power_Management_Signaling

# clean package cache in arch linux
ls /var/cache/pacman/pkg/ | wc -l
du -sh /var/cache/pacman/pkg/
paccache -r
paccache -rk 1

# Mount a directory to another location and alter permission bits
bindfs -u $(id -u) -g $(id -g) /path/to/mac/disk/ /alter/mount/dir/
https://bindfs.org/
https://aur.archlinux.org/packages/bindfs/


# fix subtitles after g.translate
sed 's/: /:/g' a.srt > b.srt
sed 's/ -> / --> /g' b.srt > c.srt
sed '/\.[0-9][0-9][0-9]/ s/\./,/g' c.srt > d.srt


# bash variable `${0##*/}` cuts  of all the preceding path elements,
# just as `basename $0` would do.
# The ## tries to find the longest matching expansion of the prefix pattern:
#
# $ x=/a/b/c/d
# $ echo ${x##*/}
# d
# $ basename $x
# d
#
# The reason for using `${0##*/}` is that it doesn’t involve an external program call,
# but it is kind of obscuring what is going on.


## sed & awk:

sed 's/term/replacement/flag' file
sed 's/term/repl/flag;s/term/repl/flag' file

awk '/pattern/ { actions }' filename
awk '//{print}'/etc/hosts
awk '/localhost/{print}' /etc/hosts
awk '/l*c/{print}' /etc/hosts
awk '/[al1]/{print}' /etc/hosts
awk '/^ff/{print}' /etc/hosts
awk '//{print $1, $2, $3; }' filename
awk '//{printf "%-10s %s\n",$2, $3 }' filename
awk '/ *\$[2-9]\.[0-9][0-9] */ { print $0 "*" ; } / *\$[0-1]\.[0-9][0-9] */ { print ; }' filename
awk '$3 <= 20 { printf "%s\t%s\n", $0,"TRUE" ; } $3 > 20  { print $0 ;} ' filename
awk '($3 ~ /^\$[2-9][0-9]*\.[0-9][0-9]$/) && ($4=="Tech") { printf "%s\t%s\n",$0,"*"; } ' filename
awk '$4 <= 20 { printf "%s\t%s\n", $0,"*" ; next; } $4 > 20 { print $0 ;} ' filename
dir -l | awk '{print $3, $4, $9;}'
uname -a | awk '{hostname=$2 ; print hostname ; }'
cat /etc/passwd | awk -v name="$username" ' $0 ~ name {print $0}'
 -v : Awk option to declare a variable

# make one liners:
cat <file> | awk '/^-/{next;}{o=o $0}END{print o}'

awk '
BEGIN { actions }
/pattern/ { actions }
/pattern/ { actions }
...
END { actions }
' filenames

Built-in variables:
FILENAME : current input file name( do not change variable name)
FR : number of the current input line (that is input line 1, 2, 3# so on, do not change variable name)
NF : number of fields in current input line (do not change variable name)
OFS : output field separator
FS : input field separator
ORS : output record separator
RS : input record separator
NR : number of records (lines)
