#!/bin/bash

printf "please input username: "
read uname
printf "please input user password: "
read upasswd

# uname=test1
# upasswd=default

echo "create a user..."
adduser $uname

echo "set the user password..."
echo $upasswd | passwd --stdin $uname

echo "verify the user from /etc/passwd..."
grep ^$uname /etc/passwd || exit
grep ^$uname /etc/shadow