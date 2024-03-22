#!/bin/bash

uname=$1
upasswd=$2

echo -e "\e[31mcreate a user with password...\e[0m"
adduser $uname -p $(mkpasswd -m sha-512 password -s $upasswd) 2> /dev/null
logger -i -p local3.info "USER CREATE"

echo -e "\e[31mverify the user from /etc/passwd...\e[0m"
getent passwd $uname
logger -i -p local3.info "USER VERIFIED"
