# day4

## centos 6 for rgmanager test(almost as like rhel 6 version)

centos 6.x doesn't not support the RPM repository anymore.
Have to do run below command for use to RPM repository for CentOS 6

```bash
virt-install --format qcow2 --size 10G --root-password password:centos -o /var/lib/libvirt/images/centos-6-node1.qcow2 centos-6

virt-builder --format qcow2 --size 10G --root-password password:centos -o /var/lib/libvirt/images/centos-6-node2.qcow2 centos-6

virt-builder --format qcow2 --size 10G --root-password password:centos -o /var/lib/libvirt/images/centos-6-gfs.qcow2 centos-6

virt-install --memory 4096 --vcpu 2 -n node1 \ 
--disk /var/lib/libvirtd/images/centos-6-node1.qcow2,cache=none,bus=virtio \
-w network=default,model=virtio -w network=internal,model=virtio \
--graphics none --autostart --noautoconsole --import

virt-install --memory 4096 --vcpu 2 -n node2 \ 
--disk /var/lib/libvirtd/images/centos-6-node2.qcow2,cache=none,bus=virtio \
-w network=default,model=virtio -w network=internal,model=virtio \
--graphics none --autostart --noautoconsole --import

virt-install --memory 4096 --vcpu 2 -n node2 \ 
--disk /var/lib/libvirtd/images/centos-6-node-gfs.qcow2,cache=none,bus=virtio \
-w network=default,model=virtio -w network=internal,model=virtio \
--graphics none --autostart --noautoconsole --import
```


```bash
mkdir /etc/yum.repos.d/backup-repo
mv /etc/yum.repos.d/CentOS-*.repo
wget -P /etc/yum.repos.d https://mapoo.net/downfiles/Linux/repo/centos-vault.repo --no-check-certificate
yum clean all
yum repolist

```

install to rgmanager
```bash
yum install rgmanager -y
service rgmanager status
```


```bash
yum groupinstall "High Availability"

```



## iscsi

before
```bash
iscsiadm -m discoverydb -t sendtargets -p 192.168.90.110 
```

after

```bash
iscsiadm -m discoverydb -t sendtargets -p 192.168.90.110 --discover
```


```bash

node1# parted --script /dev/sda "mklabel msdos"
node1# parted --script /dev/sda "mkpart primary 0% 100%"
node1# parted --script /dev/sda "set 1 lba on"
node1# mkfs.xfs /dev/sda1
node1# mkdir -p /mnt/iscsi
node1# mount /dev/sda1 /mnt/iscsi
node1# echo "This is from node1 shared" > /mnt/iscsi/README.md
node3# partprobe ## kpartx later explain
node3# mkdir -p /mnt/iscsi
node3# mount -oro /dev/sda1 /mnt/iscsi
node3# cat /mnt/iscs/README.md
node2# dd if=/dev/zero of=/mnt/iscsi/data.raw bs=1M count=10
node2# touch helloworld.md
```










