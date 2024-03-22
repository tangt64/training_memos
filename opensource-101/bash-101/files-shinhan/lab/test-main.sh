#!/bin/bash
#source include/login.sh
source include/user.sh
source include/firewalld.sh

case $1 in
  add)           ## firewalld
    case $2 in
      service)
         SetFirewall $3
      ;;
    esac
  ;;
  list)          ## firewalld
    case $2 in
      service)
         ListFirewall $3
      ;;
    esac
  ;;
  create)
    case $2 in
      user)	
    	  CreateUser $3 $4
      ;;
    esac
  ;;
  delete)
    case $2 in
      user)
        echo "this is delete"
	DeleteUser $3
    ;;
   esac
  ;;    
esac
