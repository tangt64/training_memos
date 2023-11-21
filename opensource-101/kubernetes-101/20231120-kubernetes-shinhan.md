# day 1

## 강의 주제: 쿠버네티스 기초

__강사 이름:__ 최국현

__메일 주소:__ tang@linux.com

## 문서 및 자료 주소
1. https://github.com/tangt64/training_memos/tree/main/opensource-101/kubernetes-101
2. 20231120-kubernetes-shinhan.md
3. [화이트 보드 링크](https://wbd.ms/share/v2/aHR0cHM6Ly93aGl0ZWJvYXJkLm1pY3Jvc29mdC5jb20vYXBpL3YxLjAvd2hpdGVib2FyZHMvcmVkZWVtL2ZiMjM0ZThlNmQyMTQwNmFhMWUzOTA0MGYxYTBjMTkxX0JCQTcxNzYyLTEyRTAtNDJFMS1CMzI0LTVCMTMxRjQyNEUzRF82OGJlYmVmZS0yNTI0LTQ5ZjQtYThhMy0xOTM0Yjg4MWRlYmY=)


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

## 시간

- 강의 시작 및 종료 시간: 오전 09:00분 ~ 오후 05:50분
- 점심 시간: 오전 11:30분 ~ 오후 01:00분

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
```

# day 3

# day 4

# day 5