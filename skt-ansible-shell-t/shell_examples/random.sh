#! /bin/bash

TMPFILE=`mktemp tmp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

for n in {1..1000}; do
    dd if=/dev/urandom of=file$( printf %03d "$n" ).bin bs=1 count=$(( RANDOM + 1024 ))
    touch $(hexdump -n 16 -v -e '/1 "%02X"' /dev/urandom)
    touch $TMPFILE
done
