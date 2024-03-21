#!/bin/bash

echo "install to a httpd package..."
dnf install httpd -y

echo "start to the httpd service..."
systemctl start httpd.service || exit

echo "make a template httpd web page..."
echo "it's okay" > /var/www/html/index.html

echo "test to the WWW service..."
curl localhost || exit
