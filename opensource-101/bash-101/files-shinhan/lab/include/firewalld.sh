#!/bin/bash

function SetFirewall(){
  local firewalld_srv_name=$1			## firewalld
  echo -e "\e[34mset up a $firewalld_srv_name protocol to Firewalld...\e[0m"
  firewall-cmd --add-service=${firewalld_srv_name} 2> /dev/null
  firewall-cmd --runtime-to-permanent
  logger -i -p local3.info "ADDED $firewalld_srv_name FIREWALLD SERVICE"
}

function ListFirewall(){
  local firewalld_srv_name=$1			## firewalld
  echo -e "\e[34mverify to $firewalld_srv_name protocol on Firewalld...\e[0m"

  if [[ $(firewall-cmd --list-services) =~ $firewalld_srv_name ]] ; then
    echo "it's good"
  else
    echo "it's not good"
  fi
  logger -i -p local3.info "SHOWED $firewalld_srv_name FIREWALLD SERVICE LIST"
}

function RemoveFirewall(){
  local firewalld_srv_name=$1			## firewalld
  echo -e "\e[34mremove to $firewalld_srv_name protocol on Firewalld...\e[0m"
  firewall-cmd --remove-service=$firewalld_srv_name
  logger -i -p local3.info "REMOVED $firewalld_srv_name FIREWALLD SERVICE LIST"

}
