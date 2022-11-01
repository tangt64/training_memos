#!/bin/bash

ansible localhost, -m lineinfile -a 'line="Hello SKT" path=/var/www/html/default.html state=present'
ansible localhost, -m yum -a 'name=httpd state=latest'
ansible localhost, -m firewalld -a 'service=http permanent=yes state=enabled'
ansible localhost, -m firewalld -a 'service=https permanent=yes state=enabled'
ansible localhost, -m shell -a 'curl http://localhost'
