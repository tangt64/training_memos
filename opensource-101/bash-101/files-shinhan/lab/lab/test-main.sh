#!/bin/bash
#source include/login.sh
source include/user.sh
source include/firewalld.sh
source include/passwd.sh
source include/systemd.sh
source include/log.sh
source include/container.sh

case $1 in
  set)           ## password
    case $2 in
      password)
         SetUserPasswd $3 $4
      ;;
    esac
  ;;
  start)         ## systemd
    case $2 in
      service)
        StartService $3 
      ;;
    esac
  ;;
  stop)         ## systemd
    case $2 in
      service)
        StopService $3 
      ;;
      container) ## create container service. wildfly middle ware.
    	  StopContainer $3 $4      ## container name
    ;;
    esac
  ;;
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
  remove)        ## firewalld
    case $2 in
      service)
         RemoveFirewall $3
    ;;
    esac
  ;;
  create)        ## adduser
    case $2 in
      user)	
    	  CreateUser $3 $4
    ;;
      log)       ## create log from journald	
    	  CreateLog $3      ## email address 
    ;;
      container) ## create container service. wildfly middle ware.
    	  CreateContainer $3 $4      ## container image, container name
    ;;
    esac
  ;;
  delete)        ## userdel
    case $2 in
      user)
       	DeleteUser $3
     ;;
   esac
  ;;    
esac
