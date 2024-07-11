#!/bin/bash
ansible all -b -m file -a 'state=directory path=/etc/yum.repos.d'
ansible all -b -m yum_repository -a 'name=internal description=hehe file=internal baseurl=http://repo.example.com gpgcheck=0'
