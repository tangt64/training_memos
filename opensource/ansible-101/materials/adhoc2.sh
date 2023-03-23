#!/bin/bash
ansible webserver, -m yum -a "name=httpd state=latest"
ansible localhost, -m copy -a "src=test_html.html.j2 dest=/var/www/html/index.html"
