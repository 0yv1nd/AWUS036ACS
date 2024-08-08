#!/bin/bash

# What it does:
# Check if some packages are installed
# (tmux not needed, just for convenience)
# Creates a hostapd and dnsmasq configfile

# Check for packages to be installed and installing if not present
packages=("hostapd" "dnsmasq" "tmux")

for package in "${packages[@]}"
do
  if dpkg -s "$package" >/dev/null 2>&1; then
    echo "$package is installed"
  else
    echo "$package is not installed. Installing..."
    sudo apt install -y "$package"
  fi
done


# Write a simple config file for hostapd and dnsmasq

# Replace with your desired SSID, passphrase, and DHCP range
SSID="MySSID"
PASSPHRASE="MyPw4wifi"
DHCP_START="192.168.169.100"
DHCP_END="192.168.169.200"
LEASE_TIME="12h"

# Interface names, you need to check if these are correct
WIFI_INTERFACE="wlx00c0cab369ef"
ETHERNET_INTERFACE="ens33"

# Config file paths
DNSMASQ_CONF="dnsmasq.conf"
HOSTAPD_CONF="hostapd.conf"

# Function to create dnsmasq config
create_dnsmasq_config() {
  cat > $DNSMASQ_CONF <<EOF
interface=$WIFI_INTERFACE
bind-interfaces
port=53

# DNS servers
server=8.8.8.8
server=8.8.4.4

# DHCP range
dhcp-range=$DHCP_START,$DHCP_END,$LEASE_TIME
EOF
}

# Function to create hostapd config
create_hostapd_config() {
  cat > $HOSTAPD_CONF <<EOF
interface=$WIFI_INTERFACE
driver=nl80211
ssid=$SSID
wpa_passphrase=$PASSPHRASE
hw_mode=g
channel=6
wpa=3
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=TKIP CCMP
EOF
}


configure_iptables() {
  # add to /etc/sysctl.conf for permanent ipv4 forwarding
  sudo sysctl -w net.ipv4.ip_forward=1
  # Function to configure IP tables  
  sudo iptables -t nat -A POSTROUTING -o $ETHERNET_INTERFACE -j MASQUERADE
  sudo iptables -A FORWARD -i $WIFI_INTERFACE -o $ETHERNET_INTERFACE -j ACCEPT
}

# Main script
create_dnsmasq_config
create_hostapd_config
configure_iptables

echo "Start dnsmasq and hostapd"
echo "sudo dnsmasq -d -C configFile"
echo "sudo hostapd configFile"
