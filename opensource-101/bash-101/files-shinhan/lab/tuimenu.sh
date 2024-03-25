#!/bin/bash
items=(1 "Item 1"
       2 "Item 2")
while choice=$(dialog --title "$TITLE" \
                 --menu "Please select" 10 40 3 "${items[@]}" \
                 2>&1 >/dev/tty)
    do
    case $choice in
        1) test1 ;;
        2) test2 ;; 
        *) test3 ;; 
    esac
done
clear 

