#!/bin/bash

# nginx
# apache

package_name=$1
systemd_name=$2
welcome_message="Hello World"
html_directory="/var/www/html/"
html_file="index.html"

echo -e "\e[32minstall to a httpd package...\e[0m"
dnf install $package_name -y
logger -i -p local3.info "INSTALLED $package_name"

echo -e "\e[32mstart to the httpd service...\e[0m"
systemctl start $systemd_name
logger -i -p local3.info "$(systemctl is-active $systemd_name) FOR $package_name"

echo -e "\e[32mmake a template httpd web page...\e[0m"
echo "$welcome_message" > $html_directory/$html_file
logger -i -p local3.info "CREATE $html_directory/$html_file"

echo -e "\e[32mtest to the WWW service...\e[0m"
systemctl enable --now $systemd_name.service
logger -i -p local3.info "$(systemctl is-enabled $systemd_name) FOR $package_name"