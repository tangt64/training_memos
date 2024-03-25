#!/bin/bash


function CreateUser(){
  local uname=$1
  local upasswd=$2
  echo -e "\e[31mcreate a user with password...\e[0m"
  adduser $uname -p $(mkpasswd -m sha-512 password -s $upasswd) 2> /dev/null
  logger -i -p local3.info "USER CREATE"

  echo -e "\e[31mverify the user from /etc/passwd...\e[0m"
  getent passwd $uname
  logger -i -p local3.info "USER VERIFIED"
}

function DeleteUser(){
  local uname=$1
  echo -e "\e[31mdelete a user...\e[0m"
  userdel -r $uname 
  logger -i -p local3.info "USER DELETED"

  echo -e "\e[31mverify the user from /etc/passwd...\e[0m"
  getent passwd $uname
  logger -i -p local3.info "USER VERIFIED"
}
