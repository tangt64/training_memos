# 쿠버네티스 싱글 마스터 + 2노드 클러스터 구성(kubeadm)

## 마스터 및 노드 공통 설정

```bash
cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
dnf search --disableexcludes=kubernetes kube
dnf list --disableexcludes=kubernetes kubeadm
dnf install --disableexcludes=kubernetes kubeadm -y
setenforce 0
systemctl stop firewalld
systemctl disable firewalld

```

```bash
systemctl stop firewalld && systemctl disable firewalld
swapon -s
swapoff -a
dnf install tc -y
dnf install iproute-tc -y ## centos-9-stream
```

### hosts A Recode(insted bind)
1. bind(dns) 구성(primary)
2. /etc/hosts A(ipv4),AAAA(ipv6) recode를 구성(backup)

```bash
cat <<EOF>> /etc/hosts
192.168.90.110 master.example.com master
192.168.90.240 master2.example.com master2
192.168.90.250 master3.example.com master3
192.168.90.120 node1.example.com node1
192.168.90.130 node2.example.com node2
EOF
```
### kubelet service

```bash
systemctl status kubelet
systemctl enable --now kubelet
```

### containerd(선택사항)

```bash
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf search containerd
dnf remove podman -y
dnf install containerd -y   ## docker repository (subsystem for dockerd)
containerd config default > /etc/containerd/config.toml
systemctl enable --now containerd
```

### crio install(o)

```bash
dnf install wget -y
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/libcontainers.repo -O /etc/yum.repos.d/libcontainers.repo
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/stable_crio.repo -O /etc/yum.repos.d/stable_crio.repo
dnf install cri-o -y
systemctl enable --now crio
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/policy.json -O /etc/containers/policy.json
```
### modules

```bash
modprobe br_netfilter    ## bridge for iptables or nftables, L2/L3
modprobe overlay         ## cotainer image for UFS(overlay2), Disk(UFS)
cat <<EOF> /etc/modules-load.d/k8s-modules.conf
br_netfilter
overlay
EOF
```

### kenrel parameter
```bash
cat <<EOF> /etc/sysctl.d/k8s-mod.conf
net.bridge.bridge-nf-call-iptables=1    ## container ---> link ---> tap ---> bridge
net.ipv4.ip_forward=1                   ## pod <---> svc
net.bridge.bridge-nf-call-ip6tables=1   ## ipv6
EOF
sysctl --system                           ## 재부팅 없이 커널 파라메타 수정하기
```

### firewalld stop and disabled
```bash
systemctl stop firewalld && systemctl disable firewalld
```

### 초기화 순서 및 방법

노드에서 마스터 순서로 리셋.
```bash
@node]# kubeadm reset --force
@master]# kubeadm reset --force 
```

### kubeadm join(single)

```bash
@master]# KUBECONFIG=/etc/kubernetes/admin.conf kubeadm token create --print-join-command
```

### kubeadm init/join(multi)

```bash
kubeadm init --apiserver-advertise-address=192.168.90.110 \
 --control-plane-endpoint 192.168.90.110 \
 --cri-socket=/var/run/crio/crio.sock \
 --upload-certs \
 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16 \
 --service-dns-domain=devops.project
```

#### master join
```bash
kubeadm join 192.168.90.110:6443 --token yspx54.k2076yehis972cng \
        --discovery-token-ca-cert-hash sha256:4743574ead43b14374be00496294bcb5ee85a3967724c0c3464ca9dcb576fb27 \
        --control-plane --certificate-key f45f54f44bb08318926005b5619a6af5523acb30f132da31f2172555efbfb2b8
```

#### node join
```bash

kubeadm join 192.168.90.110:6443 --token yspx54.k2076yehis972cng \
        --discovery-token-ca-cert-hash sha256:4743574ead43b14374be00496294bcb5ee85a3967724c0c3464ca9dcb576fb27
```
#### 터널링 네트워크 구성

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/calico-quay-crd.yaml
kubectl get pods -wA   ## -w: wait, 갱신되면 화면에 출력, -A: 모든 네임스페이스 Pod출력
```

#### 메트릭/역할(임시)
```bash
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/metrics.yaml
kubectl label node node1.example.com node-role.kubernetes.io/worker=worker
kubectl label node node2.example.com node-role.kubernetes.io/worker=worker
kubectl top nodes
kubectl get nodes
```

- 노드 1번에 쿠버네티스/CRIO/모듈/커널 파라메타/방화벽/kubelet 등 서비스 설정
- 마스터에서 token create로 조인 명령어 생성 후, 노드1에서 실행

#### 확인하기(마스터)
```bash
export KUBECONFIG=/etc/kubernetes/admin.conf 
kubectl get nodes
```

## 터널링 네트워크 구성

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/calico-quay-crd.yaml
kubectl get pods -wA   ## -w: wait, 갱신되면 화면에 출력, -A: 모든 네임스페이스 Pod출력
```
