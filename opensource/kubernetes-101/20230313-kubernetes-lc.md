# day 1

## 강의 주제: 쿠버네티스 기초

강사 이름: 최국현

메일 주소: 
- bluehelix@gmail.com
- tang@linux.com

https://github.com/tangt64/training_memos/blob/main/opensource/kubernetes-101/20230313-kubernetes-lc.md

## 문서 및 자료 주소
1. https://github.com/tangt64/training_memos/tree/main/opensource/kubernetes-101
2. https://github.com/tangt64/training_memos
3. https://github.com/tangt64/duststack-k8s-auto

## 선수 사항

1. 컨테이너 런타임 기본 지식 및 이해
2. OCI표준 도구에 대한 기본 지식 및 이해
> container == docker ---> containerd(standard) ---> docker(deprecated) ---> cri-docker(kubernetes)
> OCI(image, command), podman, buildah, skopeo
> docker ---> podman, docker build ---> buildah, docker search ---> skopeo

## 내부 ISO내려받기 주소

http://172.16.8.31/

## 잠깐 잡담

kubernetes docker based

기존 리눅스 컨테이너는 vServer프로젝트에서 시작.

1. 가상머신(하드웨어 + 커널 + 소프트웨어)
  * 프로세스 격리(호스트하고 분리 운영)
  * dom0(코스트, 즉 비용이 높음)
  * vcpu, vmem 자원 활용을 제한

2. 컨테이너(커널 의존성이 강한 기술)
  * 프로세스 격리(호스트하고 분리 운영)
  * 낮은 비용으로 프로세스 격리 
  * namespace(process isolate(ing))
  * cgroup(자원제한)

3. google 먼저 시도(프로세스를 격리)
        
### runtime
- lxc(ring structure(x86))
- chroot(-)
- Jails(-, bsd)
- rkt(ring structure(x86))
- docker(rootless, ring shared)

### 이전 도커
- 컨테이너 관리
- 네임스페이스 및 cgroup를 관리
- dockerd 밑으로 모든 자원을 관리
  * containerd(컨테이너 생성, 분리요청)
  * kubernetes, CRI-O
  * docker(x), Podman
    - skopeo
    - buildah    

## 랩 환경

Windows 10/11 Pro(HyperV)
- Virtulbox(VCPU(AMD))
- VMware Workstation(license)
- VMware Player(personal free)

### 하이퍼브이 가상머신 설정
- ISO 
  * CentOS-8-Stream
  * Rocky 8/9
  * RHEL 8/9
  * Oracle 8/9
- 3대 설치(1 마스터, 2 워커)
- 네트워크 2개
  * Default
  * internal(없으면, "가상 스위치 관리자"에서 생성 )
- 가상CPU 2개, 가상 메모리 4096MiB

### 가상머신 설정

- 루트 암호
  * centos
- 네트워크 시간 꼭 활성화(Time & Date)
  * Seoul, Korea
  * NTP활성화
- 소프트웨어 선택(software selection)
  * Minimal Instal
- 네트워크 설정(master, node1, node2)
  * eth0: DHCP
  * eth1: STATIC(manual)
    * master: 192.168.90.110/24, GW(x)
    * node1: 192.168.90.120/24, GW(x)
    * node2: 192.168.90.130/24, GW(x)
  * method: manual
  * IP: 192.168.90.X
  * NETMASK: /24, 255.255.255.0
  * GATEWAY: NONE
  * OFF ---> ON

[파워쉘 다운로드](https://learn.microsoft.com/ko-kr/windows/terminal/install)


## 런타임???

1. docker
2. podman
```bash
dnf search docker
dnf search podman
dnf install podman -y
systemctl is-active podman
podman images
podman pod ls
podman container ls
```

### POD
1. Pod 격리목적(애플리케이션 컨테이너를 격리)
2. Infra Container(mount, network, IPC, uts)
3. Pod에서 사용하는 pause application, 각각 다름
4. Pod == Container
5. 추상적인 개념은 같지만, 애플리케이션(POD Application)은 다름

```bash
podman pod create
podman pod ls
podman pod start <ID>
ps -ef | grep conmon
podman save f6e7446e6d3d -o pause.tar
mkdir images
tar xf pause.tar -C images/
cd images/
tar xf fbffd51150c91376e3716bb1703583b76f7207a6910883dd75c259075947a6e5.tar
```
### POD의 공통 부분

1. 네임스페이스(linux kernel namespace)
2. 자원 관리자(cgroup)

```bash
cd /proc/self/ns
lsns   ## namespace 자원 확인

```

### Container

1. containerd
2. cri-o


### 나노 에디터 설정

```bash
dnf install nano -y
```
```bash
nano ~/.nanorc
# Supports `YAML` files
syntax "YAML" "\.ya?ml$"
header "^(---|===)" "%YAML"
## Keys
color magenta "^\s*[\$A-Za-z0-9_-]+\:"
color brightmagenta "^\s*@[\$A-Za-z0-9_-]+\:"
## Values
color white ":\s.+$"
## Booleans
icolor brightcyan " (y|yes|n|no|true|false|on|off)$"
## Numbers
color brightred " [[:digit:]]+(\.[[:digit:]]+)?"
## Arrays
color red "\[" "\]" ":\s+[|>]" "^\s*- "
## Reserved
color green "(^| )!!(binary|bool|float|int|map|null|omap|seq|set|str) "
## Comments
color brightwhite "#.*$"
## Errors
color ,red ":\w.+$"
color ,red ":'.+$"
color ,red ":".+$"
color ,red "\s+$"
## Non closed quote
color ,red "['\"][^['\"]]*$"
## Closed quotes
color yellow "['\"].*['\"]"
## Equal sign
color brightgreen ":( |$)"
set tabsize 2
set tabtospaces

```
```bash
nano test.yaml
---
- hosts: all
  tasks:
  - name: hello
    module:
       args1:
       args2:
```

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

```

```bash
systemctl stop firewalld && systemctl disable firewalld
swapon -s
swapoff -a
dnf install tc -y
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

# day 2


실무에서 쿠버네티스 설치 방법

__kubeadm__: bootstrap(ing)명령어. 마스터 + 노드 구성

1. kubeadm 기반: 이 명령어 기반으로 옵션 설정 및 클러스터 구성 
  - 쉘 스크립트 기반으로 구성하는 경우
2. kubeadm + YAML Configuration: kubeadm                  
  - 앤서블이나 혹은 테라폼으로 자동화 하는 경우
  - kubernetes-202에서 참고

## init 사용자 설정

* --apiserver-advertise-address: eth1로 설정 m <---> n 서로 API통신시 사용.
* --cri-socket: 현재 사용하는 런타임의 소켓 위치(조만간 사라질 옵션)
* --pod-network-cidr: POD가 사용할 POD네트워크 정보(터널링 대역)
* --service-dns-domain: cluster.local ---> devops.project
* --upload-certs[x]: preflight과정에 TLS키 생성 후, etcd서버에 업로드(마스터 TLS키). 
* --control-plane-endpoint[x]:   


master2: 192.168.90.200
master3: 192.168.90.210

```bash
kubeadm init --apiserver-advertise-address=192.168.90.110 \
 --control-plane-endpoint 192.168.90.110 \
 --cri-socket=/var/run/crio/crio.sock \
 --upload-certs \
 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16 \
 --service-dns-domain=devops.project
```

master join
```bash
kubeadm join 192.168.90.110:6443 --token yspx54.k2076yehis972cng \
        --discovery-token-ca-cert-hash sha256:4743574ead43b14374be00496294bcb5ee85a3967724c0c3464ca9dcb576fb27 \
        --control-plane --certificate-key f45f54f44bb08318926005b5619a6af5523acb30f132da31f2172555efbfb2b8
```

node join
```bash

kubeadm join 192.168.90.110:6443 --token yspx54.k2076yehis972cng \
        --discovery-token-ca-cert-hash sha256:4743574ead43b14374be00496294bcb5ee85a3967724c0c3464ca9dcb576fb27
```

## 터널링 네트워크 구성

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/calico-quay-crd.yaml
kubectl get pods -wA   ## -w: wait, 갱신되면 화면에 출력, -A: 모든 네임스페이스 Pod출력
```

## UFS/Overlay

```bash
podman run -d quay.io/centos/centos:stream8 sleep 1000
podman container ls
podman exec -ti <ID NAME> /bin/bash
```

## merge 디렉터리
```bash
podman run -d quay.io/centos/centos:stream8 sleep 1000
podman exec -it <ID> tocuh babo.txt
podman inspect <ID>   ## merged
ls -al <MERGED_DIR>/babo.txt
```


# day 3


## 프로세스 공유(in namespace)

```bash
cat <<EOF> namespaceshare.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: quay.io/redhattraining/hello-world-nginx
  - name: shell
    image: quay.io/quay/busybox:latest
    securityContext:
      capabilities:
        add:
        - SYS_PTRACE
    stdin: true
    tty: true
EOF
kubectl create -f namespaceshare.yaml
kubectl debug -it nginx --image=quay.io/quay/busybox:latest --target=nginx
```
## 디버그

```bash
kubectl run --image quay.io/redhattraining/hello-world-nginx debug-nginx 
kubectl debug -it debug-nginx  --image=quay.io/quay/busybox:latest --target=debug-nginx
```

## 멀티 마스터 노드 추가 
먼저 "phase upload-certs"실행 후 출력되는 "아이디를" --certificate-key에 명시.

마스터 노드 추가
```bash
kubeadm init phase upload-certs --upload-certs   ## kube-system configmap에 저장
kubeadm token create --certificate-key <KEY_ID> --print-join-command
kubeadm join --control-plane --certificate-key
```

워커 노드 추가
```bash
kubeadm token create --print-join-command
@node]# kubeadm join 
```

## 메트릭/역할(임시)
```bash
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/metrics.yaml
kubectl label node node1.example.com node-role.kubernetes.io/worker=worker
kubectl label node node2.example.com node-role.kubernetes.io/worker=worker
kubectl top nodes
kubectl get nodes
```

## 자동완성

1. kubeadm
2. kubectl

```bash
dnf install epel-release -y
dnf install bash-completion -y
dnf install fish -y
kubeadm completion bash > kubeadmrc
kubectl completion bash > kubectlrc
bash
source kubeadmrc
source kubectlrc
complete -rpf
```

```fish
kubectl completion fish > kubectlrc
source kubectlrc
complete -rpf

```

## 연습문제

```bash
kubectl create namespace basic
kubectl config set-context --current --namespace basic
kubectl run --image quay.io/redhattraining/hello-world-nginx debug-nginx
kubectl get pods
kubectl expose pod debug-nginx --port=8080 --protocol=TCP --name=debug-nginx --type=LoadBalancer

```

# day 4
```bash
kubectl run --image quay.io/redhattraining/hello-world-nginx --port=8080 --labels=app=nginx,owner=dev debug-nginx-3 -oyaml --dry-run=client > nginx3.yaml
kubectl create -f nginx3.yaml
kubectl create deployment my-nginx --image=nginx --port=8080 --dry-run=client -oyaml > my-nginx.yaml
```

## 노드 빼기

리셋후 kubeadm init ::ipv6, calico ---> ipv6 ---> reboot ---> init

master1.example.com not found, can not registerd
- /etc/hosts ---> /etc/resolve.conf
- /etc/hosts의 레코드가 올바르게..???
=> umount -a
=> rm -rf /var/lib/kubelet /etc/kubernetes/
=> rm -rf /var/lib/containers/storages/overlay-* (물리문제)

k8s_metrics경우, 크게 문제 없으면 동작이 되어야 됨.
- api not found 
- metrics api sever can not start 
- selinux, firewalld, reboot
- init --> metrics --> calico --> 물리문제 
           <creating>
corosync(multi nodes for etcd)

master3: cordon
master2: cordon(x), member remove <ID>

```
object-"kube-system"/"kube-root-ca.crt": Failed to watch *v1.ConfigMap: failed to list *v1.ConfigMap: configmaps "kube-root-ca.crt" is forbidden: User "system:node:master.example.com" cannot list resource "configmaps" in API group "" in the namespace "kube-system": no relationship found between node 'master.example.com' and this object
```

etcd(강제로 맴버 제거)
```bash
/etc/kubernetes/pki/etcd
kubectl exec -n kube-system etcd-master.example.com -- etcdctl  --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/peer.crt --key /etc/kubernetes/pki/etcd/peer.key member list
kubectl exec -n kube-system etcd-master.example.com -- etcdctl  --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/peer.crt --key /etc/kubernetes/pki/etcd/peer.key member remove <ID>
kubectl exec -n kube-system etcd-master.example.com -- etcdctl  --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/peer.crt --key /etc/kubernetes/pki/etcd/peer.key get --keys-only --prefix=true "/"
```


taint
```bash

```

cordon
```bash
kubectl cordon node2.example.com 
kubectl drain node2.example.com --force --ignore-daemonsets
kubectl uncordon node2.example.com
```
drain
```bash
kubectl drain node2.example.com --force --ignore-daemonsets
kubectl uncordon node2.example.com
```
```
crio: "컨테이너 엔진", 관리 및 쿠버네티스와 연결
 \
  `---> conmon(container monitor)
         \
          `---> -b: bundle, 컨테이너 이미지 위치
                -c: 컨테이너 아이디
                -r: 런타임(컨테이너 생성), runc(go lang), crun(c lang)
                     \
                      `---> runc
                              \
                               `---> process(pid)
                                       \
                                        `---> lsns, nsenter
```
