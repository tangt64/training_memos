# day 5

## create gfs without Pacemaker

```bash
node1/2/3# dnf install gfs2-utils -y
node1/2/3# umount /mnt/iscsi
nod
node1# wipefs -a /dev/sda
node1# mkfs.gfs2 -j3 -t mycluster:shared  /dev/sda1
node2/3# mount -t xfs 

```


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

```bash
node2# lsblk

node2# mount /dev/sda1 /mnt/iscsi
node2# cd /mnt/iscsi
node2# touch node2.md
node2# sync
node2# ls -l

node3# lsblk
node3# mount /dev/sda1 /mnt/iscsi
node3# cd /mnt/iscsi
node3# touch node3.md
node3# sync
node3# ls -l

```


```bash
node1# systemctl enable --now pcsd
node1# echo centos | passwd --stdout hacluster
node2# cat /etc/corosync/corosync.conf
node2# pcs host auth -u hacluster -p centos node1.example.com
node2# corosync-quorumtool | grep Flags  ## two_node is gone
node2# pcs cluster node add node1.example.com
node2# pcs cluster node remove node1.example.com

```

the option "wait_for_all" the master node, will fence to the second node when the node booting up. Prevent the loop fencing with "wait_for_all".


```bash
node2# man 5 votequorum

node2# pcs cluster stop --all
node2# pcs quorum update auto_tie_breaker=1 auto_tie_breaker=1 last_man_standing=1 last_man_standing_window=10000(10sec) wait_for_all=1
node2# pcs cluster start --all
node2# nano /etc/corosync/corosync.conf
quorum {
    provider: corosync_votequorum
    auto_tie_breaker: 1
    last_man_standing: 1
    last_man_standing_window: 10000
    wait_for_all: 0
    two_node: 1
}
node2# pcs cluster sync
node2# pcs cluster reload corosync

```
