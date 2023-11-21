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
export OS=CentOS_9_Stream
echo $OS
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:/kubic:/libcontainers:/stable.repo

curl -o /etc/yum.repos.d/libcontainer.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_9_Stream/devel:kubic:libcontainers:stable.repo

#
# LOW level CRIO RUNTIME
#
export OS=CentOS_8
export VERSION=1.24.6
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo

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
kubeadm init

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

kubeadm reset
```

# day 3

# day 4

# day 5