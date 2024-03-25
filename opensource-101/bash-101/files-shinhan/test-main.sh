#!/bin/bash
source include/user.sh

case $1 in
  create)
    case $2 in
      user)
        echo "this is create"
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