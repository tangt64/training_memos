# day 1

## 강의 주제: 쿠버네티스 기초

__강사 이름:__ 최국현

__메일 주소:__ tang@linux.com

## 문서 및 자료 주소

1. https://github.com/tangt64/training_memos/tree/main/opensource-101/kubernetes-101
2. 20231120-kubernetes-shinhan.md
3. [화이트 보드 링크](https://wbd.ms/share/v2/aHR0cHM6Ly93aGl0ZWJvYXJkLm1pY3Jvc29mdC5jb20vYXBpL3YxLjAvd2hpdGVib2FyZHMvcmVkZWVtL2ZiMjM0ZThlNmQyMTQwNmFhMWUzOTA0MGYxYTBjMTkxX0JCQTcxNzYyLTEyRTAtNDJFMS1CMzI0LTVCMTMxRjQyNEUzRF82OGJlYmVmZS0yNTI0LTQ5ZjQtYThhMy0xOTM0Yjg4MWRlYmY=)

## 시간

- 강의 시작 및 종료 시간: 오전 09:00분 ~ 오후 05:50분
- 점심 시간: 오전 11:30분 ~ 오후 01:00분


## 선수 사항

1. 컨테이너 런타임 기본 지식 및 이해
- docker, podman(OCI, CRI)
- 최신 컨테이너의 동작구조
- 표준 컨테이너 도구
- Pod와 Container의 차이
2. OCI표준 도구에 대한 기본 지식 및 이해
- buildah, skopeo
3. 리눅스 시스템
- 처음 사용자

## 라이선스 문제

__레드햇에서 더 이상 SRPM를 재배포 금지!!__

```

CentOS
  ==                 			   [up-stream, rolling]
 RHEL 		---		 CentOS   ---     Fedora
                 ------
                 \
                  `---> CentOS-Stream [up-stream, rolling]
                  |
                   `---> Rocky Linux 
                          \
                           `---> ABI/KABI호환성 유지 선언
```

1. 오픈소스는 GPL라이선스
2. SRPM의 라이선스는 대다수가 GPL/MIT/BSD로 구성
3. SRPM제공은 __패키징 서비스__ 제공은 레드햇 
4. 재배포는 금지(SRPM -> Oracle, Rocky, Alma)
5. ABI/KABI의 호환성
6. 더 이상 rhel하고 100%호환성을 제공하지 않음

From centos to RHEL(X)
---
https://access.redhat.com/discussions/5779541

From centos-stream to Rocky(O)
---
https://ciq.com/products/rocky-linux/


1. Redhat CentOS ---> Rocky/Oracle/Alma
2. SuSE: OpenSUSE Leaf ---> SESL
3. ubuntu: Ubuntu Comm ---> Ubuntu ENT

## 표준 컨테이너
```bash
 .-------------- PODMAN ----------------.
/                                        \
RUNTIME(APP_Container(APP + Container LIB))
------- ---------------------------------
  CRI                     OCI
```
1. OCI: Open Container Image(v1: docker-image, v2: oci-image)
2. CRI: Container Runtime Interface(containerd(CRI adapter), CRI-O)
3. POD/CONTAINER

- 고수준(runtime engine): Docker, Podman
- 저수준: containerd(dockerd), cri-o, runc(컨테이너 생성)
- 저수준 관리자: conmon(container monitor)

```bash
podman
  \
   `---> conmon
           \
            `---> runc
                    \
                     `---> Container Process(LIB + APP)
                           namespace+c-group
```

1. ifconfig, netstat, route...
2. standard modern linux(systemd)
3. RHEL 10(xfs, stratis-dracut, vdo)

```bash
dnf search podman epel-release
dnf install epel-release 
dnf search podman
dnf install podman podman-docker podman-compose -y

podman pod ls
podman container ls

grep -Ev '^#|^$' /etc/containers/registries.conf
> unqualified-search-registries = ["quay.io"]
podman search httpd
podman run -d --name httpd-24-centos-7 --rm quay.io/centos7/httpd-24-centos7
ps -ef | grep httpd
whereis httpd
rpm -qi httpd
find / -name httpd -type f -print 
cd /var/lib/containers/storage/overlay

## 컨테이너 네트워크

iptables -L -n -t nat
nft list table nat

## 포드/컨테이터

podman run -d --name httpd-24-centos-7 -p 58080:8080 --rm quay.io/centos7/httpd-24-centos7

podman network create shared          ## flanned, calico
podman network inspect shared

podman pod create --name pod1 --network shared --share uts,ipc,net
podman run -d --pod pod1 --name pod1-httpd-1 --network shared quay.io/centos7/httpd-24-centos7 --port 8080
podman run -d --pod pod1 --name pod1-httpd-2 --network shared quay.io/centos7/httpd-24-centos7 --port 8080

podman generate kube pod1 --service --filename pod1.yaml


```

### POD? Pause?

POD: 개념
\
 `---> Pause: Pod 구현 애플리케이션
 `---> Infra Container(Pod Container)
       (namespace, cgroup)

systemd: PID 1
VM: systemd, PID 1
Container: systemd(x), Pause PID 1, 


```bash
 Pause --- (APPLICATION + LIB)
        \     httpd       CentOS
         `---> (APPLICATION + LIB)
                  mysql       CentOS

man conmon
man run
``` 


```bash
runc: 일반적으로 많이 사용하는 컨테이너 생성(kubernetes,go)
crun: 레드햇 제품에서 많이 사용(openshift, rancher, c)

crun: 컨테이너 생성(/var/lib/containers/storages/overlay), overlay module
      \
       `---> lsmod | grep overlay --- /var/lib/containers/overlay(binding mount)
        ---> mount -obind

컨테이너에 연결되는 장치는 전부다 호스트 컴퓨트(worker node)를 통해서 전달 받음.
 
[10.10.10.10:/container_disk/] ---> worker_node --->  [bind] ---> | container |
                                     [mount]       </var/lib/containers/>

infraContainer = Container
conmon: LifeCycle Mangement(stop, start, rm, restart(stop+start))

<------엔진----->    <---------- 관리/생성 -------->
podman         ---> conmon ---> runc ---> container 
[고수준,명령어]

crio/container ---> conmon ---> runc ---> container
[저수준,socket/api]

                    +-----------------+
                    |podman/kubernetes|  <--- # podman container run -d --pod pod1 --name httpd -p 58080:8080 <IMAGE>
                    +-----------------+  <--- # podman pod create pod1
                            |                 # podman container ls
                            |
                    .---- conmon----.
                   /                 \         [infraContainer]
# ps -ef | conmon /                   \        +---------------+
           .--- runc # crun list     runc -----*      POD      |  # podman pod ls 
          /         ipc,uts,net,mnt,pid        |    [pause]    |  # ps -efw | grep catatonit
         /          [cgroup/namespace]         +---------------+                  pause
        /                                                    \
    +--*--------+    # lsns                                   \
    | container |    # systemd-cgls                            v
    |  [httpd]  | --- dport 10.88.0.4:8080 --- saddr: 10.88.0.0:58080 <--- #curl localhost:58080
    | 8080/tcp  |      \         [nftables]                       /
    +-----------+       \        [linux bridge]                  /
                         `--------------------------------------'

VM: 4 x 2 = 8
CON: 4

APP ---> USERSPACE DRIVER --- KERNEL DRIVER ---> KERNEL

httpd ---> PID 1[systmed] ---> kernel(ring)

httpd ---> PID 1[application] ---> runc(HV) ---> systemd ---> KERNEL
lsns
- mnt, ipc, net, uts
```


### 쿠버네티스 설치 준비


eth0: 외부망(k8s image, rpm)
eth1: 쿠버네티스 내부망(Pod vlan/vxlan)

```bash
nmcli dev eth1
nmtui edit eth1
nmcli con sh
nmtui edit "Wired connection 1"
> 아이피 주소
> "Automatic" -> "Manual"
> "Never use this network for default route"
nmcli con sh
ip a s eth0
```


node1
---
eth1: 192.168.90.110/24

node2 
---
eth1: 192.168.90.120/24

node3
---
eth1: 192.168.90.130/24


# day 2

레드햇 계열(커뮤니티 버전중심으로) 사용이 가능한 저수준 컨테이너 런타임은 2개

1. containerd(from docker)
>https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-rocky-linux-9
2. cri-o(from opensuse CBS)
>https://cri-o.io/


## CRIO

```bash
## https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/

#
# libcontainer 
#
## 사이트에서 제공하는 저장소 내려받기 방법
export OS=CentOS_9_Stream
echo $OS
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:/kubic:/libcontainers:/stable.repo

## libcontainer, 표준 컨테이너 라이브러리(CRI)
## 직접 내려받기
curl -o /etc/yum.repos.d/libcontainer.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_9_Stream/devel:kubic:libcontainers:stable.repo

#
# LOW level CRIO RUNTIME
#

## 사이트에서 제공하는 저장소 내려받기 방법
export OS=CentOS_8
export VERSION=1.24.6
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo

## 직접 내려받기(https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/)
## CRIO런타임 내려받기
curl -o /etc/yum.repos.d/crio.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.6/CentOS_8/devel:kubic:libcontainers:stable:cri-o:1.24:1.24.6.repo

dnf repolist
dnf search cri-o
dnf install -y cri-o 

dnf provides crictl
> cri-tools
dnf install cri-tools -y
podman ps
crictl ps
systemctl enable --now crio
crictl ps


setenforce 0
getenforce 
vi /etc/selinux/config/
> SELINUX=permissive

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.24/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.24/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

dnf install tmux
```

## containerd

```bash
systemctl stop crio
dnf remove cri-o -y
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf repolist
dnf search containerd
dnf instrall containerd -y
containerd config default > /etc/containerd/config.toml
systemctl enable --now containerd
```

## kubeadm

```bash
firewall-cmd --get-services | grep kube
> kube-api kube-apiserver kube-control-plane kube-control-plane-secure kube-controller-manager kube-controller-manager-secure kube-nodeport-services kube-scheduler kube-scheduler-secure kube-worker kubelet kubelet-readonly kubelet-worker
for i in kube-api kube-apiserver kube-control-plane kube-control-plane-secure kube-controller-manager kube-controller-manager-secure kube-nodeport-services kube-scheduler kube-scheduler-secure kube-worker kubelet kubelet-readonly kubelet-worker ; do firewall-cmd --add-service=$i --permanent ; done 
firewall-cmd --reload

systemctl stop firewalld
systemctl disable firewalld

swapon -s
swapoff -a
vi /etc/fstab
> # ~~~ swap   swap
systemctl daemon-reload

cd /lib/modules/$(uname -r)/
> /lib/modules/5.14.0-284.11.1.el9_2.x86_64/kernel/net/netfilter
> /lib/modules/5.14.0-284.11.1.el9_2.x86_64/kernel/net/bridge
modprobe br_netfilter
lsmod | grep br_netfilter
echo br_netfilter > /etc/modules-load.d/k8s_module.conf

sysctl -a | grep ip_forward
sysctl -w net.ipv4.ip_forward=1
sysctl -a | grep ip_forward

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/k8s.conf
systemctl daemon-reload

# 아래 파일에 redhat관련 단어가 있으면 아래 같이 수정
#
cat /etc/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker-daemon": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        }
    }
}

hostnamectl set-hostname control1.example.com
ip a s eth0
echo "10.10.10.1 control1.example.com control" >> /etc/hosts


kubeadm completion bash > /etc/bash_completion.d/kubeadm
kubectl completion bash > /etc/bash_completion.d/kubectl
complete -rp

## API-SERVER:6443

1. kubeadm init
2. kubeadm init --apiserver-advertise-address=192.168.90.110 --pod-network-cidr=192.168.10.0/24 --service-cidr=10.10.10.0/24 --service-dns-domain=shinhan.k8s
3. kubeadm init --apiserver-advertise-address=192.168.90.110


ss -antp | grep 6443
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl cluster-info
kubectl cluster-info dump
kubectl cluster-info dump | grep -i -e cidr -e clusterIP

kubectl describe nodes control1.example.com | grep -i taints

kubeadm token create --print-join-command

kubeadm reset
```

```bash
/etc/hosts
---
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.90.110  control1.example.com control1
192.168.90.120  worker1.example.com worker1
192.168.90.130  worker2.example.com worker2

1. firewalld
2. swap + selinux
3. timedatectl
  > systemctl restart chronyd
  > chronyc sources
  > timedatectl
    > System clock synchronized: yes

```


```bash
kubeadm init  -v3
        join  -v3

* reached, retry, expire...
* used, already == kubeadm reset --force
```

## 자동완성(명령어, kubectl, kubeadm)
```
kubeadm completion bash > /etc/bash_completion.d/kubeadm
                   zsh
                   fish
kubectl completion bash > /etc/bash_completion.d/kubectl
complete -rp
```


## calico 설치(마스터 실행)
```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/tigera-operator.yaml
kubectl get pods -A               ## docker.io blocked
> Error
#
# 이미지를 quay.io에서 가져오는거 + 네트워크 대역(Pod)
#
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource-101/kubernetes-101/calico-quay-crd.yaml
kubectl get pods -A 
> Running
```

```bash
## control1 
#
# POD Network IP == eth1, internal
#
# kubeadm init == 컨트롤
# 
kubeadm init --apiserver-advertise-address=192.168.90.110 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource-101/kubernetes-101/calico-quay-crd.yaml
kubectl get pods -Aw

## worker1/2

kubeadm join

```


## TS???

```
kubeadm reset --force
cd /var/lib/
(X)/crio
(O)/containers, rm -rf
(O)/calico,     rm -rf 
(O)/etcd,       rm -rf
(O)/cni         rm -rf 
(O)/
cd /etc/
(O)/kubernetes, rm -rf
cd /run/
(O)/calico,     rm -rf
(O)/containers, rm -rf

reboot ---> kubeadm init
```

```bash
kubectl run test-httpd --image=quay.io/centos7/httpd-24-centos7
kubectl get pods
kubectl get svc
kubectl expose pod test-httpd
kubectl expose pod --port 8080 test-httpd
kubectl expose pod --port=8080 --type=NodePort test-httpd
kubectl expose pod --port=8080 --type=NodePort --name=np-test-httpd test-httpd
```

1. 무조건 최초 한대 서버는 init로 구성
2. 그 이후로 구성되는 컨트롤러, 워커노드는 join구성
3. reset은 재구성이 필요한 경우 사용. 그 이외 용도는 없음
4. Pod네트워크 혹은 클러스터 네트워크 최초 노드 생성 후, 구성
5. 최초 서버 + 네트워크 구성이 완료가 되면, 그 이후로 노드 확장

# day 3


EKS vs OnPremise
---

1. https://www.techtarget.com/searchaws/tip/2-options-to-deploy-Kubernetes-on-AWS-EKS-vs-self-managed
2. https://www.reddit.com/r/kubernetes/comments/y5cpxh/running_a_kubernetes_cluster_across_onpremise_and/
3. https://www.uturndata.com/2022/10/10/migrating-to-amazon-eks-vs-vanilla-kubernetes/
4. https://medium.com/bestcloudforme/on-premises-kubernetes-game-is-changing-with-aws-2ec76980cd6f


## 명령어 자동완성(kubectl, kubeadm)
```
kubeadm completion bash > /etc/bash_completion.d/kubeadm
                   zsh
                   fish
kubectl completion bash > /etc/bash_completion.d/kubectl
complete -rp
```


```bash

1. 코드(YAML FOR DATA)
2. 데이터(JSON FOR API)
3. 설정(TOML FOR CONFIG)

           .---> KUBECONFIG: SHELL VAR(V)
          /      ~/.kube/config: DIR
      <login>
        /
       .---> /etc/kubernetes/admin.conf
      /       > name:
     /        > key:                                                replicaController(POD)
    /         > URL:                                                replicaset(POD)                    1. network
   /                                proxy         containerzied     deployment        node(cpu,mem)    2. container
kubectl --- <YAML> ---<JSON> ---> [kubelet] ---> [API_SERVER] ---> [controller] ---> [scheduler] ---> [proxy] ---> CRI-O
  \              :6443                                             ------------                               ---> LinuxBridge/vxlan                  
   \                                                                delpoy+ReplicaSet
    \
     `---> kubectl run test-nginx --image=nginx --output=yaml --dry-run=client
                                                -o=json       

control
---
controller/scheduler/apiserver: API 작업 처리
etcd: control plane(scaleable), key pair DB
coredns: control plane(scaleable), DNS Service for Kubernetes Service

control/worker
---
kubelet: monitoring(pod, node status, proxy)
proxy: control, compute(daemon service, container, network)

worker node
---
- kubelet.service(hosted)
- proxy(container, static-pod)
  * proxy network
  * runtime(socket)
    + CRI-O
    + containerd
    + cri-docker
```


## VM/Container

VM(baremetal: Software, Hardware)
---
1. 하이퍼바이저 필요
2. 가상장치가 필요
3. O/S설치 및 구성 필요
4. 가상기반으로 "생성"
5. TCP/IP 100%

Container(root ful/less)
---

1. rootful(LXC)

VM하고 거의 동일. 호스트 커널을 거의 그대로 사용. LXC/LXD(IBM)컨테이너. rootful 컨테이너 정보는 [rootful container](https://raesene.github.io/blog/2020/02/23/More-Podman/), [https://linuxcontainers.org/](https://linuxcontainers.org/), [lxc/podman/docker](https://www.reddit.com/r/homelab/comments/p5f07o/lxclxd_vs_docker_vs_podman/), [docker/lxc](https://www.upguard.com/blog/docker-vs-lxc)

- VM처럼 시작이 느림
- 가상머신과 비교시 장점이 없음

2. rootless

VM하고 비슷한 구조를 가지고 있으나, 대다수 자원은 호스트를 통해서 공유. session과 같은 기술을 구현하기 위해서 다음과 같은 기술을 쿠버네티스에서 지원.

1. [Session Affinity](https://www.ibm.com/docs/en/datapower-gateway/7.6?topic=groups-session-affinity)
2. [Istio Sticky Session](https://istio.io/latest/docs/reference/config/networking/destination-rule/)

- 부팅이 필요 없음
- 격리 및 추적 기술 기반으로 동작
- 대다수 기술이 커널에서 구현
- Podman/Docker와 같은 기반으로 구현하는 경우, 90%이상 VM하고 동일하게 구현 가능
  + AI/ML
  + TCP/UDP왠만하면 다 호환
- 쿠버네티스는 가상머신처럼 모든 서비스를 구현 및 실현이 어려움
  + 확장이 가능한 구조(scale out, HPA)
  + UDP나 혹은 세션 정보가 필요한 경우, 쿠버네티스와 적절하지 않을수 있음
  + 수직 확장도 지원하나...(VPA)
  + 인그레스 서비스를 통해서 외부에서 직접 POD접근 허용

## 설치 정리

```bash
dnf update -y
hostnamectl set-hostname control1.example.com
                         worker1.example.com
                         worker2.example.com
nmcli con show
nmcli con mod eth1 ipv4.addresses 192.168.90.110/24 ipv4.method manual
nmtui edit eth1
nmcli con mod eth1 ipv4.addresses 192.168.90.120/24 ipv4.method manual
nmtui edit eth1
nmcli con mod eth1 ipv4.addresses 192.168.90.130/24 ipv4.method manual
nmtui edit eth1
nmcli con reload eth1

cat <<EOF>> /etc/hosts      ## control1, worker1, worker2
192.168.90.110  control1.example.com control1
192.168.90.120  worker1.example.com worker1
192.168.90.130  worker2.example.com worker2
EOF

## 쿠버네티스 저장소

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.24/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.24/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

## cri-o런타임 설치 control1/worker1/2
#
curl -o /etc/yum.repos.d/crio.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.6/CentOS_8/devel:kubic:libcontainers:stable:cri-o:1.24:1.24.6.repo

## libcontainer 설치 control1/worker1/2
#
curl -o /etc/yum.repos.d/libcontainer.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_9_Stream/devel:kubic:libcontainers:stable.repo

## crio, kubelet 서비스 시작, control1/worker1/2
#
dnf install cri-o kubelet kubeadm kubectl -y --disableexcludes=kubernetes
systemctl enable --now crio
systemctl enable --now kubelet

## 방화벽 중지 
# 

systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/enforcing/permissive/' /etc/selinux/config
swapon -s 
swapoff -a
vi /etc/fstab
## 스왑파일 주석처리

modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1
echo br_netfilter > /etc/modules-load.d/k8s.conf
echo "net.ipv4.ip_forward=0" > /etc/sysctl.d/k8s.conf

systemctl daemon-reload


#
## 쿠버네티스 설치
#

## 연습용 추천 L/B: HAproxy/Ngninx, MetalLB
## L/B주소가 192.168.90.250라고 하면, "--control-plane-endpoint=192.168.90.250"
kubeadm init --upload-certs --control-plane-endpoint=192.168.90.110 --apiserver-advertise-address=192.168.90.110 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.10.10.0/24 -v3

## -v3...

# APP --> TAP/TUN --> KERNEL_SPACE 
# kubectl cluster-info dump | grep -e cidr -e clusterip
# (container)POD --- {POD_NETWORK(VXLAN)}
# ip link, bridge, brctl...
# ip netns exec <netns-ID> ip link
# [hosted] ---> <container> --- {podman_birdge}
# <container> ---> [hosted] 

# 1. crio containerd 찾을수 없음
# 2. WARNING, kubelet not enabled

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource-101/kubernetes-101/calico-quay-crd.yaml

kubeadm token create --print-join-command

worker1# kubeadm join
worker2# kubeadm join

kubeadm completion bash > /etc/bash_completion.d/kubeadm
kubectl completion bash > /etc/bash_completion.d/kubectl
complete -rp

kubectl run test-httpd --image=quay.io/centos7/httpd-24-centos7

```

https://www.stackrox.io/about/



MASTER: 3대 + metalLB

### 멀티 마스터 3대 구성 이유

1. etcd백업을 위해서
2. corosync(종족수)기능이 활성화 되기 위해서 3대가 필요함
3. API데이터 처리속도 향상
4. L4/L7이 필요

```bash
kubectl create deployment np-test-httpd --image=quay.io/centos7/httpd-24-centos7 --port=8080 --replicas=5 --dry-run=client --output=yaml > np-test-httpd.yaml
```
# day 4

```bash
@control1]# dnf install tmux
@control1]# kubectl delete namespace(ns) <test1>
@control1]# dnf install git -y
@control1]# curl -sS https://webi.sh/vim-ale | sh
@control1]# dnf install epel-release -y
@control1]# dnf install yamllint -y
@control1]# cat <<EOF> /$USER/.vimrc
au! BufNewFile,BufReadPost *.u{yaml,yml} set filetype=yaml foldmethod=indent
set autoindent expandtab tabstop=2 shiftwidth=2
EOF
@control1]# vi test.yaml
```
```yaml
---
- name: hello
  module:
    args1:
    args2:
```
```bash
@control1]# curl -o /usr/share/nano/yaml.nanorc https://raw.githubusercontent.com/serialhex/nano-highlight/master/yaml.nanorc
@control1]# cat <<EOF> /$USER/.nanorc
set tabsize 2
set tabstospaces
EOF
```
```bash
@control1]# nano test.yaml
```
```yaml
---
- name: hello
  module:
    args1:
    args2:
```

## YAML작성 방법

```bash
kubectl run                     ## POD
kubectl create namespace first-namespace -o=yaml --dry-run=client > first-namespace.yaml
```

```bash
mkdir basic-cmd
cd basic-cmd
nano second-namespace.yaml
```

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: second-namespace
  labels:
    type: namespace
...
```

```bash
kubectl create -f second-namespace.yaml
```

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: wordpress-service
  labels:
    service: wordpress
    type: namespace
...
```

```bash
kubectl apply -f wordpress-namespace.yaml
kubectl get ns -l type=namespace -l service=wordpress
```

# day 5