# day1

## lab plan(5번)

1,2: podman, crio
3,4: crio+kubernetes
  5: kubernetes
<pre>
docker runtime(==PODMAN) -->                                  --> KUBERNETES
   [PODMAN]                   [CRIO]
                              [CONTAINERD[EPEL]]
                              [DOCKER(==CRI-DOCKER(COMPIEL))]
</pre>
* podman은 io.podman혹은 podman.io라는 API서버를 가지고 있음.
* docker는 docker-ee(swam)서버를 가지고 있음.

docker-ee: RestAPI
-> 확장성은 매우 낮음
podman: podman.server, RestAPI
-> 확장성은 낮음
kubernetes: kubelet, kube-apiserver, RestAPI
-> 확장성이 큼

Low Level Runtime Engine
-------
cri-docker: socket, cri기반의 명령어 처리
cri-o: socket, cri기반의 명령어 처리
containerd: socket, cri adaptor, cri기반의 명령어 처리


```bash

  POD == CONTAINER == INFRA CONTAINER

   +------------+
   | kubernetes |  <--- MIDDLE WARE(API, MASTER/NODE ROLES, ORCHESTRATION, RESETAPI)
   +------------+                                          
-----------------------------------------------------------
container runtime engine layer
--> LOW
--> HIGH
    [EXEC]
    +---------+
    | runtime |
    |         | ---> SOCKET
    |  [LOW]  |
    +---------+
 # ps -ef | grep docker ---> docker(dockerd(containerd))
 # ps -ef | grep podman ---> conmon(OCI)

-----------------------------------------------------------
container create layer
       [FORK]
         |
       conmon
         |
        runc    ---> [container]
         |
    +--------+
    | kernel | - namespace
    +--------+ - cgroup
               - seccomp


```
### 가상머신 사양

vcpu: 2개
vmem: 4기가
vdisk: 최소 8기가
os: centos-9-stream

## 하이퍼바이저
- HyperV
  + Windows 10/11 pro
  + HOME, not support

- virtualbox(Windows 10, 11, vcpu bug)
- vmware player(vcpu)
- mac user
  + virtualbox
  + vmware fusion
  + vmware player
- ubuntu
  + apt search podman  

## docker vs podman(stand-alone-container-server)

OCI: Open Container Initiative
-> The Container(image, specs)
CNI: Container Network Interface
CSI: Container Storage Interface

podman: https://podman.io/, Pod Manager tool (podman)
buildah: https://buildah.io/, OCI container images.
-> https://github.com/mairin/coloringbook-container-commandos
-> https://github.com/containers/buildah/tree/main/docs/tutorials
skopeo: performs various operations on container images and image repositories.
-> https://github.com/containers/skopeo 

```bash
docker: search, build, container init
        ------  -----  ---------
        \       \      \
         \       \      `---> runc/crun
          \       `---> buildah
           `---> skopeo

runtime: runtime engine or container runtime engine           
         --------------
         \
          `---> container, image, volume....(meta)

```

docker(더 이상 개발이 되지 않음): OCI/CRI표준 컨테이너 이미지 및 런타임 사양
  - containerd: OCI/CRI 표준 컨테이너로 선언
  - cri-o: K8S에서는 이 녀석을 표준 런타임으로 사용
  - openshift, rancher...기타 컨테이너 미들웨어들은 cri-o기반으로 사용
  - cri-docker, 최근에 프로젝트 릴리즈

kubernetes runtimes list
  1. crio(default)
  2. containerd(standard)
  3. cri-docker(optional)

- 도커에서 사용하는 이미지가 산업표준
- 도커에서 사용하는 명령어 방식이 산업표준

## rocky vs rhel vs centos(HPC, CERN)

```
centos: release ---> rolling update  ---> RHEL(stream)
          v9.1          (stream)          Phase 1/2/3/4
          v9.2        3 years(EOL)              1: centos/rhel(os update + hardware)       
                                                2/3/4: subscription update only 
```                                                
RHEL7 RPM REPOS
----------------
base
os

RHEL8(9) RPM REPOS
----------------
baseos
appstream + module(PPA)
            SCL(Software Collection)

## 설치 시작

```bash
dnf install podman -y
systemctl status podman
podman images
podman container ls
podman pod ls
```

```bash
dnf install epel-release -y ## 엔터프라이즈 패키지 저장소
dnf search podman
dnf install podman-compose -y ## docker compose
dnf install podman-docker -y  ## docker command 
dnf install podman-tui -y     ## rhel9이후에 추가된 사용자 도구
dnf install podman-catatonit  ## POD 이미지 혹은 애플리케이션 
```

```bash
podman-tui        ## API 혹은 소켓 서버를 찾지 못함
systemctl enable --now podman
podman-tui
```

## 잠깐 교양 시간 :)

```bash
podman pod create
podman pod ls
                                                               *                *
POD ID        NAME               STATUS      CREATED        INFRA ID      # OF CONTAINERS
0b5b6be932c6  strange_goldstine  Created     7 seconds ago  0db5c2d7c918  1
                                                            ------------  ---------------
                                                            POD: K8S      POD CONTAINER: 1 RUNNING
                                                                          APP CONTAINER: 2 RUNNING
                                                                == INFRA CONTAINER
                                                                == CONTAINER

COMMAND <OBJECT> <VERB> <OPTION> <RESOURCE> <ARGS>
podman stop --all
podman rm --all
podman container run -d --name test-centos centos /bin/sleep 100000   ## 위치명령어, 옵션 위치에 따라서 동작이 안될 수도 있음
                                           ------
                                           hub.docker.io 
podman container ls                                           
podman pod create
podman pod start --all
podman pod ls                                           
```

pod, container는 같은 컨테이너 자원 및 개념

POD라는 애플리케이션이 각기 다른걸 사용하기 때문에, POD개념이 소프트웨어 별로 조금씩 다를수 있음. 

```
kubernetes: pause(pod(pause))
podman: pause(pod(catatonit))
OCP: pause(pod(catatonit))
Rancher: pause(pod(catatonit))

pause ---> pod ---> infra container
 \         \        \
  \         \        `---> 자원 호칭
   \         `---> 추상적인 개념
    `---> 애플리케이션 이름
```
```bash
ps -ef | grep podman    ## ??
ps -ef | grep conmon    ## container monitor process, mandb, man -k conmon
mandb
man -k conmon
man 8 conmon
   
   [stop]     
   docker ---> dockerd ---> containerd == all stop
                            ----------
                            OpenStack Kolla(containerd)
                                |
                                v
                            detached(daemon less,OCI)
                                         \
                                          `--->fork() ---> conmon ---> exec(container)

   podman ---> container create ---> detached(daemon less,OCI)
                                         \
                                          `--->fork() ---> conmon ---> exec(container)
                                         

conmon(CONTAINER_IMAGE) == Image Loader == /var/lib/containers/storages  ## 컨테이너 이미지 및 레이어 파일 저장
------
\
 `---> OCI 사양

crun(CONTAINER(container_environment(PODMAN)))
----
\
 `---> OCI 사양
```

### 컨테이너 이미지

```bash
cd /var/lib/containers/storage


```


### 자동완성 기능
```bash
dnf search bash-completion
dnf install bash-completion -y
complet -rp
exit | bash
```

## 격리기능

container: namespace(USERSPACE(격리(PROCE/SYSCALL)))
- 콜제한 및 환경 분리

virtualization: OS(ring_strcuture(bytecode(hypervisor(cpu_emulate))))
- 재구성
- 실제 물리장비와 똑같이 구현이 가능


namespace: 가상화하고 다르게 호스트의 자원을 공유하는게 주요 목적(격리 통해서)

## 잠깐 역사


격리:
컨테이너는: 호스트에서 동작하는 프로세스를 볼수 없음. +root권한 조절(rootless)
호스트는: 컨테이너에서 동작하는 프로세스를 볼수 있음.

가상:
가상머신은: 호스트의  프로세스를 볼수 없음.
호스트는: 가상머신의 내부 프로세스를 볼수 없음.


# podman
   ---> container ---> root 권한 ---> 가지치기


kernel(v4)
--------
- namespace
- cgroup
- seccomp


1999~00년도에 리눅스 가상화 프로젝트. vServer project

chroot기반으로 컨테이너 혹은 가상화 시스템 구성
당시 리눅스 커널에는 격리 기능이 없었음. 구글에서 리눅스 기반의 컨테이너 프로젝트 그리고 가상화 프로젝트 시작. 
- xen, kvm ---> 가상화 
- namespace ---> redhat, google, ibm 
  --------
  격리
- cgroup    ---> linux container ---> lxc(runtime,rootful(booting))   
  -----                                   ---> docker(runtime,rootless(none-boot, none-root))
  추적


## 포드만 런타임

URI
docker://
oci://

podman명령어로 제어(OCI)

/etc/containers/: 컨테이너 설정파일 위치
/var/lib/containers/: 컨테이너 이미지 파일 위치
/run/containers
/etc/cni/: 컨테이너 런타임이 사용하는 네트워크 설정 디렉터리




# 포드만 랩

컨테이너 둘러보기

```bash
podman run -ti --rm registry.access.redhat.com/ubi8/httpd-24 bash
        -t: tty, pesudo device
        -i: interactive, stdout/in, console(/dev/console)
        --rm: 컨테이너가 중지가 되면, 즉시 삭제

bash-4.4$ ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
default        1       0  0 05:38 pts/0    00:00:00 bash
default        3       1  0 05:41 pts/0    00:00:00 ps -ef

container(bash) ---> container(ps) ---> [syscall] ---> [seccomp] ---> <HOST> ---> namespace                                
```


```bash
     registry.access.redhat.com/ubi8/httpd-24
     ----
     서브스크립션이 필요
podman run -d -p  80:8080 --name my-httpd-app registry.access.redhat.com/ubi8/httpd-24
                  /    \
                 /      \
          <---사용자  <---컨테이너
    -p: port 컨테이너 및 호스트 포트 매핑
--name: 컨테이너가 사용할 이름

podman stop --all
podman rm --all
                          .----> 호스트
                         /   .---> 컨테이너
                        /   /
podman run -it --rm -p 8080:80 --name my-httpd-app quay.io/centos/centos:stream8 bash
                    ---
                    \
                     `---> 1. iptables(nft)
                           2. veth(tap)
                           3. bridge(switch)
                           4. namespace

ip netns 
ip netns exec <ID> ip a 
                   ip r 
iptables-save | grep 8080 
bridge link
bridge fdb                   
```

# 연습문제 

## 컨테이너 생성 문제

podman run -it --rm -p 호스트:컨테이너 --name     bash 
podman run -it --rm -p 9090:8080 --name hello-nginx quay.io/redhattraining/hello-world-nginx bash
podman run -d -p 9090:8080 --name hello-nginx-2 quay.io/redhattraining/hello-world-nginx


1. nginx(quay.io/redhattraining/hello-world-nginx)기반으로 컨테이너 생성
  - 컨테이너 이름은 hello-nginx
2. 8080포트는 호스트 9090으로 접근이 가능
3. 웹 페이지 내용을 변경
  - hello nginx
  - /usr/share/nginx/html/index.html
4. find으로 파일 위치 확인(index.html)
5. iptables-save, podman port로 아이피 및 포트 번호 일치 확인
6. ip netns exec, bridge로 아이피 및 장치 조회

	podman run -d -p 9090:8080 --name hello-nginx-2 quay.io/redhattraining/hello-world-nginx
curl localhost:9090
podman container port hello-world-ngninx
iptables-save | grep 9090


podman run -d --rm -p 8080:80 --name my-httpd-app quay.io/centos/centos:stream8 sleep 100000



## 컨테이너 커밋

컨테이너 생성 후 커밋을 한다.

- 컨테이너는 데비안 컨테이너를 생성한다. 
  - quay.io/official-images/debian
  - 이미지가 없는 경우 이미지를 런타임에 내려받기 한다.
- 생성된 데비안 컨테이너의 이름은 fresh-debian-server로 지정한다.
  - 생성 후 바로 이미지를 커밋한다.
  - 커밋 이름은 before-install-package-debian으로 한다.
- 데비안에 다음과 같은 패키지를 설치한다.
  - apache2
  - vsftpd
  - 설치시 사용하는 명령어는 apt install이다. apt install apache2 -y 
  - 올바르게 동작하지 않으면 apt update를 먼저 수행한다.
  - 설치가 완료가 되면 이미지를 커밋한다. 
  - 커밋 이름은 after-install-package-debian으로 한다.
- 설치가 완료가 되면 diff으로 before, after에 어떠한 차이가 있는지 확인한다.
  - 확인이 완료가 되면 before, after이미지를 제거한다.
  - 동작중인 컨테이너 fresh-debian-server는 중지한다.

```bash
podman commit fresh-debian-server before-install-package-debian
podman images
podman exec -it fresh-debian-server /bin/bash
podman commit fresh-debian-server after-install-package-debian
podman diff before-install-package-debian:latest after-install-package-debian:latest
```

  1. iptables, bridge부분 
  2. echo, permission 

# day 2

- podman 명령어 계속
- 컨테이너 이미지 부분
- 컨테이너 구조 및 구성

## 레지스트리 주소 추가 및 변경
```bash
pwd
/etc/containers
nano registries.conf
grep -Ev '^#|^$' registries.conf
unqualified-search-registries = ["quay.io"]
short-name-mode = "enforcing"
podman search centos
podman pull centos
podman search --list-tags centos/centos          ## tag목록이 출력이 되나, 자세하지는 않음
dnf install skopeo -y
skopeo list-tags docker://quay.io/centos/centos | less ## tag목록이 자세하게 출력
podman pull centos/centos:stream9
```
