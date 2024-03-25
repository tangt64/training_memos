#!/bin/bash

for i in include/*;
  do source $i
done


case $1 in
  create)
    case $2 in
      user)
      echo "create user"
      ;;
      *)
      echo "command help"
      echo "------------"
      echo "create user: make a user"
      echo "create webfile: make a index.html file"
      ;;
    esac
    ;;
  delete)
    case $2 in
      user)
      echo "delete user"
      ;;
    esac
    ;;
  set)
    case $2 in
      firewalld)
      echo "set firewall"
      ;;
    esac
    ;;
esac
#CreateUser "user1" "testtest"
#SetupHttpd "httpd" "httpd"
#SetFirewall "http" "http"
#ListFirewall "http"
