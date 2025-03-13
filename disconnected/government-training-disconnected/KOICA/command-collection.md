
![LAB DESIGN](images/LAB-DESIGN.png "lab design image")

# virtualmbc installation

```bash
node1# dnf install libvirt libvirt-devel python3-devel gcc -y
node1# pip3 install virtualbmc
node1# vbmcd
node1# vbmc add --username centos --password centos --port 7755 --libvirt-uri qemu+ssh://root@bare/system node2
node1# vbmc list
```

# create virtual network and machine


vmem: 8GiB      vmem: 16GiB
vcpu: 2         vcpu: 8
               +--------+
               | ORACLE |
+-------+      +--------+      +-------+
| NODE1 |      | NODE2  |      | NODE3 |
+-------+      +--------+      +-------+
    \           /                 /
     \         /                 /
      .       .                 /
      |       |                /
   +-----------+              /
   | LIBVIRTD  | ------------'
+--------------+
| LINUX        |
+--------------+
| HP DL380/360 | CPU: over 4 cores, MEM: over 16 GIB
+--------------+           8 cores            32 GIB
   BAREMETAL              (Intel Xeon Silver)

![LAB NETWORK](images/lab-network.png)
```bash
bare# dnf groupinstall "Virtualization Host" -y
bare# dnf install libguestfs-tools-c -y
bare# dnf install nano -y
bare# virt-builder --list

bare# virsh net-list
bare# nano internal-network.xml
<network>
  <name>internal</name>
  <bridge name='virbr10' stp='on' delay='0'/>
  <domain name='internal'/>
  <ip address="192.168.90.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.90.2" end="192.168.90.254"/>
    </dhcp>
  </ip>
</network>
bare# nano external-network.xml
<network>
  <name>internal</name>
  <bridge name='virbr11' stp='on' delay='0'/>
  <domain name='external'/>
  <ip address="192.168.100.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.100.2" end="192.168.100.254"/>
    </dhcp>
  </ip>
</network>
bare# virsh define --file internal-network.xml
bare# virsh define --file external-network.xml
bare# virsh net-list
bare# virt-builder --size 10G --format qcow2 -o --root-password password:centos /var/lib/libvirtd/images/node1.qcow2 centosstream-8

bare# virt-builder --size 10G --format qcow2 -o --root-password password:centos /var/lib/libvirtd/images/node2.qcow2 centosstream-8

bare# virt-builder --size 30G --format qcow2 -o --root-password password:centos /var/lib/libvirtd/images/node3.qcow2 centosstream-8
bare# dnf install virt-install -y

bare# virt-install --memory 4096 --cpu host-passthrough --vcpu 2 -n node1 \ 
--disk /var/lib/libvirtd/images/node1.qcow2,cache=none,bus=virtio \
-w network=default,model=virtio -w network=internal,model=virtio \
--graphics none --autostart --noautoconsole --import

bare# virt-install --memory 4096 --cpu host-passthrough --vcpu 2 -n node2 \
--disk /var/lib/libvirtd/images/node2.qcow2,cache=none,bus=virtio \
-w network=default,model=virtio -w network=internal,model=virtio \
--graphics none --autostart --noautoconsole --import


bare# virt-install --memory 4096 --cpu host-passthrough --vcpu 2 -n node3 \
--disk /var/lib/libvirtd/images/node3.qcow2,cache=none,bus=virtio \ 
-w network=default,model=virtio -w network=internal,model=virtio \ 
--graphics none --autostart --noautoconsole --import

bare# virsh console node1
bare# virsh console node2
bare# virsh console node3

bare# virsh domifaddr node1

bare# ssh root@<IP>
```
# virtual machine snapshot

```bash
bare# virsh snapshot-create as --domain node1 --name node1-pcs-setup
bare# virsh snapshot-create-as --domain node2 --name node2-pcs-setup
bare# virsh snapshot-create-as --domain node3 --name node3-pcs-setup

bare# virsh snapshot-list node1

bare# virsh snapshot-revert --domain node1 --snapshotname node1-pcs-setup --running
```

# network configuration

```bash
node1# nmcli con add con-name eth1 ipv4.addresses 192.168.90.110/24 ipv4.never-default yes method manual autoconnect yes type ethernet ifname eth1 
node1# nmcli con up eth1

node2# nmcli con add con-name eth1 ipv4.addresses 192.168.90.120/24 ipv4.never-default yes method manual autoconnect yes type ethernet ifname eth1 
node2# nmcli con up eth1

node3# nmcli con add con-name eth1 ipv4.addresses 192.168.90.130/24 ipv4.never-default yes method manual autoconnect yes type ethernet ifname eth1 
node3# nmcli con up eth1
```

# set hostname by cli
```bash
node1# hostnamectl set-hostname node1.example.com
node2# hostnamectl set-hostname node2.example.com
node3# hostnamectl set-hostname node3.example.com

node1# cat /etc/hosts && hostnamectl
node2# cat /etc/hosts && hostnamectl
node3# cat /etc/hosts && hostnamectl 
```



# Set A recode in /etc/hosts

pacemaker resovle to hosts via DNS(hostname) or IP ADDRESS
- DNS with hostname + domain name
  * node1.example.com
  * install "bind" and configure
- /etc/hosts for instead BIND "A recode"

```bash
node1# cat <<EOF>> /etc/hosts
192.168.90.110 node1.example.com node1 storage
192.168.90.120 node2.example.com node2
192.168.90.130 node3.example.com node3 
EOF
```

# make a ssh private and public key

This session is not mandatory. 

```bash
node1# ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
node1# dnf install sshpass -y
```

# verify to the public ssh key

The node1 public key will in the authorized_keys file

```bash
node2# cat /root/.ssh/authorized_keys  ## NOT HAVE
node3# cat /root/.ssh/authorized_keys  ## NOT HAVE 
```

Install the nano editor for skip to fingerprint checking.

```bash
node1# dnf install nano -y
node1# cat <<EOF> ~/.ssh/config
StrictHostKeyChecking=no
EOF
```



```bash
node1# sshpass -pcentos ssh-copy-id root@node2.example.com
node1# sshpass -pcentos ssh-copy-id root@node3.example.com

```

updated whole of node packages

```bash
node1# for i in node{1..3} ; do sshpass -pcentos ssh root@$i 'dnf update -y' ; done
node1# for i in node{2..3} ; do sshpass -pcentos scp /etc/hosts root@$i.example.com:/etc/hosts ; done
```

## install pacemaker package

if you don't want to do install firewalld package, Do not run it. 
```bash
node1# for i in node{1..3} ; do sshpass -p centos ssh root@$i 'dnf --enablerepo=ha -y install pacemaker pcs' ; done
node1# for i in node{1..3} ; do sshpass -p centos ssh root@$i 'dnf install firewalld && systemctl enable --now firewalld' ; done
```

open the pacemaker port in the Firewalld service

```bash
node1# for i in node{1..3} ; do sshpass -p centos ssh root@${i} 'firewall-cmd --add-service=high-availability && firewall-cmd --runtime-to-permanent' ; done
```

Chanage hacluster user password and enable/start pcsd.service

```bash
node1# for i in node{1..3} ; do sshpass -p centos ssh root@$i 'echo centos | passwd --stdin hacluster && systemctl enable --now pcsd.service' ; done
```
the eth1 check to each node

```bash
node1# ping node1 -c3
node1# ping node2 -c3
node1# ping node3 -c3
```
access to the nodes without password

```bash
node1# ssh node1 hostname
node2# ssh node2 hostname
node3# ssh node3 hostname
```

## makes useful for bash

```bash
node1# dnf install bash-completion -y
node1# complete -r -p
node1# pcs <TAB><TAB>
```
## make the Pacemaker Cluster

Authenticate to each cluster node with hacluster user.

```bash
node1# pcs host auth -u hacluster -p centos node1.example.com node2.example.com node3.example.com
node1# pcs cluster setup cluster_lab node1.example.com node2.example.com node3.example.com
```

Start and Enabled to pcsd and pacemaker service. 

```bash
node1# pcs cluster start --all
node1# pcs cluster enable --all 
node1# pcs cluster status
```

Checking and Verifying the corosync status in the cluster.

```bash
node1# pcs status corosync
node1# pcs cluster stop --all
node1# pcs cluster destroy --all 

node1# ss -npltu | grep -i corosync
```

# target server config

```bash
node1# firewall-cmd --add-service=iscsi-target
node1# firewall-cmd --runtime-to-permanent
node1# dnf install epel-release -y
node1# dnf install targetd targetcli -y
node1# systemctl enable --now target

node1# dnf install iscsi-initiator-utils -y

node1# mkdir -p /var/lib/iscsi_disks

node1# targetcli backstores/fileio create iscsi /var/lib/iscsi_disks/iscsi_disk.img 2G
node1# targetcli backstores/fileio create nfs /var/lib/iscsi_disks/nfs_disk.img 2G
node1# targetcli backstores/fileio create gfs2 /var/lib/iscsi_disks/gfs2_disk.img 2G

node1# targetcli iscsi/ create iqn.2023-02.com.example:blocks

node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/luns/ create /backstores/fileio/iscsi/
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/luns/ create /backstores/fileio/nfs/
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/luns/ create /backstores/fileio/gfs2/

node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/ create iqn.2023-02.com.example:node1.init
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/ create iqn.2023-02.com.example:node2.init
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/ create iqn.2023-02.com.example:node3.init

node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example:node1.init set auth userid=username
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example:node1.init set auth password=password

node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example:node2.init set auth userid=username
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example:node2.init set auth password=password

node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example:node3.init set auth userid=username
node1# targetcli iscsi/iqn.2023-02.com.example:blocks/tpg1/acls/iqn.2023-02.com.example:node3.init set auth password=password
```


# scanning and login into targetd service

```bash
node1# dnf install nano -y
node1# cat<<EOF> /etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2023-02.com.example:node1.init
node1# nano /etc/iscs/iscsid.conf
node.session.auth.authmethod = CHAP
node.session.auth.username = username
node.session.auth.password = password
EOF
node1# systemctl restart iscsi iscsid

node1# ssh root@node2 "dnf install iscsi-initiator-utils -y"
node1# ssh root@node2 cat /etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2023-02.com.example:node2.init
node2# nano /etc/iscsi/iscsid.conf
node.session.auth.authmethod = CHAP
node.session.auth.username = username
node.session.auth.password = password
node2# systemctl restart iscsi iscsid


node3# dnf install nano -y
node3# dnf install iscsi-initiator-utils -y
node3# nano /etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2023-02.com.example:node3.init
node3# nano /etc/iscsi/iscsid.conf
node.session.auth.authmethod = CHAP
node.session.auth.username = username
node.session.auth.password = password
node3# systemctl restart iscsi iscsid
```

Check to a block devices list from each node by lsblk command

```bash
node1/2/3# lsblk
```


First only run the command on the node1

```bash
node1/2/3# dnf install iscsi-initiator-utils -y
node1/2/3# iscsiadm -m discoverydb -t sendtargets -p 192.168.90.110
node1/2/3# iscsiadm -m discovery -t sendtargets -p 192.168.90.110
```

save the target server config in /etc/target/saveconfig.json

```bash
node1# targetcli saveconfg
```

Do not run this command today!! And, First time only run the command on the node1.

```bash
node1/2/3# iscsiadm -m node --login       ## loging commnad
node1/2/3# iscsiadm -m session --debug 3  ## debug command
node1/2/3# iscsiadm -m session --rescan   ## rescanning of disks from target luns
```


# install pacemaker and create a cluster

```bash
node2/3# dnf --enablerepo=ha -y install pacemaker pcs
node2/3# systemctl enable --now pcsd
node2/3# echo centos | passwd --stdin hacluster

node2/3# firewall-cmd --add-service=high-availability --permanent
node2/3# firewall-cmd --reload

node2# pcs host auth -u hacluster -p centos node2.example.com node3.example.com
node2# pcs cluster setup ha_cluster_lab node2.example.com node3.example.com
node2# pcs cluster start --all
node2# pcs cluster enable --all
node2# pcs cluster status
node2# pcs status corosync
```

# xfs to gfs2

```bash
node1# parted --script /dev/sda "mklabel msdos"
node1# parted --script /dev/sda "mkpart primary 0% 100%"
node1# parted --script /dev/sda "set 1 lba on"
node1# mkfs.xfs /dev/sda1
node1# mkdir -p /mnt/iscsi
node1/2/3# kpartx -a /dev/sda
node1# mount /dev/sda1 /mnt/iscsi
node1# echo "This is from node1 shared" > /mnt/iscsi/README.md
node3# partprobe ## kpartx later explain
node3# mkdir -p /mnt/iscsi
node3# mount -oro /dev/sda1 /mnt/iscsi
node3# cat /mnt/iscs/README.md
node2# dd if=/dev/zero of=/mnt/iscsi/data.raw bs=1M count=10
node2# touch helloworld.md
```

```bash
node1# umount /mnt/iscsi
node2# umount /mnt/iscsi
node3# umount /mnt/iscsi
```




# lvm

```bash
node2/3# vi /etc/lvm/lvm.conf
system_id_source = "uname"

node2# parted --script /dev/sdb "mklabel msdos"
node2# parted --script /dev/sdb "mkpart primary 0% 100%"
node2# parted --script /dev/sdb "set 1 lvm on"

node2/3# dnf install --enablerepo=ha,resilientstorage dlm lvm2-lockd -y

node2# systemctl enable --now lvmlockd lvmlocks dlm

node2# pvcreate /dev/sdb1
node2# vgcreate vg_ha_iscsi /dev/sdb1
node2# vgs -o+systemid
node2# lvcreate -l 100%FREE -n lv_ha_iscsi vg_ha_iscsi

node2# mkfs.xfs /dev/vg_ha_iscsi/lv_ha_iscsi
node2# vgchange vg_ha_iscsi -an

node2# lvm pvscan --cache --activate ay
node2# pcs resource create lvm_ha_iscsi ocf:heartbeat:LVM-activate vgname=vg_ha_iscsi vg_access_mode=uname --group ha_iscsi_group

node2# pcs status
```

# nfs server

```bash
node2/3# firewall-cmd --add-service=nfs --permanent
node2/3# firewall-cmd --add-service={nfs3,mountd,rpc-bind} --permanent
node2/3# firewall-cmd --reload

node2/3# mkdir -p /home/nfs-share
node2# pcs resource create nfs_share_iscsi ocf:heartbeat:Filesystem device=/dev/vg_ha_iscsi/lv_ha_iscsi directory=/home/nfs-share fstype=xfs --group ha_iscsi_group

node2# pcs status
node2# mount | grep /home/nfs-share

node2# pcs resource create nfs_daemon ocf:heartbeat:nfsserver nfs_shared_infodir=/home/nfs-share/nfsinfo nfs_no_notify=true --group ha_iscsi_group 

node2# pcs resource create nfs_vip ocf:heartbeat:IPaddr2 ip=192.168.100.250 nic=eth1 cidr_netmask=24 --group ha_iscsi_group

node2# pcs resource create nfs_notify ocf:heartbeat:nfsnotify source_host=192.168.100.250 --group ha_iscsi_group 

node2# mkdir -p /home/nfs-share/nfs-root/share01
node2# pcs resource create nfs_root ocf:heartbeat:exportfs clientspec=192.168.100.0/255.255.255.0 options=rw,sync,no_root_squash directory=/home/nfs-share/nfs-root fsid=0 --group ha_iscsi_group 
node1 # pcs resource create nfs_share01 ocf:heartbeat:exportfs clientspec=192.168.100.0/255.255.255.0 options=rw,sync,no_root_squash directory=/home/nfs-share/nfs-root/share01 fsid=1 --group ha_iscsi_group 

node2 # pcs status
node2 # showmount -e

node2/3 # mkdir -p /mnt/test_nfs
node2/3 # mount 192.168.100.250:/home/nfs-share/nfs-root/share01 /mnt
```

# www(apache server)

```bash
node2/3 # dnf install httpd -y
node2/3 # vi /etc/httpd/conf.d/server-status.conf
<Location /server-status>
    SetHandler server-status
    Require local
</Location>


node2/3 # firewall-cmd --add-service={http,https} --permanent && firewall-cmd --runtime-to-permanent
node2/3 # mkdir -p /mnt/html
node2/3 # mount /dev/vg_ha_iscsi/lv_ha_iscsi /mnt/html
node2/3 # echo "Hello World" > /mnt/html/index.html && umount /mnt/html/

node2 # pcs resource create httpd_fs ocf:heartbeat:Filesystem device=/dev/vg_ha_iscsi/lv_ha_iscsi directory=/var/www fstype=xfs --group ha_group_iscsi

node2 # pcs resource create httpd_vip ocf:heartbeat:IPaddr2 ip=192.168.100.240 cidr_netmask=24 --group ha_group_iscsi

node2 # pcs resource create website ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl=http://127.0.0.1/server-status --group ha_group 

node2 # pcs status

node2 # restorecon -RFvvv /var/www/
node2 # curl http://192.168.100.240/index.html
```
