## 마스터 및 노드 공통 설정

```bash
master/node]# cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
master/node]# dnf search --disableexcludes=kubernetes kubectl kubeadm kubelet  
master/node]# dnf install --disableexcludes=kubernetes kubectl kubeadm kubelet -y
master/node]# setenforce 0
master/node]# vi /etc/selinux/config
> permissive
```

```bash
master/node]# systemctl stop firewalld && systemctl disable firewalld
master/node]# swapon -s
master/node]# swapoff -a
master/node]# dnf install tc -y        			 		## optional
master/node]# dnf install iproute-tc -y 				        ## centos-9-stream, optional
```

### hosts A Recode(instead bind)
1. bind(dns) 구성(primary)
2. /etc/hosts A(ipv4),AAAA(ipv6) recode를 구성(backup)

```bash
#
# 내부 아이피로 구성
#
master/node]# cat <<EOF>> /etc/hosts
192.168.90.100 master.example.com master
192.168.90.110 node1.example.com node1
EOF
```
### kubelet service
#
# 처음에 동작 시 "activing..."라고 표시가 되는것은 지극히 정상
# 

```bash
master]# systemctl status kubelet
master]# systemctl enable --now kubelet
```

### crio install(o) 레드햇 계열

```bash
curl https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_9_Stream/devel:kubic:libcontainers:stable.repo -o /etc/yum.repos.d/libcontainers.repo
curl https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.28:/1.28.1/CentOS_9_Stream/devel:kubic:libcontainers:stable:cri-o:1.28:1.28.1.repo -o /etc/yum.repos.d/crio.repo
yum repolist
yum search cri-o
yum install cri-o -y
systemctl enable --now crio

#
# podman 설치 한 후, crio설치 시, policy.json문제 발생
#
vi /etc/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports":
        {
            "docker-daemon":
                {
                    "": [{"type":"insecureAcceptAnything"}]
                }
        }
}

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
net.bridge.bridge-nf-call-iptables=1    ## container ---> link ---> tap ---> bridge
net.ipv4.ip_forward=1                   ## pod <---> svc
net.bridge.bridge-nf-call-ip6tables=1   ## ipv6
EOF
sysctl --system                           ## 재부팅 없이 커널 파라메타 수정하기
dracut -f 								  ## ramdisk 갱신
```

### kubeadm init as single controller role node

```bash
master]# kubeadm init --apiserver-advertise-address=192.168.90.110 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16
master]# systemctl is-active kubelet  							## active
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
node]# kubeadm join 192.168.90.110:6443 --token yspx54.k2076yehis972cng \
        --discovery-token-ca-cert-hash sha256:4743574ead43b14374be00496294bcb5ee85a3967724c0c3464ca9dcb576fb27
master]# kubectl get nodes    
```
### 터널링 네트워크 구성

```bash
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml -o tigera-operator.yaml
kubectl create -f tigera-operator.yaml
curl https://raw.githubusercontent.com/tangt64/training_memos/main/opensource-101/kubernetes-101/calico-quay-crd.yaml -o ~/calico-quay-crd.yaml
kubectl apply -f ~/calico-quay-crd.yaml
kubectl get pods -wA   						## -w: wait, 갱신되면 화면에 출력, -A: 모든 네임스페이스 Pod출력
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


