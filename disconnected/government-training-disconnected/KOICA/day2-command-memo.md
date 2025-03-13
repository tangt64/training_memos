# day2

```bash
node1# dnf install nano -y
node1# nano /etc/hosts
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.90.110 node1.example.com node1 storage
192.168.90.120 node2.example.com node2
192.168.90.130 node3.example.com node3

node1# ping -c1 {node1 node2 node3}
```
