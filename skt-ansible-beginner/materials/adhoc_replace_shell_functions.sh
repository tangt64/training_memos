#!/bin/bash

if $(ansible localhost, -m ping) then;
  ansible all, -m lineinfile -a "path=/var/www/html/index.html state=present line=Hello World"
else
  ansible all, -m lineinfile -a "path=/root/README.md state=present line=This module is not working
fi
