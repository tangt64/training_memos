#!/bin/bash

if [[ -b $1 ]] ; then
  echo "this disk is $1"
  mkfs.xfs $1
  blkid $1
else
  echo "no disk here"
fi
