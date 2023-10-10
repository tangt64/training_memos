```bash
sudo dnf install guestfs-tools
virt-builder --list

sudo virt-builder --size=20G --root-password password:cka --format qcow2 ubuntu-20.04 -o /var/lib/libvirt/images/cka-ubuntu-master.qcow2
sudo virt-builder --size=20G --root-password password:cka --format qcow2 ubuntu-20.04 -o /var/lib/libvirt/images/cka-ubuntu-node1.qcow2

sudo virt-install -n ubuntu-master-k8s -r 2048 --cpu host-passthrough --vcpus 2  --network network=default --network network=internal --graphics vnc -v --disk=path=/var/lib/libvirt/images/cka-ubuntu-master.qcow2,format=qcow2 --noautoconsole --osinfo ubuntufocal --import

sudo virt-install -n ubuntu-node1-k8s -r 2048 --cpu host-passthrough --vcpus 2  --network network=default --network network=internal --graphics vnc -v --disk=path=/var/lib/libvirt/images/cka-ubuntu-node1.qcow2,format=qcow2 --noautoconsole --osinfo ubuntufocal --import
```

```bash
sudo hostnamectl set-hostname master.example.com
sudo hostnamectl set-hostname node1.example.com

sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

```


```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir -m 755 /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb  [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list
sudo apt update

export OS=xUbuntu_20.04
export VERSION=1.27.0

#
## root 
#


curl -fsSL  https://mirrorcache-jp.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.27:/1.27.0/xUbuntu_20.04/Release.key | apt-key add -

curl -fsSL  https://mirrorcache-jp.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/Release.key | apt-key add -

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.27:/1.27.0/xUbuntu_20.04/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
sudo apt update
sudo apt-get install cri-o cri-o-runc -f

sudo systemctl enable --now crio
sudo systemctl enable --now kubelet

cat <<EOF> /etc/netplan/01-enp2s0.yaml 
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0:
      dhcp4: no
      addresses:
        - 192.168.90.110/24
EOF
sudo netplan apply

cat <<EOF>> /etc/hosts
192.168.90.100 master.example.com master
192.168.90.110 node1.example.com node2
EOF

systemctl stop firewalld
systemctl disable firewalld
systemctl is-active firewalld

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

sudo swapoff -a 


sudo kubeadm init --apiserver-advertise-address=192.168.90.100 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16 

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/tangt64/training_memos/main/opensource-101/kubernetes-101/calico-quay-crd.yaml -o calico-quay-crd.yaml 
kubectl applyf -f calico-quay-crd.yaml 


```