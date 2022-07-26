#!/bin/bash

TEST_TMPFILE=`mktemp test.XXXXXXXXX`
FISH_TMPFILE=`mktemp fish.XXXXXXXXX`
BEEF_TMPFILE=`mktemp beef.XXXXXXXXX`
GIT_TMPFILE=`mktemp git.XXXXXXXXX`
VIM_TMPFILE=`mktemp vim.XXXXXXXXX`

mkdir docs
pushd docs

for n in {1..1000}; do	
  touch $(hexdump -n 16 -v -e '/1 "%02X"' /dev/urandom).$TEST_TMPFILE
  touch $(hexdump -n 16 -v -e '/1 "%02X"' /dev/urandom).$FISH_TMPFILE
  touch $(hexdump -n 16 -v -e '/1 "%02X"' /dev/urandom).$BEEF_TMPFILE
  touch .$GIT_TMPFILE
  touch .$VIM_TMPFILE
done

