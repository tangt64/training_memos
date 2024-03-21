#!/bin/bash

nm-ip4="172.25.21.201/20"
nm-gw4="172.24.16.1"
nm-dns="8.8.8.8"
nm-type="manual"
nm-name="eth0"
nm-hostname="servera.example.com"
nm-chrony="ntp.example.com"

echo "setup up to network configureation..."

nmcli con mod ipv4.addresses $(nm-ip4) ipv4.gateway $(nm-gw4) ipv4.dns $(nm-dns) ipv4.method $(nm-type) $(nm-name)

echo "NM connection up..."
nmcli con up $(nm-name)

echo "setup a hostname..."
hostnamectl set-hostname $(nm-hostname)
echo "This host name is $(hostname)"

echo "setup the chorny NTP server as $(nm-chrony)."
sed -i 's/pool 2.rocky.pool.ntp.org iburst/ntp.example.com/' /etc/chronyd.conf

echo "restart to chronyd service..."
systemctl restart chronyd.service