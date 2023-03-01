# cockpit

Must be installed the cockpit package each node if you want to do manage all nodes within cockpit management system.


```bash
# for i in node{1..3} ; do ssh root@$i "dnf install cockpit-* -y && systemctl enable --now cockpit.service && systemctl enable --now cockpit.socket" ; done 

# ssh-copy-id root@node2.example.com
# ssh-copy-id root@node3.example.com

# ss -atnp | grep 9090

# firefox https://<HOST>:9090/

```