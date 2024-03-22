#!/bin/bash
firewalld_srv_name=$1			## firewalld
systemd_srv_name=$2	         	## systemd

echo -e "\e[34mset up a $firewalld_srv_name protocol to Firewalld...\e[0m"
firewall-cmd --add-service=${firewalld_srv_name} 2> /dev/null
firewall-cmd --runtime-to-permanent
logger -i -p local3.info "ADDED FIREWALLD SERVICE"

echo -e "\e[34mverify to $firewalld_srv_name protocol on Firewalld...\e[0m"
firewall-cmd --list-services
logger -i -p local3.info "SHOWED FIREWALLD SERVICE LIST"

echo -e "\e[34mstart to a $systemd_srv_name service from systemd...\e[0m"
systemctl enable --now $systemd_srv_name.service
echo "the $systemd_srv_name is $(systemctl is-active $systemd_srv_name)."
echo "the $systemd_srv_name is $(systemctl is-enabled $systemd_srv_name)."
logger -i -p local3.info "STARTED AND ENABLED $systemd_srv_name"

