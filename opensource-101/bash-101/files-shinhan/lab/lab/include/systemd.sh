#!/bin/bash
function StartService(){
  local srv_name=$1
  systemctl start $srv_name
  systemctl is-active $srv_name
}

function StopService(){
  local srv_name=$1
  systemctl stop $srv_name
  systemctl is-active $srv_name
}
