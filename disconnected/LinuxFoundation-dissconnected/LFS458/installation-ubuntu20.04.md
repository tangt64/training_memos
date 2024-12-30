# 설치 명령어 정리

## 호스트 공통사항

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

swapon -s
swapoff -a

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
```

## root 권한에서 실행

```bash
export OS=xUbuntu_20.04
export VERSION=1.27.0

curl -fsSL  https://mirrorcache-jp.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.27:/1.27.0/xUbuntu_20.04/Release.key | apt-key add -

curl -fsSL  https://mirrorcache-jp.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/Release.key | apt-key add -

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.27:/1.27.0/xUbuntu_20.04/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
sudo apt update
sudo apt-get install cri-o cri-o-runc -y

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
```

## 쿠버네티스 설치

```bash
sudo kubectl completion bash > /etd/bash_completion.d/kubectl
sudo kubeadm completion bash > /etd/bash_completion.d/kubeadm
sudo vi ~/.bashrc
>if ! shopt -oq posix; then
>  if [ -f /usr/share/bash-completion/bash_completion ]; then
>    . /usr/share/bash-completion/bash_completion
>  elif [ -f /etc/bash_completion ]; then
>    . /etc/bash_completion
>  fi
>fi
complet -r -p
source /etc/bash_completion


sudo kubeadm init --apiserver-advertise-address=192.168.90.100 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16 

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/tangt64/training_memos/main/opensource-101/kubernetes-101/calico-quay-crd.yaml -o calico-quay-crd.yaml 
kubectl apply -f calico-quay-crd.yaml 
```

#### 메트릭/역할
```bash
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/metrics.yaml
kubectl label node node1.example.com node-role.kubernetes.io/worker=worker
kubectl label node node2.example.com node-role.kubernetes.io/worker=worker
kubectl top nodes
kubectl get nodes
```

#### 확인하기(마스터)
```bash
export KUBECONFIG=/etc/kubernetes/admin.conf 
kubectl get nodes
```
