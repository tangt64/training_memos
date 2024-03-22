#!/bin/bash

sleep 1000 &
spid=$(pidof sleep)
spidrc=$?
spid_list=$(ps -ocmd,pid | grep sleep | head -1)

echo 'This World sponsor @Bash.'
echo 'I love to save $$USD$$ in my bank account!!!'
echo "The sleep process ID is $$ and $?"

echo "The sleep process ID is $spid and $spidrc"

echo "Here is the sleep process list"
echo "-----"
echo $spid_list


killall sleep

echo 'done work!! :)'
