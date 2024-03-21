#!/bin/bash
printf "please input firewalld service name: "
read firewalld_srv_name                 ## firewalld
printf "please input systemd service name: "
read systemd_srv_name                   ## systemd

echo "set up a $firewalld_srv_name protocol to Firewalld..."

firewall-cmd --add-service=${firewalld_srv_name} || exit
firewall-cmd --runtime-to-permanent

echo "verify to $firewalld_srv_name protocol on Firewalld..."
firewall-cmd --list-services | grep -e $firewalld_srv_name

echo "start to a $systemd_srv_name service from systemd..."
systemctl enable --now $systemd_srv_name.service
echo "the $systemd_srv_name is $(systemctl is-active $systemd_srv_name)."
echo "the $systemd_srv_name is $(systemctl is-enabled $systemd_srv_name)."