#!/bin/bash

echo "create the bash user"
adduser bash

echo "switch user to the bash"
su - bash

echo "create a material directories and files"

mkdir -p testdir

cd ~
mkdir -p working/secret
touch working/secret/report.txt


