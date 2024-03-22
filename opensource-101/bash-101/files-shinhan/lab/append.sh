#!/bin/bash
echo 'Starting script' >> log.txt
echo 'Creating test directory' >> log.txt
mkdir test || return 0 || exit
echo $?
echo 'Changing into test directory' >> log.txt
cd test || exit
echo $?
echo 'Writing current date' >> log.txt
date >> log.txt || exit
echo $?

