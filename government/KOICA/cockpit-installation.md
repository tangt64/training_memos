# cockpit

Must be installed the cockpit package each node if you want to do manage all nodes within cockpit management system.


## in script install and start/enable of service all nodes
```bash
# for i in node{1..3} ; do ssh root@$i "dnf install cockpit-* -y && systemctl enable --now cockpit.service && systemctl enable --now cockpit.socket" ; done 
```

## single commnand

for install cockpit packages-
```
# dnf install cockpit-*
```

start and enabled the cockpit service
```bash
systemctl enable --now cockpit.service 
systemctl enable --now cockpit.socket
```

copy the ssh public key to each node

```bash
# ssh-copy-id root@node2.example.com
# ssh-copy-id root@node3.example.com
```

check to the service port and access to the cockpit dashboard

```bash
# ss -atnp | grep 9090

# firefox https://<HOST>:9090/
```