#!/bin/bash

if $(ansible local, -m ping) 
then
  ansible localhost, -m copy -a "dest=/var/www/html/index.html content='Hello World'"
else
  ansible localhost, -m copy -a "dest=/root/README.md content='This module is not working'"
fi
