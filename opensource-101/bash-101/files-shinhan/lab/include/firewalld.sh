#!/bin/bash

function SetFirewall(){
  local firewalld_srv_name=$1			## firewalld

  echo -e "\e[34mset up a $firewalld_srv_name protocol to Firewalld...\e[0m"
  firewall-cmd --add-service=${firewalld_srv_name} 2> /dev/null
  firewall-cmd --runtime-to-permanent
  logger -i -p local3.info "ADDED FIREWALLD SERVICE"
}

function ListFirewall(){
  local firewalld_srv_name=$1			## firewalld

  echo -e "\e[34mverify to $firewalld_srv_name protocol on Firewalld...\e[0m"
  firewall-cmd --list-services
  logger -i -p local3.info "SHOWED FIREWALLD SERVICE LIST"
}
