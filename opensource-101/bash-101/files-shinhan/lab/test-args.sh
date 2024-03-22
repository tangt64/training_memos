#!/bin/bash 

useradd $1

getent passwd $1
# echo $0 $1 $2 $3 $4


echo $#

echo $*
