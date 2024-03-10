ansible all --inventory-file inventory -m shell -a hostname
ansible all --inventory-file inventory -m dnf -a name=httpd -a state=present
