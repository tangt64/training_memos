#!/bin/bash
#!/bin/bash
ansible localhost, -m copy -a "content='Hello SKT' dest=/var/www/html/default.html"
ansible localhost, -m package  -a "name=httpd state=latest"
ansible localhost, -m service -a "name=httpd state=started enabled=yes"
ansible localhost, -m package -a "name=python3-firewall state=latest"
ansible localhost, -m firewalld -a "service=http permanent=yes state=enabled"
ansible localhost, -m firewalld -a "service=https permanent=yes state=enabled"
ansible localhost, -m uri -a "url=http://localhost return_content=yes"
