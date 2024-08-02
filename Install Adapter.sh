#!/bin/bash

# What it does:
# Install some packages needed for this + other stuff
# Gets the drivers from a git repository and installs them
# Enables the Wifi-adapter and gives it an ip

# Version history:
# 0.1 	- Base script using hardcoded dongle name + install dependencies
# 0.2 	- If/else to see if dongle is up
# 0.2.1	- Minor if/else edits for the wifi check
# 0.2.2 - IP+mask on dongle using ifconfig
# 0.2.3 - Multi-line commenting used for ignoring part of script for debugging
# 0.2.4 - Added root-check as the script needs root privileges to run properly.

# Todo:
# Make change from ifconfig to ip command as ifconfig is deprecated(?)

################################################

# Script needs to be run as root, checking:
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root."
	exit 1
fi

# Some variables that will be parameters at some point in the script:
wifiDongleName="wlx00c0cab369ef"
wifiDongleIP="192.168.169.1"
wifiDongleMask="255.255.255.0"


# Some error variables in order to give a status report at the end of the script
wifiDongleError=0

echo "Please execute script in a folder where you can have downloads + configfiles"
read -p "Press enter to Continue or CTRL+C to abort"

#: <<'DRIVER_INSTALLMENT_DELIMITER' # If Driver dl/install is not needed
echo "Executing setupScript"
# First update
sudo apt update

# Install all dependencies
echo "Install all dependencies + ping and ssh"
sudo apt install -y git build-essential hostapd dnsmasq iptables net-tools iputils-ping openssh-server

# Drivers for the USB dongle (ALFA AWUS something...)
echo "Drivers for the USB dongle..."
sudo mkdir downloads
cd downloads
sudo git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au/
sudo make
cd ..
cd ..

sudo make -C ./downloads/rtl8812au/ install

#DRIVER_INSTALLMENT_DELIMITER
# Getting the USB wifi up and running!
read -p "Insert / Reinsert the USB WIFI-dongle before pressing enter"
sleep 5
sudo ip link set $wifiDongleName up
echo "Script halt success!"


# Check if the Wifi-Dongle is found and has the UP flag + set IP/mask
if ifconfig | grep "$wifiDongleName" | grep -q "UP"; then
# Show status in green text with yellow background
	echo -e "\033[0;32mWifi-Dongle is up and running!\033[0m"
	sleep 2 # So its possible to read
	sudo ifconfig $wifiDongleName $wifiDongleIP netmask $wifiDongleMask
	echo -e "\033[0;32m$wifiDongleIP is set\033[0m"
	sleep 3
else
# Show status in red
	wifiDongleError=1 # For summary at the end of script
	echo -e "\033[0;31mWifi-Dongle is not up, debug when script is done\033[0m"
	sleep 3
fi
