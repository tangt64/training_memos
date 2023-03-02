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
