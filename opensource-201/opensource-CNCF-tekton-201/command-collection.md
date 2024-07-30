# 쿠버네티스 싱글 마스터 + 싱글 노드 클러스터 구성

## 마스터 및 노드 공통 설정

```bash
master/node]# cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/repodata/repomd.xml.key
# exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

master/node]# dnf search --disableexcludes=kubernetes kubectl kubeadm kubelet 
master/node]# dnf install --disableexcludes=kubernetes kubectl kubeadm kubelet 
master/node]# setenforce 0
master/node]# vi /etc/selinux/config
> permissive
```

```bash
master/node]# systemctl stop firewalld && systemctl disable firewalld
master/node]# swapon -s
master/node]# swapoff -a
master/node]# vi /etc/fstab
> #/dev/mapper/rl-swap     none                    swap    defaults        0 0
master/node]# systemctl daemon-reload
master/node]# dnf install tc -y        			 		## optional
master/node]# dnf install iproute-tc -y 				## centos-9-stream, optional
```

### hosts A Recode(instead bind)
1. bind(dns) 구성(primary)
2. /etc/hosts A(ipv4),AAAA(ipv6) recode를 구성(backup)

```bash
#
# 내부 아이피로 구성
#
master/node]# cat <<EOF>> /etc/hosts
192.168.10.10 master.example.com master
192.168.10.20 node1.example.com node1
EOF
```

```bash
master]# systemctl status kubelet
master]# systemctl enable --now kubelet
```

### crio install(o)

```bash
master/node]# cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/rpm/repodata/repomd.xml.key
EOF
master/node]# dnf install -y \
    conntrack \
    container-selinux \
    ebtables \
    ethtool \
    iptables \
    socat
master/node]# dnf install cri-o -y
master/node]# systemctl enable --now crio
master/node]# systemctl is-active crio

```
### modules

```bash
master/node]# modprobe br_netfilter    ## bridge for iptables or nftables, L2/L3
master/node]# modprobe overlay         ## cotainer image for UFS(overlay2), Disk(UFS)
master/node]# cat <<EOF> /etc/modules-load.d/k8s-modules.conf
br_netfilter
overlay
EOF
```

### kenrel parameter
```bash
master/node]# cat <<EOF> /etc/sysctl.d/k8s-mod.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1   
net.ipv4.ip_forward=1
EOF
sysctl --system
dracut -f
```

### kubeadm init as single controller role node

```bash
master]# hostnamectl set-hostname master.example.com
node]# hostnamectl set-hostname node1.example.com
master]# kubeadm init --apiserver-advertise-address=192.168.10.10 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16 --ignore-preflight-errors=Mem
master]# systemctl is-active kubelet
master]# crictl ps 
```
### 초기화 순서 및 방법

노드에서 마스터 순서로 리셋.
```bash
@master]# kubeadm reset --force 
@node]# kubeadm reset --force
```

### kubeadm join(single)

```bash
@master]# KUBECONFIG=/etc/kubernetes/admin.conf kubeadm token create --print-join-command
```

### node join

```bash
kubeadm join 192.168.10.10:6443 --token yspx54.k2076yehis972cng \
        --discovery-token-ca-cert-hash sha256:4743574ead43b14374be00496294bcb5ee85a3967724c0c3464ca9dcb576fb27
```
### 터널링 네트워크 구성

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource-101/kubernetes-101/files/calico-quay-crd.yaml
kubectl get pods -A
```

#### 확인하기
```bash
export KUBECONFIG=/etc/kubernetes/admin.conf 
kubectl get nodes
```

```text
calico-system     calico-kube-controllers-6ddc79c6c6-7vwwp     1/1     Running   0          2m56s
calico-system     calico-node-6j96z                            1/1     Running   0          2m56s
calico-system     calico-node-cz8tn                            1/1     Running   0          2m56s
calico-system     calico-typha-fdd6d7c45-qhdhv                 1/1     Running   0          2m56s
kube-system       coredns-787d4945fb-cz88n                     1/1     Running   0          107m
kube-system       coredns-787d4945fb-ntcj5                     1/1     Running   0          107m
kube-system       etcd-master.example.com                      1/1     Running   0          107m
kube-system       kube-apiserver-master.example.com            1/1     Running   0          107m
kube-system       kube-controller-manager-master.example.com   1/1     Running   0          107m
kube-system       kube-proxy-6vdbv                             1/1     Running   0          107m
kube-system       kube-proxy-pvhns                             1/1     Running   0          107m
kube-system       kube-scheduler-master.example.com            1/1     Running   0          107m
tigera-operator   tigera-operator-7795f5d79b-g6kl6             1/1     Running   0          3m33s
```

## 테크톤 설치

```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.53.7/release.yaml
kubectl get pods -n tekton-pipelines
dnf install wget -y
wget https://github.com/tektoncd/cli/releases/download/v0.32.0/tkn_0.32.0_Linux_x86_64.tar.gz
mkdir ~/bin/
tar xf tkn_0.32.0_Linux_x86_64.tar.gz -C ~/bin/
tkn hub install task buildah
tkn hub install task kubernetes-actions
tkn hub install task git-clone
tkn hub install task maven

tkn task list
```

```text
NAME                 DESCRIPTION              AGE
buildah              Buildah task builds...   7 seconds ago
git-clone            These Tasks are Git...   5 seconds ago
kubernetes-actions   This task is the ge...   6 seconds ago
maven                This Task can be us...   4 seconds ago
```

## 명령어 자동완성

```bash
dnf install bash-completion -y

kubectl completion bash > /etc/profile.d/kubectl.sh
tkn completion  bash > /etc/profile.d/tkn.sh

source /etc/profile
```


```bash

kubectl get nodes
```

## 강제 종료

```bash
$VmGUID = (Get-VM 'cicd-master').id
$VMWMProc = (Get-WMIObject Win32_Process | ? {$_.Name -match 'VMWP' -and $_.CommandLine -match $VmGUID})
Stop-Process ($VMWMProc.ProcessId) –Force
```


## 에디터 환경


```bash
dnf install epel-release -y
dnf search vim yaml
dnf install neovim-ale yamllint -y

nvim test.yaml
alias vi="nvim"

```