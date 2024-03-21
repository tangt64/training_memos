#!/bin/bash

echo "set up a http, https protocols to Firewalld..."

firewall-cmd --add-service={http,https} || exit
firewall-cmd --runtime-to-permanent

echo "verify to http, https protocol on Firewalld..."
firewall-cmd --list-services | grep -e http -e https 


echo "start to a httpd service from systemd..."
systemctl enable --now httpd.service
