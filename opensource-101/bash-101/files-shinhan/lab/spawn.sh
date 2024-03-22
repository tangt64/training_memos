#!/bin/bash
# spawn.sh
PIDS=$(pidof sh $0)
P_array=( $PIDS ) 
echo $PIDS
let "instances = ${#P_array[*]} - 1"
echo "$instances instance(s) of this script running."
echo "[Hit Ctl-C to exit.]"; echo
sleep 1 
sh $0
exit 0

