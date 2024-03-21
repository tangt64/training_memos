#!/bin/bash

echo "create a user..."
adduser test1

echo "set the user password..."
echo default | passwd --stdin test1

echo "verify the user from /etc/passwd..."
grep ^test1 /etc/passwd || exit

