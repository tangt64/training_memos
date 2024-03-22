#!/bin/bash

uname=$1	## mine

function CreateUser() {
  local uname=cuser
  exit
}

function DeleteUser() {
  local uname=duser
  return 1
}

CreateUser
echo $?
DeleteUser
echo $?
