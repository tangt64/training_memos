#!/bin/bash
printf "Enter your name:\n"
read name
printf "Enter your surname:\n"
read surname

printf 'welcome: %s\n' "$name $surname"
