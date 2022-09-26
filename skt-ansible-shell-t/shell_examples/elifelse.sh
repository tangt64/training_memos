#!/bin/bash
second=$2
if [ "$seconds" -eq 0 ]; then
   timezone_string="Z"
elif [ "$seconds" -gt 0 ]; then
   timezone_string=$(printf "%02d:%02d" $((seconds/3600)) $(((seconds / 60) % 60)))
else
   echo "Unknown parameter"
fi
