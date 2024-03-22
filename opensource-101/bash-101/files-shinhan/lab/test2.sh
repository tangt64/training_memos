#!/bin/bash

sleep 1000 &
spid=$(pidof sleep)
spidrc=$($?)

echo This World sponsor @Bash.
echo I love to save $$USD$$ in my bank account!!!
echo The sleep process ID is $$ and $?

echo The sleep process ID is $spid and $spidrc

