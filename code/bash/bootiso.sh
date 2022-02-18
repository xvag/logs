#!/bin/bash
# shellcheck disable=SC2181
#
# Author: jules randolph <jules.sam.randolph@gmail.com> https://github.com/jsamr
# License: MIT
# Version 3.1.3

set -o pipefail
set -E

version="3.1.3"
scriptName=$(basename "$0")
bashVersion=$(echo "$BASH_VERSION" | cut -d. -f1)

if [ -z "$BASH_VERSION" ] || [ "$bashVersion" -lt 4 ]; then
	echoerr "You need bash v4+ to run this script. Aborting..."
	exit 1
fi

# program constrains definitions
typeset -ar commandDependencies=('lsblk' 'sfdisk' 'mkfs' 'blkid' 'wipefs' 'grep' 'file' 'awk' 'mlabel' 'partprobe' 'tar')
typeset -Ar commandPackages=(
	['lsblk']='util-linux'
	['sfdisk']='util-linux'
	['mkfs']='util-linux'
	['blkid']='util-linux'
	['wipefs']='util-linux'
	['grep']='grep'
	['file']='file'
	['awk']='gawk'
	['mlabel']='mtools'
	['syslinux']='syslinux'
	['rsync']='rsync'
	['partprobe']='parted'
	['curl']='curl'
	['tar']='tar'
)
typeset shortOptions='bydJahlMftLp'
typeset -ar supportedFS=('vfat' 'exfat' 'ntfs' 'ext2' 'ext3' 'ext4' 'f2fs')
typeset -Ar userVarsCompatibilityMatrix=(
	['iso-file']='install-auto install-mount-rsync install-dd inspect probe'
	['device']='install-auto install-mount-rsync install-dd format'
	['type']='install-mount-rsync format'
	['label']='install-mount-rsync format'
	['remote-bootloader']='install-auto install-mount-rsync'
)
typeset -Ar userFlagsCompatibilityMatrix=(
	['local-bootloader']='install-auto install-mount-rsync'
	['assume-yes']='install-auto install-mount-rsync install-dd format'
	['no-eject']='install-auto install-mount-rsync install-dd format'
	['autoselect']='install-auto install-mount-rsync install-dd format'
	['no-mime-check']='install-auto install-mount-rsync install-dd'
	['no-usb-check']='install-auto install-mount-rsync install-dd format'
)

# internal variables
typeset ticketsurl="https://github.com/jsamr/bootiso/issues"
typeset mountRoot=/mnt
typeset tempRoot=/var/tmp/bootiso
typeset cacheRoot=/var/cache/bootiso
typeset selectedPartition
typeset isoMountPoint
typeset usbMountPoint
typeset startTime
typeset endTime
typeset addSyslinuxBootloader=false
typeset syslinuxVersion
typeset -a devicesList
typeset operationSuccess
typeset expectingISOFile
typeset foundSyslinuxMbrBinary
typeset foundSyslinuxBiosFolder
typeset -A syslinuxInstall
typeset -a temporaryAssets=()
typeset -A isoInspection=(
	['isHybrid']=''
	['syslinuxBin']=''
	['syslinuxVer']=''
	['syslinuxConf']=''
	['supportsEFIBoot']=''
)
typeset -A userFlags=(
	# Actions
	['help']=''
	['version']=''
	['list-usb-drives']=''
	['format']=''
	['install-dd']=''
	['install-mr']=''
	['inspect']=''
	['probe']=''
	# Options
	['local-bootloader']=''
	['assume-yes']=''
	['device']=''
	['no-eject']=''
	['autoselect']=''
	['no-mime-check']=''
	['no-usb-check']=''
)
typeset -A userVars=(
	['iso-file']=''
	['device']=''
	['type']=''
	['label']=''
	['remote-bootloader']=''
)

# user defined variables
typeset selectedIsoFile # no default
typeset selectedDevice  # default to prompted to user
typeset partitionLabel  # default to inferred from ISO file label
typeset partitionType   # default to vfat
typeset action='install-auto'
typeset selectedBootloaderVersion # default to auto

# options
typeset disableMimeCheck
typeset disableUSBCheck
typeset disableConfirmation
typeset autoselect
typeset shouldMakePartition
typeset noDeviceEjection
typeset localBootloader

# $1: The text to colorify.
redify() {
	echo -e "\\033[0;31m$1\\033[0m"
}

# $1: The text to colorify.
greenify() {
	echo -e "\\033[0;32m$1\\033[0m"
}

# $1: The text to colorify.
yellowify() {
	echo -e "\\033[1;33m$1\\033[0m"
}

typeset openTicketMessage="This is not expected: please open a ticket at $ticketsurl."

# 100 wide + no tabs
typeset help_message="Create a bootable USB from any ISO securely.
Usage: $scriptName [<options>...] <file.iso>
       $scriptName <action> [<options>...] <file.iso>
       $scriptName <action> [<options>...]

The default action [install-auto] as per first synopsis is to install an ISO file to a USB device in
automatic mode. In such mode, $scriptName will analyze the ISO file and select the best course of
actions to maximize the odds your USB stick be proven bootable. Option and action flags can be
stacked in their POSIX form.

ACTION FLAGS

You can override the default [install-auto] action with bellow flags (cannonical names given in
brackets):

-h, --help, help                   [help] Display this help message and exit.
-v, --version                      [version] Display version and exit.
-l, --list-usb-drives              [list-usb-drives] List available USB drives and exit.
-i, --inspect                      [inspect] Inspect ISO file boot capabilities and how $scriptName can handle
                                   it, then exit.
-p, --probe                        [probe] Equivalent to [inspect] followed by [list-usb-drives] actions.
-f, --format                       [format] Format selected USB drive and exit.
    --dd                           [install-dd] Overrides \"automatic\" mode and install ISO in image-copy
                                   mode with \`dd' utility. It is recommended to run [inspect] action first.
    --mrsync                       [install-mount-rsync] Overrides \"automatic\" mode and install ISO in
                                   mount-rsync mode with \`rsync' utility. It is recommended to run [inspect]
                                   action first.

OPTION FLAGS

-d, --device  <device>             Select <device> block file as USB device.
                                   If <device> is not connected through USB, $scriptName will fail and
                                   exit. Device block files are usually situated in /dev/sdX or /dev/hdX.
                                   You can omit \`/dev/' prefix.
-y, --assume-yes                   $scriptName won't prompt the user for confirmation before erasing and
                                   partitioning USB device. $(yellowify 'Use at your own risks.')
-a, --autoselect                   Enable autoselecting USB devices in combination with -y option.
                                   Autoselect will automatically select a USB drive device if there is
                                   exactly one connected to the system. Enabled by default when neither
                                   \`-d' nor \`--no-usb-check' options are given.
-J, --no-eject                     Do not eject device after unmounting.
-M, --no-mime-check                $scriptName won't assert that selected ISO file has the right mime-type.
-t, --type <type>                  Format to \`<type>' instead of default FAT32 (vfat). Supported types:
                                   ${supportedFS[*]}.
                                   Applicable to [install-mount-rsync] and [format] actions.
-L, --label <label>                Set partition label as \`<label>' instead of inferring.
                                   Applicable to [install-mount-rsync] and [format] actions. $scriptName
                                   will cut labels which are too long regarding the selected filesystem
                                   limitations.
    --no-usb-check                 $scriptName won't assert that selected device is connected
                                   through USB bus. $(redify 'Use at your own risks.')
    --local-bootloader             Prevent download of remote bootloader and force local (SYSLINUX) during
                                   installation. Applicable to [install-mount-rsync] action.
    --remote-bootloader <version>  Force download of remote bootloader at version <version>.
	                               Version must follow the pattern MAJOR.MINOR. Examples: 4.08, 6.04.
								   Applicable to [install-mount-rsync] action.
    --                             POSIX end of options.


INFO

    Bootiso v$version. Author: Jules Samuel Randolph
    Bugs and new features: $ticketsurl
    If you like bootiso, feel free to help the community by making it visible:
    * star the project at https://github.com/jsamr/bootiso
    * upvote those SE post: https://goo.gl/BNRmvm
                            https://goo.gl/YDBvFe"

display_help() {
	echo -e "$help_message"
}

indent() {
	sed -e ':a;N;$!ba;s/\n/\n         /g'
}

indentAll() {
	sed -e 's/^/         /'
}

# $1: The message to print.
echoerr() {
	redify "$scriptName: $1" | indent >&2
}

# $1: The message to print.
echowarn() {
	yellowify "$scriptName: $1" | indent
}

# $1: The message to print.
echogood() {
	greenify "$scriptName: $1" | indent
}

# $1: The message to print.
echoinfo() {
	echo -e "$scriptName: $1" | indent
}

# $1: The message to print.
failAndExit() {
	echoerr "$1\\nExiting..."
	exit 1
}

compute() {
	answer=$(echo "$@" | bc)
	if ((answer == 0)); then
		return 1
	else
		return 0
	fi
}

# $1: The name of the command to check against $PATH.
hasPackage() {
	command -v "$1" &>/dev/null
	return $?
}

configureFolders() {
	typeset defaultMode=777
	if [ ! -e "$tempRoot" ]; then
		mkdir -m $defaultMode "$tempRoot"
	elif [ -d "$tempRoot" ]; then
		chmod -R $defaultMode "$tempRoot"
	else
		failAndExit "Unexpected state: \`$tempRoot' is not a folder.\\nRemove this file and try again."
	fi
	if [ ! -e "$cacheRoot" ]; then
		mkdir -m $defaultMode "$cacheRoot"
	elif [ -d "$cacheRoot" ]; then
		chmod -R $defaultMode "$cacheRoot"
	else
		failAndExit "Unexpected state: \`$cacheRoot' is not a folder.\\nRemove this file and try again."
	fi
	if [ ! -e "$mountRoot" ]; then
		mkdir "$mountRoot"
	elif [ ! -d "$mountRoot" ]; then
		failAndExit "Unexpected state: \`$mountRoot' is not a folder.\\nRemove this file and try again."
	fi
}

isMounted() {
	if [ ! -z "$1" ] && grep -q -e "$1" /etc/mtab; then
		return 0
	else
		return 1
	fi
}

umountUSB() {
	if isMounted "$usbMountPoint"; then
		if umount "$usbMountPoint" |& indentAll; then
			echogood "USB device partition succesfully unmounted."
		else
			echowarn "Could not unmount USB mount point."
		fi
	fi
}

umountISO() {
	if isMounted "$isoMountPoint"; then
		if umount "$isoMountPoint" |& indentAll; then
			echogood "ISO succesfully unmounted ($isoMountPoint)."
		else
			echowarn "Could not unmount ISO mount point."
		fi
	fi
}

initPckgManager() {
	if hasPackage apt-get; then # Debian
		pkgmgr="apt-get install"
		return 0
	fi
	if hasPackage dnf; then # Fedora
		pkgmgr="dnf install"
		return 0
	fi
	if hasPackage yum; then # Fedora
		pkgmgr="yum install"
		return 0
	fi
	if hasPackage pacman; then # Arch
		pkgmgr="pacman -S"
		return 0
	fi
	if hasPackage zypper; then # OpenSuse
		pkgmgr="zypper install"
		return 0
	fi
	if hasPackage emerge; then # Gentoo
		pkgmgr="emerge"
		return 0
	fi
	return 1
}

checkSudo() {
	if ((EUID != 0)); then
		if [[ -t 1 ]]; then
			sudo "$0" "$@"
		else
			exec 1>output_file
			gksu "$0" "$@"
		fi
		exit
	fi
}

failISOCheck() {
	echoerr "Provided file \`$selectedIsoFile' doesn't seem to be an ISO file (wrong mime type: \`$mimetype')."
	echowarn "You can bypass this policy with \`-M, --no-mime-check' option, but it is likely that operation will fail."
	echoerr "Exiting..."
	exit 1
}

assertISOIsOK() {
	typeset mimetype
	typeset -i isOctetStream
	if [ -z "$selectedIsoFile" ]; then
		echoerr "Missing argument \`iso-file'."
		exit 2
	fi
	if [ -d "$selectedIsoFile" ]; then
		failAndExit "Provided file \`$selectedIsoFile' is a directory."
	fi
	if [ ! -f "$selectedIsoFile" ]; then
		failAndExit "Provided iso file \`$selectedIsoFile' does not exists."
	fi
	if [ "$disableMimeCheck" == 'false' ]; then
		mimetype=$(file --mime-type -b -- "$selectedIsoFile")
		[ "$mimetype" == "application/octet-stream" ]
		isOctetStream=$?
		if ((isOctetStream != 0)) && [ ! "$mimetype" == "application/x-iso9660-image" ]; then
			failISOCheck
		fi
	fi
}

firstMatchInFolder() {
	find "$1" -type f -iname "$2" -print -quit
}

matchFirstExpression() {
	typeset root=$1
	typeset expr
	typeset match
	shift
	for expr in "$@"; do
		match=$(firstMatchInFolder "$root" "$expr")
		if [ ! -z "$match" ]; then
			echo "$match"
			break
		fi
	done
}

findFileFromPatterns() {
	typeset root=$1
	shift
	typeset loc
	typeset found
	for loc in "$@"; do
		if [ -f "${root}/$loc" ]; then
			found="${root}/$loc"
			break
		fi
	done
	if [ -z "$found" ]; then
		for loc in "$@"; do
			typeset candidate=$(find "$root" -type f -path "*/$loc" -print -quit)
			if [ ! -z "$candidate" ]; then
				found="$candidate"
				break
			fi
		done
	fi
	echo "$found"
}

configureLabel() {
	partitionLabel=${partitionLabel:-$(blkid -o value -s LABEL -- "$selectedIsoFile")}
	case $partitionType in
	vfat)
		# Label to uppercase, otherwise some DOS systems won't work properly
		partitionLabel=${partitionLabel^^}
		# FAT32 labels have maximum 11 chars
		partitionLabel=${partitionLabel:0:11}
		;;
	exfat)
		# EXFAT labels have maximum 15 chars
		partitionLabel=${partitionLabel:0:15}
		;;
	ntfs)
		# NTFS labels have maximum 32 chars
		partitionLabel=${partitionLabel:0:32}
		;;
	ext2 | ext3 | ext4)
		# EXT labels have maximum 16 chars
		partitionLabel=${partitionLabel:0:16}
		;;
	*)
		echowarn "Unexpected partition type \`$partitionType'.\\n$openTicketMessage"
		;;
	esac
	# Fallback to "BOOTISO"
	partitionLabel=${partitionLabel:-"BOOTISO"}
	if [ -z "${userVars['label']}" ]; then
		echogood "Partition label automatically set to \`$partitionLabel'.\\nYou can explicitly set label with \`-L, --label' option."
	else
		echogood "Partition label manually set to \`$partitionLabel'."
	fi

}

# $1: The name of the package command to check.
checkpkg() {
	typeset answer
	if ! hasPackage "$1"; then
		echowarn "Package '$1' not found!"
		if [ ! -z "$pkgmgr" ]; then
			read -r -n1 -p "Attempt installation? (y/n)>" answer
			echo
			case $answer in
			y | Y)
				if ! $pkgmgr "${commandPackages["$1"]}"; then
					failAndExit "Installation of dependency \`$1' failed.\\nPerhaps this dependency has a slightly different name in your distribution.\\nFind it and install manually."
				else
					if ! hasPackage "$1"; then
						failAndExit "Program \`$1' is not accessible in the \$PATH environment even though the package ${commandPackages["$1"]} has just been installed."
					fi
				fi
				;;
			*)
				failAndExit "Missing dependency \`$1'."
				;;
			esac
		else
			failAndExit "Missing dependency \`$1'."
		fi
	fi
}

# $1: The string by which elements will be joined.
# $2-* : the elements to join
joinBy() {
	local IFS=$1
	shift
	echo "$*"
}

# $1: The element to check.
# $2-* : the list to check against.
containsElement() {
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}

initDevicesList() {
	typeset -a devices
	typeset device
	mapfile -t devices < <(lsblk -o NAME,TYPE | grep --color=never -oP '^\K\w+(?=\s+disk$)')
	devicesList=()
	for device in "${devices[@]}"; do
		if [ "$(getDeviceType "/dev/$device")" == "usb" ] || [ "$disableUSBCheck" == 'true' ]; then
			devicesList+=("$device")
		fi
	done
}

listDevicesTable() {
	typeset lsblkCmd='lsblk -o NAME,MODEL,VENDOR,SIZE,TRAN,HOTPLUG,SERIAL'
	initDevicesList
	if [ "$disableUSBCheck" == 'false' ]; then
		echoinfo "Listing drives available in your system:"
	else
		echoinfo "Listing USB devices available in your system:"
	fi
	if [ "${#devicesList[@]}" -gt 0 ]; then
		$lsblkCmd | sed -n 1p | sed 's/^/         /'
		$lsblkCmd | grep --color=never -P "^($(joinBy '|' "${devicesList[@]}"))" | sed 's/^/         /'
		return 0
	else
		echowarn "Couldn't find any USB drive in your system.\\nIf any is physically plugged in, it's likely that it has been ejected and should be plugged-in again to be discoverable.\\nYou can check the availability of USB drives with \`$scriptName -l' command."
		return 1
	fi
}

parseArguments() {
	enableUserFlag() {
		userFlags["$1"]=true
	}
	setUserVar() {
		userVars["$1"]=$2
	}
	typeset key
	typeset isEndOfOptions=false
	while [[ $# -gt 0 ]]; do
		key="$1"
		if [ "$isEndOfOptions" == 'false' ]; then
			case $key in
			# ACTIONS
			-h | --help | help)
				enableUserFlag 'help'
				shift
				;;
			-v | --version)
				enableUserFlag 'version'
				shift
				;;
			-l | --list-usb-drives)
				enableUserFlag 'list-usb-drives'
				shift
				;;
			-p | --probe)
				enableUserFlag 'probe'
				shift
				;;
			-f | --format)
				enableUserFlag 'format'
				shift
				;;
			-i | --inspect)
				enableUserFlag 'inspect'
				shift
				;;
			--dd)
				enableUserFlag 'install-dd'
				shift
				;;
			--mrsync)
				enableUserFlag 'install-mount-rsync'
				shift
				;;
			# OPTIONS
			-b | --bootloader)
				echowarn "\`-b', \`--bootlaoder' option has been discarded since v3.0.0. Bootloader installation is now automatic."
				shift
				;;
			--local-bootloader)
				enableUserFlag 'local-bootloader'
				shift
				;;
			--remote-bootloader)
				if (($# < 2)); then
					failAndExit "Missing value for \`$1' flag. Please provide a version following MAJOR.MINOR pattern. ex: \`4.10'."
				fi
				setUserVar 'remote-bootloader' "$2"
				shift 2
				;;
			-y | --assume-yes)
				enableUserFlag 'assume-yes'
				shift
				;;
			-d | --device)
				if (($# < 2)); then
					failAndExit "Missing value for \`$1' flag. Please provide a device."
				fi
				setUserVar 'device' "$2"
				shift 2
				;;
			-t | --type)
				if (($# < 2)); then
					failAndExit "Missing value for \`$1' flag. Please provide a filesystem type."
				fi
				setUserVar 'type' "${2,,}" #lowercased
				shift 2
				;;
			-L | --label)
				if (($# < 2)); then
					failAndExit "Missing value for \`$1' flag. Please provide a label."
				fi
				setUserVar 'label' "$2"
				shift 2
				;;
			-J | --no-eject)
				enableUserFlag 'no-eject'
				shift
				;;
			-a | --autoselect)
				enableUserFlag 'autoselect'
				shift
				;;
			-M | --no-mime-check)
				enableUserFlag 'no-mime-check'
				shift
				;;
			--no-usb-check)
				enableUserFlag 'no-usb-check'
				shift
				;;
			--)
				isEndOfOptions=true
				shift
				;;
			-*)
				# Probably an option, possibly a file.
				if [ ! -f "$key" ]; then
					# Assume it's stacked options
					if [[ "$key" =~ ^-["$shortOptions"]{2,}$ ]]; then
						shift
						typeset options=${key#*-}
						typeset -a extractedOptions
						mapfile -t extractedOptions < <(echo "$options" | grep -o . | xargs -d '\n' -n1 printf '-%s\n')
						set -- "${extractedOptions[@]}" "$@"
					elif [[ "$key" =~ ^--[a-zA-Z0-9]{2,}$ ]]; then
						failAndExit "Unknown option: \`$key'"
					else
						printf "\\e[0;31m%s\\e[m" "$scriptName: Unknown option: "
						printf '%s' "$key" | GREP_COLORS='mt=00;32:sl=00;31' grep --color=always -P "[$shortOptions]"
						if [[ "$key" =~ ^-[a-zA-Z0-9]+$ ]]; then
							typeset wrongOptions=$(printf '%s' "${key#*-}" | grep -Po "[^$shortOptions]" | tr -d '\n')
							if [ ${#key} -eq 2 ]; then
								yellowify "flag: \\033[0;31m\`$wrongOptions'\\033[0m."
							else
								yellowify "stacked flags: \\033[0;31m\`$wrongOptions'\\033[0m."
							fi

						fi
						echoerr "Exiting..."
						exit 2
					fi
				else
					# Happened to be a file.
					setUserVar 'iso-file' "$1"
					shift
				fi
				;;
			*)
				setUserVar 'iso-file' "$1"
				shift
				;;
			esac
		else
			setUserVar 'iso-file' "$1"
			break
		fi
	done
}

checkPackages() {
	typeset pkg
	for pkg in "${commandDependencies[@]}"; do
		checkpkg "$pkg"
	done
	# test grep supports -P option
	if ! echo 1 | grep -P '1' &>/dev/null; then
		failAndExit "You're using an old version of grep which does not support perl regular expression (-P option)."
	fi
}

# $1 : the folder name prefix
# print the name of the new folder if operation succeeded, fails otherwise
createMountFolder() {
	typeset tmpFileTemplate
	if ((EUID == 0)); then
		tmpFileTemplate="$mountRoot/$1.XXX"
	else
		tmpFileTemplate="$tempRoot/$1.XXX"
	fi
	mktemp -d "$tmpFileTemplate"
	typeset status=$?
	if [ ! $status -eq 0 ]; then
		failAndExit "Failed to create temporary mount point with pattern \`$tmpFileTemplate'."
	fi
}

createTempFile() {
	typeset tmpFileTemplate="$tempRoot/$1.XXX"
	mktemp "$tmpFileTemplate"
	typeset status=$?
	if [ ! $status -eq 0 ]; then
		failAndExit "Failed to create temporary file"
	fi
}

mountISOFile() {
	isoMountPoint=$(createMountFolder iso) || exit "$?"
	temporaryAssets+=("$isoMountPoint")
	echogood "Created ISO mount point at \`$isoMountPoint'."
	if ! mount -r -o loop -- "$selectedIsoFile" "$isoMountPoint" >/dev/null; then
		failAndExit "Could not mount ISO file."
	fi
}

# $1 :  a device block
# Return 0 if device is USB, 1 otherwise
getDeviceType() {
	typeset deviceName=/sys/block/${1#/dev/}
	typeset deviceType=$(udevadm info --query=property --path="$deviceName" | grep -Po 'ID_BUS=\K\w+')
	echo "$deviceType"
}

deviceIsDisk() {
	lsblk --nodeps -o NAME,TYPE "$1" | grep -q disk
	return $?
}

selectDevice() {
	typeset _selectedDevice
	chooseDevice() {
		echoinfo "Select the device corresponding to the USB device you want to make bootable among: $(joinBy ',' "${devicesList[@]}")\\nType CTRL+D to quit."
		read -r -p "Select device id>" _selectedDevice
		echo
		if containsElement "$_selectedDevice" "${devicesList[@]}"; then
			selectedDevice="/dev/$_selectedDevice"
		else
			if containsElement "$_selectedDevice" "" "exit"; then
				echoinfo "Exiting on user request."
				exit 0
			else
				failAndExit "The drive $_selectedDevice does not exist."
			fi
		fi
	}
	handleDeviceSelection() {
		if [ ${#devicesList[@]} -eq 1 ] && [ "$disableUSBCheck" == 'false' ]; then
			# autoselect
			if [ "$disableConfirmation" == 'false' ] || { [ "$disableConfirmation" == 'true' ] && [ "$autoselect" == 'true' ]; }; then
				typeset selected="${devicesList[0]}"
				echogood "Autoselecting \`$selected' (only USB device candidate)"
				selectedDevice="/dev/$selected"
			else
				chooseDevice
			fi
		else
			chooseDevice
		fi
	}
	if [ -z "$selectedDevice" ]; then
		# List all hard disk drives
		if listDevicesTable; then
			handleDeviceSelection
		else
			echoerr "Exiting..."
			exit 1
		fi
	fi
	selectedPartition="${selectedDevice}1"
}

assertDeviceIsOK() {
	failDevice() {
		echoerr "$1"
		listDevicesTable
		echoerr "Exiting..."
		exit 1
	}
	typeset -r device=$1
	if [ ! -e "$device" ]; then
		failDevice "The selected device \`$device' does not exists."
	fi
	if [ ! -b "$device" ]; then
		failDevice "The selected device \`$device' is not a valid block file."
	fi
	if [ ! -d "/sys/block/$(basename "$device")" ] || ! deviceIsDisk "$device"; then
		failAndExit "The selected device \`$device' is either unmounted or not a disk (might be a partition or loop).\\nSelect a disk instead or replug the USB device.\\nYou can check the availability of USB drives with \`$scriptName -l' command."
	fi
}

assertDeviceIsUSB() {
	typeset deviceType
	if [ "$disableUSBCheck" == 'true' ]; then
		echowarn "USB check has been disabled. Skipping."
		return 0
	fi
	deviceType=$(getDeviceType "$selectedDevice")
	if [ "$deviceType" != "usb" ]; then
		echoerr "The device you selected is not connected via USB (found BUS: \`$deviceType') and operation was therefore discarded."
		echowarn "Use \`--no-usb-check' option to bypass this policy at your own risks."
		echoerr "Exiting..."
		exit 1
	fi
	echogood "The selected device \`$selectedDevice' is connected through USB."
}

shouldWipeUSBKey() {
	typeset answer='y'
	echowarn "About to wipe out the content of device \`$selectedDevice'."
	if [ "$disableConfirmation" == 'false' ]; then
		read -r -p "         Are you sure you want to proceed? (y/n)>" answer
	else
		echowarn "Bypassing confirmation with \`-y, --assume-yes' option."
	fi
	if [ "$answer" == 'y' ]; then
		return 0
	else
		return 1
	fi
}

createMBRPartitionTable() {
	typeset sfdiskCommand='sfdisk'
	typeset sfdiskVersion=$(sfdisk -v | grep -Po '\d+\.\d+')
	typeset -Ar mbrTypeCodes=(['vfat']='c' ['exfat']='7' ['ntfs']='7' ['ext2']='83' ['ext3']='83' ['ext4']='83' ['f2fs']='83')
	typeset partitionOptions
	makeSfdiskCommand() {
		# Retrocompatibility for 'old' sfdisk versions
		if compute "$sfdiskVersion >= 2.28"; then
			sfdiskCommand='sfdisk -W always'
		fi
	}
	makeSfdiskCommand
	if [ "$notBootable" == true ]; then
		partitionOptions="$selectedPartition : start=2048, type=${mbrTypeCodes[$partitionType]}"
	else
		partitionOptions="$selectedPartition : start=2048, type=${mbrTypeCodes[$partitionType]}, bootable"
	fi
	echogood "Creating MBR partition table with \`sfdisk' v$sfdiskVersion..."
	# Create partition table
	echo "$partitionOptions" | $sfdiskCommand "$selectedDevice" |& indentAll || failAndExit "Failed to write USB device partition table."
	partprobe "$selectedDevice" # Refresh partition table
	sync
}

# $1: not-bootable, default false. When true, the partition will not be bootable.
partitionUSB() {
	typeset notBootable=${false:-1}
	# These options always end up with the label flag setter
	typeset -Ar mkfsOpts=(
		['vfat']="-v -F 32 -n" # Fat32 mode
		['exfat']="-n"
		['ntfs']="-Q -c 4096 -L" # Quick mode + cluster size = 4096 for Syslinux support
		['ext2']="-O ^64bit -L" # Disabling pure 64 bits compression for syslinux compatibility
		['ext3']="-O ^64bit -L" # see https://www.syslinux.org/wiki/index.php?title=Filesystem#ext
		['ext4']="-O ^64bit -L"
		['f2fs']="-l"
	)
	unmountPartitions() {
		typeset partition
		# unmount any partition on selected device
		mapfile -t devicePartitions < <(grep -oP "^\\K$selectedDevice\\S*" /proc/mounts)
		for partition in "${devicePartitions[@]}"; do
			if ! umount "$partition" >/dev/null; then
				failAndExit "Failed to unmount $partition. It's likely that partition is busy."
			fi
		done
	}
	eraseDevice() {
		echoinfo "Erasing contents of \`$selectedDevice'..."
		# clean signature from selected device
		wipefs --all --force "$selectedDevice" &>/dev/null
		# erase drive
		dd if=/dev/zero of="$selectedDevice" bs=512 count=1 conv=notrunc status=none |& indentAll || failAndExit "Failed to erase USB device.\\nIt's likely that the device has been ejected and needs to be replugged manually.\\nYou can check the availability of USB drives with \`$scriptName -l' command."
		sync
	}
	formatPartition() {
		# format
		echogood "Creating $partitionType partition on \`$selectedPartition'..."
		# shellcheck disable=SC2086
		mkfs -V -t "$partitionType" ${mkfsOpts[$partitionType]} "$partitionLabel" "$selectedPartition" |& indentAll || failAndExit "Failed to create $partitionType partition on USB device.\\nMake sure you have mkfs.$partitionType installed on your system."
	}
	if shouldWipeUSBKey; then
		unmountPartitions
		eraseDevice
		if [ "$shouldMakePartition" == 'true' ]; then
			createMBRPartitionTable
			formatPartition
		fi
	else
		failAndExit "Discarding operation."
	fi
}

mountUSB() {
	typeset type="$partitionType"
	usbMountPoint=$(createMountFolder usb) || exit "$?"
	temporaryAssets+=("$usbMountPoint")
	echoinfo "Created USB device mount point at \`$usbMountPoint'"
	if ! mount -t "$type" "$selectedPartition" "$usbMountPoint" >/dev/null; then
		failAndExit "Could not mount USB device."
	fi
}

updateProgress() {
	typeset sp="/-\\|"
	# print when launched from terminal
	if tty -s; then
		printf "\\b%s" "${sp:i++%${#sp}:1}"
	fi
	sleep 0.25
}

cleanProgress() {
	# print when launched from terminal
	if tty -s; then
		printf "\\b%s\\n" " "
	fi
}

syncWithProgress() {
	printProgress() {
		typeset -i isWriting=1
		typeset -i i=1
		echo -n "$scriptName: Synchronizing writes on device \`${selectedDevice}'    "
		while ((isWriting != 0)); do
			isWriting=$(awk '{ print $9 }' "/sys/block/${selectedDevice#/dev/}/stat")
			updateProgress
		done
		cleanProgress
	}
	sync &
	printProgress
}

copyWithRsync() {
	rsyncWithProgress() {
		typeset -i i=1
		typeset statusFile=$(createTempFile "bootiso-status")
		temporaryAssets+=("$statusFile")
		(
			rsync -r -q -I --no-links --no-perms --no-owner --no-group "$isoMountPoint"/. "$usbMountPoint"
			echo "$?" >"$statusFile"
		) &
		pid=$!
		echo -n "$scriptName: Copying files from ISO to USB device with \`rsync'    "
		while [ -e "/proc/$pid" ]; do
			updateProgress
		done
		cleanProgress
		typeset status=$(cat "$statusFile")
		if [ ! "$status" -eq 0 ]; then
			failAndExit "Copy command with \`rsync' failed.\\nIt's likely that your device has not enough space to contain the ISO image."
		fi
	}
	checkpkg 'rsync'
	rsyncWithProgress
	syncWithProgress
}

copyWithDD() {
	ddWithProgress() {
		typeset -i i=1
		typeset statusFile=$(createTempFile "bootiso-status")
		temporaryAssets+=("$statusFile")
		(
			dd if="$selectedIsoFile" of="$selectedDevice" bs=4MB status=none
			echo "$?" >"$statusFile"
		) &
		pid=$!
		echo -n "$scriptName: Copying files from ISO to USB device with \`dd'    "
		while [ -e "/proc/$pid" ]; do
			updateProgress
		done
		cleanProgress
		typeset status=$(cat "$statusFile")
		if [ ! "$status" -eq 0 ]; then
			failAndExit "Copy command with \`dd' failed. It's likely that your device has not enough space to contain the ISO image."
		fi
	}
	ddWithProgress
	syncWithProgress
}

installSyslinuxVersion() {
	typeset versions
	typeset minor
	typeset filename
	typeset rootURL="https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/Testing"
	typeset syslinuxArchive
	typeset assetURL
	typeset status
	typeset selectedSyslinuxVersion=$1
	typeset abortingMessage="Aborting SYSLINUX installation and resuming with local install."
	checkConnexion() {
		status=$(curl -sLIo /dev/null -w "%{http_code}" "$rootURL")
		if [ "$status" != 200 ]; then
			if [ "$status" == 000 ]; then
				failAndExit "You don't seem to have an internet connexion.\\nPlease try again later or use \`--local-bootloader' option to force usage of local SYSLINUX version."
				return 9
			else
				echowarn "Couldn't GET $rootURL.\\nReceived status code \`$status'.\\n$openTicketMessage\\n$abortingMessage"
				return 10
			fi
		fi
		return 0
	}
	findMinorVersions() {
		typeset syslinuxInstallDir
		versions="$(curl -sL "$rootURL" | grep -oP 'href="\K\d+\.\d+(?=/")' | sort --version-sort)"
		if (($? != 0)); then
			echowarn "Couldn't GET $rootURL.\\nAborting syslinux installation and resuming with local install."
			return 10
		elif [ -z "$versions" ]; then
			echoerr "Couldn't parse the result of $rootURL.\\nThis is not expected: please open a ticket at $ticketsurl.\\n$abortingMessage"
			return 11
		fi
		minor=$(echo "$versions" | grep -E "^$selectedSyslinuxVersion" | grep "^${selectedSyslinuxVersion%.}" | tail -n 1)
		if [ -z "$minor" ]; then
			echoerr "Version \`$selectedSyslinuxVersion' is not available at kernel.org."
			return 8
		fi
		return 0
	}
	findMatchedRelease() {
		filename=$(curl -sL "$rootURL/$minor/" | grep -oP 'href="\Ksyslinux-\d+\.\d+-\w+\d+\.tar\.gz(?=")' | sort --version-sort | tail -n1)
		if [ -z "$filename" ]; then
			echoerr "Couldn't find \`$filename'."
			return 11
		fi
		assetURL="$rootURL/$minor/$filename"
		syslinuxArchive=$cacheRoot/$filename
		return 0
	}
	downloadMatchedVersion() {
		if [ -e "$syslinuxArchive" ]; then
			echogood "Found \`$syslinuxArchive' in cache."
			return 0
		fi
		if curl -sL -o "$syslinuxArchive" "$assetURL"; then
			if [ -f "$syslinuxArchive" ]; then
				echogood "Download of \`$syslinuxArchive' completed ($(du -h "$syslinuxArchive" | awk '{print $1}'))"
			else
				echowarn "Missing file \`$syslinuxArchive'.\\nThis is not expected: please open a ticket at $ticketsurl.\\n$abortingMessage"
				return 10
			fi
		else
			echowarn "Couldn't get \`$assetURL'.\\nThis is not expected: please open a ticket at $ticketsurl.\\n$abortingMessage"
			return 10
		fi
		return 0
	}
	extractMatchedVersion() {
		if tar -xf "$syslinuxArchive" -C "$tempRoot"; then
			syslinuxInstallDir="$tempRoot/$(basename "${syslinuxArchive%.tar.gz}")"
			temporaryAssets+=("$syslinuxInstallDir")
		else
			rm "$syslinuxArchive"
			return 11
		fi
	}
	configureSyslinuxInstall() {
		typeset extlinuxBin=$(findFileFromPatterns "$syslinuxInstallDir" 'bios/extlinux/extlinux' 'extlinux/extlinux' 'extlinux')
		typeset mbrBin=$(findFileFromPatterns "$syslinuxInstallDir" 'bios/mbr/mbr.bin' 'mbr/mbr.bin' 'mbr.bin')
		if [ -z "$extlinuxBin" ]; then
			echowarn "Couldn't find \`extlinux' binary in installation folder.\\n$abortingMessage"
			return 10
		fi
		if [ -z "$mbrBin" ]; then
			echowarn "Couldn't find \`mbr.bin' in installation folder.\\n$abortingMessage"
			return 10
		fi
		syslinuxInstall['mbrBin']="$mbrBin"
		syslinuxInstall['extBin']="$extlinuxBin"
		return 0
	}
	checkpkg 'curl'
	inferSyslinuxVersion
	checkConnexion || return "$?"
	findMinorVersions || return "$?"
	findMatchedRelease || return "$?"
	downloadMatchedVersion || return "$?"
	extractMatchedVersion || return "$?"
	configureSyslinuxInstall || return "$?"
	echogood "SYSLINUX version \`$minor' temporarily set for installation."
}

installBootloader() {
	typeset syslinuxFolder
	typeset syslinuxConfig
	typeset -i versionsMatch=0
	typeset localSyslinuxVersion
	inferSyslinuxVersion() {
		localSyslinuxVersion=$(syslinux --version |& grep -oP '(\d+\.\d+)')
		if [ "$selectedBootloaderVersion" != 'auto' ]; then
			syslinuxVersion="$selectedBootloaderVersion"
		else
			syslinuxVersion=${isoInspection['syslinuxVer']:-"$localSyslinuxVersion"}
		fi
	}
	# return 0 : install from kernel.org
	# return 1+: install from local
	checkSyslinuxVersion() {
		if [ "$localBootloader" == "true" ]; then
			echogood "Enfoced local SYSLINUX bootloader at version \`$localSyslinuxVersion'."
			return 1
		fi
		if [ -z "$syslinuxVersion" ]; then
			return 1
		fi
		if [ "$selectedBootloaderVersion" != 'auto' ]; then
			echoinfo "Searching for SYSLINUX V$syslinuxVersion remotely."
			if ! installSyslinuxVersion "$syslinuxVersion"; then
				if [ ! -z "${isoInspection['syslinuxVer']}" ]; then
					echowarn "Falling back to ISO SYSLINUX version \`${isoInspection['syslinuxVer']}'"
					syslinuxVersion="${isoInspection['syslinuxVer']}"
					installSyslinuxVersion "${isoInspection['syslinuxVer']}"
					return $?
				else
					return 1
				fi
			else
				return 0
			fi
		fi
		echoinfo "Found local SYSLINUX version \`$localSyslinuxVersion'"
		compute "$localSyslinuxVersion == ${isoInspection['syslinuxVer']}" >/dev/null
		versionsMatch=$?
		if ((versionsMatch == 0)); then
			echogood "ISO SYSLINUX version matches local version."
			return 1
		else
			typeset -i status
			echowarn "ISO SYSLINUX version doesn't match local version.\\nScheduling download of version $syslinuxVersion..."
			if ! installSyslinuxVersion "$syslinuxVersion"; then
				echowarn "Falling back to local SYSLINUX version \`$localSyslinuxVersion'."
				syslinuxVersion="$localSyslinuxVersion"
				return 1
			fi
		fi
	}
	setSyslinuxLocation() {
		if [[ "${isoInspection['syslinuxConf']}" =~ isolinux.cfg ]]; then
			typeset isolinuxConfig="$usbMountPoint${isoInspection['syslinuxConf']}"
			typeset isoFolder=$(dirname "$isolinuxConfig")
			syslinuxConfig="$isoFolder/syslinux.cfg"
			mv "$isolinuxConfig" "$syslinuxConfig"
			echoinfo "Found ISOLINUX config file at \`$isolinuxConfig'.\\nMoving to \`$syslinuxConfig'."
		else
			syslinuxConfig="$usbMountPoint${isoInspection['syslinuxConf']}"
		fi
		syslinuxFolder=$(dirname "$syslinuxConfig")
	}
	installWtLocalExtlinux() {
		syslinuxInstall=(['mbrBin']="$foundSyslinuxMbrBinary" ['extBin']='extlinux')
		syslinuxVersion="$localSyslinuxVersion"
		echoinfo "Installing SYSLINUX bootloader in \`$syslinuxFolder' with local version \`$syslinuxVersion'..."
		rsync --no-links --no-perms --no-owner --no-group -I "$foundSyslinuxBiosFolder"/*.c32 "$syslinuxFolder" |& indentAll || echowarn "SYSLINUX could not install C32 BIOS modules."
		sync
		echogood "C32 BIOS modules successfully installed."
		${syslinuxInstall['extBin']} --stupid --install "$syslinuxFolder" |& indentAll || failAndExit "SYSLINUX bootloader could not be installed."
		sync
	}
	installWtKernelOrgExtlinux() {
		echoinfo "Installing SYSLINUX bootloader in \`$syslinuxFolder' with kernel.org version \`$syslinuxVersion'..."
		if ! ${syslinuxInstall['extBin']} --stupid --install "$syslinuxFolder" |& indentAll; then
			echowarn "kernel.org version \`$syslinuxVersion' could not be run.\\nAttempting with local SYSLINUX install..."
			installWtLocalExtlinux >/dev/null
		fi
		sync
	}
	installMasterBootRecordProg() {
		dd bs=440 count=1 conv=notrunc status=none if="${syslinuxInstall['mbrBin']}" of="$selectedDevice" |& indentAll || failAndExit "Failed to install Master Boot Record program."
		sync
		echogood "Succesfully installed Master Boot Record program."
	}
	inferSyslinuxVersion
	setSyslinuxLocation
	checkSyslinuxVersion
	case $? in
	0) installWtKernelOrgExtlinux ;;
	*) installWtLocalExtlinux ;;
	esac
	echogood "Successfully installed SYSLINUX bootloader at version \`$syslinuxVersion'."
	installMasterBootRecordProg
}

checkAction() {
	typeset -ra actions=('help' 'version' 'format' 'install-dd' 'install-mount-rsync' 'list-usb-drives' 'inspect' 'probe')
	typeset -a enabledActions=()
	typeset act
	for act in "${actions[@]}"; do
		if [ "${userFlags[$act]}" == 'true' ]; then
			enabledActions+=("$act")
		fi
	done
	if ((${#enabledActions[@]} == 0)); then
		action='install-auto'
	elif ((${#enabledActions[@]} == 1)); then
		action=${enabledActions[0]}
	else
		failAndExit "You cannot invoke multiple actions at once: $(joinBy '+' "${enabledActions[@]}")."
	fi
}

checkUserVars() {
	# check partition type
	if [ ! -z "${userVars['type']}" ]; then
		if [ "${userVars['type'],,}" == fat32 ]; then
			userVars['type']=vfat
		fi
		typeset partType=${vfat:-${userVars['type']}}
		if ! containsElement "$partType" "${supportedFS[@]}"; then
			failAndExit "FS type \`$partType' not supported.\\nSupported FS types: $(joinBy "," "${supportedFS[*]}")."
		fi
		if ! containsElement "$action" "install-mount-rsync" "format"; then
			failAndExit "Cannot set partition type with action [$action].\\n\`-t, --type' option is compatible with [format] and [install-mount-rsync] actions only."
		fi
		if ! command -v "mkfs.$partType" &>/dev/null; then
			failAndExit "Program \`mkfs.$partType' could not be found on your system.\\nPlease install it and retry."
		fi
	fi
	# check device
	if [ ! -z "${userVars['device']}" ]; then
		if [[ ! "${userVars['device']}" =~ '/dev/' ]] && [ -e "/dev/${userVars['device']}" ]; then
			userVars['device']="/dev/${userVars['device']}"
		fi
		assertDeviceIsOK "${userVars['device']}"
	fi
	if [ ! -z "${userVars['remote-bootloader']}" ] && [[ ! "${userVars['remote-bootloader']}" =~ ^[0-9]+\.[0-9]+$ ]]; then
		failAndExit "Remote bootloader version \`${userVars['remote-bootloader']}' set with \`--remote-bootloader' doesn't follow MAJOR.MINOR pattern.\\nValid examples are 4.10, 6.02"
	fi
}

checkUserFlags() {
	# Autoselect security
	if [ "${userFlags['autoselect']}" == 'true' ] && [ "${userFlags['no-usb-check']}" == 'true' ]; then
		failAndExit "You cannot set \`-a, --autoselect' option while disabling USB check with \`--no-usb-check'."
	fi
	# warnings (only with sudo)
	if ((EUID == 0)); then
		# Eject format
		if [ "${userFlags['no-eject']}" == "true" ] && [ "$action" == "format" ]; then
			echowarn "You don't need to prevent device ejection through \`-J' flag with \`format' action."
		fi
		# Warn autoselecting while assume yes is false
		if [ "${userFlags['autoselect']}" == 'true' ] && [ "${userFlags['assume-yes']}" == 'false' ]; then
			echowarn "\`-a, --autoselect' option is enabled by default when \`-y, --asume-yes' option is not set."
		fi
	fi
}

checkFlagMatrix() {
	typeset key
	for key in "${!userVarsCompatibilityMatrix[@]}"; do
		if [ ! -z "${userVars[$key]}" ]; then
			#shellcheck disable=SC2086
			if ! containsElement "$action" ${userVarsCompatibilityMatrix[$key]}; then
				if [ "$key" == "iso-file" ]; then
					failAndExit "[$action] action doesn't require any arguments."
				else
					failAndExit "[$action] action doesn't support option \`--$key'.\\nSee https://github.com/jsamr/bootiso#options"
				fi
			fi
		fi
	done
	for key in "${!userFlagsCompatibilityMatrix[@]}"; do
		if [ ! -z "${userFlags[$key]}" ]; then
			#shellcheck disable=SC2086
			if ! containsElement "$action" ${userFlagsCompatibilityMatrix[$key]}; then
				failAndExit "\`$action' action doesn't support option \`--$key'.\\nSee https://github.com/jsamr/bootiso#options"
			fi
		fi
	done
}

cleanup() {
	removeTempAsset() {
		if [[ "$1" =~ ^$tempRoot ]] || [[ "$1" =~ ^$mountRoot ]]; then
			if [ -d "$1" ]; then
				rm -rf "$1"
			elif [ -f "$1" ]; then
				rm "$1"
			else
				echowarn "Skipping deletion of unexpected asset type at \`$1'."
			fi
		else
			echowarn "Skipping deletion of unexpected temporary asset at \`$1'."
		fi
	}
	ejectDevice() {
		if [[ "$operationSuccess" =~ ^install ]]; then
			if [ "$noDeviceEjection" == 'false' ]; then
				if eject "$selectedDevice" |& indentAll; then
					echogood "USB device succesfully ejected.\\nYou can safely remove it!"
				else
					echowarn "Failed to eject device \`$selectedDevice'."
				fi
			else
				echoinfo "USB device ejection skipped with \`-J, --no-eject' option."
			fi
		fi
	}
	if ((EUID == 0)); then
		typeset asset
		umountISO
		umountUSB
		for asset in "${temporaryAssets[@]}"; do
			removeTempAsset "$asset"
		done
		ejectDevice
	fi
}

assignInternalVariables() {
	# Command argument
	selectedIsoFile=${userVars['iso-file']:-''}
	# Option flags
	disableConfirmation=${userFlags['assume-yes']:-'false'}
	autoselect=${userFlags['autoselect']:-'false'}
	localBootloader=${userFlags['local-bootloader']:-'false'}
	disableMimeCheck=${userFlags['no-mime-check']:-'false'}
	disableUSBCheck=${userFlags['no-usb-check']:-'false'}
	# Vars flags
	partitionType=${userVars['type']:-'vfat'}
	selectedDevice=${userVars['device']:-''}
	partitionLabel=${userVars['label']:-''}
	selectedBootloaderVersion=${userVars['remote-bootloader']:-'auto'}
	# Action-dependent flags
	case $action in
	install-*)
		hasActionDuration='true'
		expectingISOFile='true'
		requiresRoot='true'
		noDeviceEjection=${userFlags['no-eject']:-'false'}
		;;
	format)
		hasActionDuration='true'
		expectingISOFile='false'
		requiresRoot='true'
		;;
	version)
		hasActionDuration='false'
		expectingISOFile='false'
		requiresRoot='false'
		;;
	help | list-usb-drives)
		hasActionDuration='false'
		expectingISOFile='false'
		requiresRoot='false'
		;;
	inspect | probe)
		hasActionDuration='false'
		expectingISOFile='true'
		requiresRoot='true'
		;;
	*)
		failAndExit "Unhandled action \`$action'.\\n$openTicketMessage"
		;;
	esac
}

startTimer() {
	startTime=$(date +%s)
}

stopTimerAndPrintLapsed() {
	endTime=$(date +%s)
	echogood "Took $((endTime - startTime)) seconds to perform [$action] action."
}

runSecurityAssessments() {
	configureLabel
	selectDevice
	startTimer
	assertDeviceIsOK "$selectedDevice"
	assertDeviceIsUSB
}

inspectISO() {
	typeset -a sysLinuxLocations=('boot/syslinux/syslinux.cfg' 'syslinux/syslinux.cfg' 'syslinux.cfg' 'boot/syslinux/extlinux.conf' 'boot/syslinux/extlinux.cfg' 'boot/extlinux/extlinux.conf' 'boot/extlinux/extlinux.cfg' 'syslinux/extlinux.conf' 'syslinux/extlinux.cfg' 'extlinux/extlinux.conf' 'extlinux/extlinux.cfg' 'extlinux.conf' 'extlinux.cfg')
	typeset -a isoLinuxLocations=('boot/isolinux/isolinux.cfg' 'isolinux/isolinux.cfg' 'isolinux.cfg' 'boot/syslinux/isolinux.cfg' 'syslinux/isolinux.cfg')
	typeset syslinuxFolder
	typeset syslinuxConfig
	typeset isHybrid
	typeset supportsEFIBoot
	typeset syslinuxBinary
	typeset isoSyslinuxVersion
	inspectSyslinux() {
		syslinuxBinary=$(matchFirstExpression "$isoMountPoint" 'syslinux.bin' 'isolinux.bin' 'extlinux.bin' 'boot.bin' 'extlinux' 'syslinux' 'isolinux')
		if [ ! -z "$syslinuxBinary" ]; then
			isoSyslinuxVersion=$(strings "$syslinuxBinary" | grep -E 'ISOLINUX|SYSLINUX|EXTLINUX' | grep -oP '(\d+\.\d+)' | awk 'NR==1{print $1}')
		fi
		syslinuxConfig=$(findFileFromPatterns "$isoMountPoint" "${sysLinuxLocations[@]}")
		if [ -z "$syslinuxConfig" ]; then
			syslinuxConfig=$(matchFirstExpression "$isoMountPoint" 'syslinux.cfg' 'extlinux.conf' 'extlinux.cfg')
		fi
		if [ -z "$syslinuxConfig" ]; then
			syslinuxConfig=$(findFileFromPatterns "$isoMountPoint" "${isoLinuxLocations[@]}")
			syslinuxConfig=${syslinuxConfig:-$(firstMatchInFolder "$isoMountPoint" 'isolinux.cfg')}
		fi
	}
	inspectISOFilesystem() {
		file -b -- "$selectedIsoFile" | grep -q '^ISO 9660 CD-ROM filesystem'
		if (($? == 0)); then
			isHybrid=false
		else
			isHybrid=true
		fi
	}
	inspectEFICapabilities() {
		typeset hasEfiRoot=$(find "$isoMountPoint" -type d -iname 'efi' -print -quit)
		typeset hasEfiFile=$(find "$isoMountPoint" -type f -ipath '*/efi/*.efi' -prune -print -quit)
		supportsEFIBoot=false
		if [ ! -z "$hasEfiFile" ] && [ ! -z "$hasEfiRoot" ]; then
			supportsEFIBoot=true
		fi
	}
	inspectISOFilesystem
	mountISOFile >/dev/null
	inspectSyslinux
	inspectEFICapabilities
	umountISO >/dev/null
	# set relative paths
	isoInspection['syslinuxConf']=${syslinuxConfig#${isoMountPoint}}
	isoInspection['syslinuxBin']=${syslinuxBinary#${isoMountPoint}}
	isoInspection['syslinuxVer']=$isoSyslinuxVersion
	isoInspection['isHybrid']=$isHybrid
	isoInspection['supportsEFIBoot']=$supportsEFIBoot
}

inspectISOBootCapabilities() {
	typeset uefiCompatible=${isoInspection['supportsEFIBoot']}
	typeset syslinuxCompatible=false
	if [ "${isoInspection['supportsEFIBoot']}" == "true" ]; then
		if [ "$partitionType" != "vfat" ]; then
			echowarn "Found UEFI boot capabilities but you selected \`$partitionType' type, which is not compatible with UEFI boot.\\nBe warned that only legacy boot will work, if any."
		else
			uefiCompatible=true
			echogood "UEFI boot check validated. Your USB will work with UEFI boot."
		fi
	fi
	if [ ! -z "${isoInspection['syslinuxConf']}" ]; then
		syslinuxCompatible=true
		addSyslinuxBootloader=true
		if [ ! -z "${isoInspection['syslinuxVer']}" ]; then
			echogood "Found SYSLINUX config file and binary at version ${isoInspection['syslinuxVer']}."
		elif [ ! -z "${isoInspection['syslinuxBin']}" ]; then
			echogood "Found SYSLINUX config file and binary with unknown version."
		else
			echogood "Found SYSLINUX config file."
		fi
		echogood "A SYSLINUX booloader will be installed on your USB."
	fi
	if [ "$syslinuxCompatible" == false ] && [ "$uefiCompatible" == false ]; then
		failAndExit "The selected ISO is not hybrid, doesn't supports UEFI nor legacy booting with SYSLINUX.\\nTherefore, it cannot result in any successful booting with $scriptName.\\nConsider following the documentation provided with this ISO file."
	fi
}

checkSyslinuxInstall() {
	checkpkg 'syslinux'
	if ! command -v extlinux > /dev/null; then
		failAndExit "Your distribution doesn't ship \`extlinux' binary with \`syslinux' package.\\nPlease install \`extlinux' and try again."
	fi
	foundSyslinuxBiosFolder=$(find /usr/lib/syslinux/ -type d -path '*/bios' -print -quit)
	foundSyslinuxMbrBinary=$(findFileFromPatterns /usr/lib/syslinux 'bios/mbr.bin' 'mbr.bin')
	if [ -z "$foundSyslinuxBiosFolder" ]; then
		failAndExit "Could not find a SYSLINUX bios folder containing c32 bios module files on this system."
	fi
	if [ -z "$foundSyslinuxMbrBinary" ]; then
		failAndExit "Could not find a SYSLINUX MBR binary file on this system."
	fi
}

printISOBootCapabilities() {
	typeset uefiCompatible=${isoInspection['supportsEFIBoot']}
	typeset syslinuxCompatible=false
	typeset isHybrid=${isoInspection['isHybrid']}
	typeset syslinux='SYSLINUX'
	if [ ! -z "${isoInspection['syslinuxConf']}" ]; then
		syslinuxCompatible=true
	fi
	if [ ! -z "${isoInspection['syslinuxVer']}" ]; then
		syslinux+=" ${isoInspection['syslinuxVer']}"
	fi
	echoinfo "Reporting \`$selectedIsoFile' boot capabilities:"
	if [ "$isHybrid" == false ] && [ "$syslinuxCompatible" == false ] && [ "$uefiCompatible" == false ]; then
		echoerr "The selected ISO is not hybrid, doesn't supports UEFI nor legacy BIOS booting with SYSLINUX.\\nIt cannot result in any successful booting with $scriptName."
	elif [ "$isHybrid" == false ] && [ "$syslinuxCompatible" == true ] && [ "$uefiCompatible" == false ]; then
		echogood "The selected ISO is not hybrid, but supports legacy BIOS booting with $syslinux.\\nIt should result in successfull booting with $scriptName in [install-auto] and [install-mount-rsync] modes with any PC BIOS."
	elif [ "$isHybrid" == false ] && [ "$syslinuxCompatible" == false ] && [ "$uefiCompatible" == true ]; then
		echogood "The selected ISO is not hybrid, but supports UEFI boot.\\nIt will result in successfull booting with $scriptName in [install-auto] and [install-mount-rsync] modes with modern UEFI-enabled PC BIOS."
	elif [ "$isHybrid" == false ] && [ "$syslinuxCompatible" == true ] && [ "$uefiCompatible" == true ]; then
		echogood "The selected ISO is not hybrid, but supports legacy BIOS booting with $syslinux and UEFI boot.\\nIt will result in successfull booting with $scriptName in [install-auto] and [install-mount-rsync] modes with any PC BIOS."
	elif [ "$isHybrid" == true ] && [ "$syslinuxCompatible" == false ] && [ "$uefiCompatible" == false ]; then
		echowarn "The selected ISO is hybrid, but doesn't support UEFI nor SYSLINUX legacy BIOS bootloader.\\nIt should result in successfull booting with $scriptName in [install-auto] and [install-dd] modes, while $scriptName is not aware of its booting scheme."
	elif [ "$isHybrid" == true ] && [ "$syslinuxCompatible" == true ] && [ "$uefiCompatible" == false ]; then
		echogood "The selected ISO is hybrid and supports legacy BIOS booting with $syslinux.\\nIt will result in successfull booting with $scriptName in [install-auto] and [install-dd] modes with any PC BIOS."
	elif [ "$isHybrid" == true ] && [ "$syslinuxCompatible" == false ] && [ "$uefiCompatible" == true ]; then
		echogood "The selected ISO is hybrid and supports UEFI boot.\\nIt will result in successfull booting with $scriptName in [install-auto] and [install-dd] modes with modern UEFI-enabled PC BIOS."
	elif [ "$isHybrid" == true ] && [ "$syslinuxCompatible" == true ] && [ "$uefiCompatible" == true ]; then
		echogood "The selected ISO is hybrid and supports legacy BIOS booting with $syslinux along with UEFI boot.\\nIt will result in successfull booting with $scriptName in [install-auto] and [install-dd] modes with any PC BIOS."
	fi
	typeset localSyslinuxVersion=$(syslinux --version |& grep -oP '(\d+\.\d+)')
	if [ "$syslinuxCompatible" == true ] && [ ! -z "${isoInspection['syslinuxVer']}" ] && [ "$isHybrid" == false ]; then
		if compute "$localSyslinuxVersion == ${isoInspection['syslinuxVer']}"; then
			echogood "Furthermore, SYSLINUX version in ISO file matches local version (${isoInspection['syslinuxVer']})."
		elif compute "${localSyslinuxVersion%.*} == ${isoInspection['syslinuxVer']%.*}"; then
			echoinfo "However, SYSLINUX version (${isoInspection['syslinuxVer']}) in ISO file doesn't match minor part of local version ($localSyslinuxVersion) which should not cause any problems."
		else
			echowarn "However, SYSLINUX version (${isoInspection['syslinuxVer']}) in ISO file doesn't match major part of local version ($localSyslinuxVersion).\\n$scriptName will try to download and execute this version from kernel.org, unless given the option \`--local-bootloader'.\\nIn last resort if that fails, it will attempt installation with local version of SYSLINUX."
		fi
	fi
}

execProbe() {
	printISOBootCapabilities
	listDevicesTable
}

execWithRsync() {
	shouldMakePartition=true
	checkSyslinuxInstall
	inspectISOBootCapabilities
	runSecurityAssessments
	mountISOFile
	partitionUSB false
	mountUSB
	copyWithRsync
	if [ "$addSyslinuxBootloader" == 'true' ]; then
		installBootloader
	fi
}

execWithDD() {
	shouldMakePartition=false
	runSecurityAssessments
	partitionUSB false
	copyWithDD
}

execAuto() {
	if [ "${isoInspection['isHybrid']}" == "true" ]; then
		echogood "Found hybrid ISO; choosing image copy \`dd' mode."
		execWithDD
	else
		echoinfo "Found non-hybrid ISO; inspecting ISO for boot capabilities..."
		execWithRsync
	fi
}

execFormat() {
	shouldMakePartition=true
	selectDevice
	startTimer
	configureLabel
	assertDeviceIsOK "$selectedDevice"
	assertDeviceIsUSB
	partitionUSB true
}

checkArguments() {
	checkAction
	checkUserVars
	checkUserFlags
}

main() {
	mkdir -p "$tempRoot"
	initPckgManager "$@"
	parseArguments "$@"
	checkArguments
	assignInternalVariables
	checkFlagMatrix
	checkPackages
	if [ "$expectingISOFile" == 'true' ]; then
		assertISOIsOK
	fi
	if [ "$requiresRoot" == 'true' ]; then
		checkSudo "$@"
		configureFolders
	fi
	if [ "$expectingISOFile" == 'true' ]; then
		inspectISO
	fi
	case "$action" in
	'install-auto') execAuto "$@" ;;
	'install-dd') execWithDD "$@" ;;
	'install-mount-rsync') execWithRsync "$@" ;;
	'format') execFormat "$@" ;;
	'inspect') printISOBootCapabilities ;;
	'probe') execProbe "$@" ;;
	'list-usb-drives') listDevicesTable ;;
	'version') echo "$version" ;;
	'help') display_help ;;
	*) failAndExit "Unexpected action [$action].\\n$openTicketMessage" ;;
	esac
	if [ "$hasActionDuration" == 'true' ]; then
		stopTimerAndPrintLapsed
	fi
	operationSuccess=$action
}

trap cleanup EXIT INT TERM
main "$@"
