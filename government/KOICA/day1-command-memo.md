

Preapre virtualization


```bash  
dnf groupinstall "virtualization Host" -y ## install virtualization packages as enviorments

## check the libvirtd service for virsh command
systemctl status libvirtd         
systemctl is-active libvirtd
systemctl enable --now libvirtd ## start and enable for boot up        
systemctl is-active libvirtd  ## the result should shows "active"
active    

## for GUI virtual machine manager
dnf install virt-manager -y   

## install virt-builder command for downloading image
dnf install libguestfs-tools-c -y   
virt-builder --list


## build node1,2,3 images for lab
virt-builder --format qcow2 --size 10G --root-password password:centos -o /var/lib/libvirt/images/node1.qcow2 centosstream-8

virt-builder --format qcow2 --size 10G --root-password password:centos -o /var/lib/libvirt/images/node2.qcow2 centosstream-8
virt-builder --format qcow2 --size 10G --root-password password:centos -o /var/lib/libvirt/images/node3.qcow2 centosstream-8
ls -al /var/lib/libvirt/images/



```bash
virsh list   ## listing of virtual machines
## access to virtual machine console via virtual serial line
virsh console <ID or NAME> 
## get to a node ip address(external, internal)
virsh domifaddr <ID or NAME> 
```

## node 1/2/3

```bash
## recommend to access via external network. because, internal network will up and down 
ssh root@192.168.100.XX  

## Node1 network and hostname configure
node1# hostnamectl set-hostname node1.example.com

## create a network profile for eth1
node1# nmcli con add con-name eth1 ipv4.addresses 192.168.90.110/24 ipv4.never-default yes method manual autoconnect yes type ethernet ifname eth1 
## the eth1 profile link up
node1# nmcli con up eth1

## Node2 network and hostname configure
node2# hostnamectl set-hostname node2.example.com

## create a network profile for eth1
node2# nmcli con add con-name eth1 ipv4.addresses 192.168.90.120/24 ipv4.never-default yes method manual autoconnect yes type ethernet ifname eth1 

## the eth1 profile link up
node2# nmcli con up eth1

## Node3 network and hostname configure
node3# hostnamectl set-hostname node3.example.com

## create a network profile for eth1
node3# nmcli con add con-name eth1 ipv4.addresses 192.168.90.130/24 ipv4.never-default yes method manual autoconnect yes type ethernet ifname eth1 

## the eth1 profile link up
node3# nmcli con up eth1
```