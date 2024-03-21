#!/bin/bash
declare -a devices
read -p "hit of your an array: " -a devices

echo ${devices[@]}
echo devices[@]


for i in ${devices[@]}
do
  echo $i
done