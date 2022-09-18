#!/bin/bash
var = 5
while [ $var -gt 0 ] ; do
  var=$[ $var-1 ]
  echo $var
  sleep 2
done

