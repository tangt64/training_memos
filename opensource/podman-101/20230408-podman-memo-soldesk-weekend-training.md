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

<pre>
docker-ee: RestAPI
-> 확장성은 매우 낮음
podman: podman.server, RestAPI
-> 확장성은 낮음
kubernetes: kubelet, kube-apiserver, RestAPI
-> 확장성이 큼
</pre>

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

```
podman run -it --rm -p 호스트:컨테이너 --name     bash 
podman run -it --rm -p 9090:8080 --name hello-nginx quay.io/redhattraining/hello-world-nginx bash
podman run -d -p 9090:8080 --name hello-nginx-2 quay.io/redhattraining/hello-world-nginx
```

1. nginx(quay.io/redhattraining/hello-world-nginx)기반으로 컨테이너 생성
  - 컨테이너 이름은 hello-nginx
2. 8080포트는 호스트 9090으로 접근이 가능
3. 웹 페이지 내용을 변경
  - hello nginx
  - /usr/share/nginx/html/index.html
4. find으로 파일 위치 확인(index.html)
5. iptables-save, podman port로 아이피 및 포트 번호 일치 확인
6. ip netns exec, bridge로 아이피 및 장치 조회

```bash
podman run -d -p 9090:8080 --name hello-nginx-2 quay.io/redhattraining/hello-world-nginx
curl localhost:9090
podman container port hello-world-ngninx
iptables-save | grep 9090
podman run -d --rm -p 8080:80 --name my-httpd-app quay.io/centos/centos:stream8 sleep 100000
```


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
podman search --list-tags centos/centos                ## tag목록이 출력이 되나, 자세하지는 않음
dnf install skopeo -y
skopeo list-tags docker://quay.io/centos/centos | less ## tag목록이 자세하게 출력
podman pull centos/centos:stream9
```

```bash
podman run -it --rm --name test-centos-stream-9 centos:stream9 /bin/bash
-> dnf search httpd
-> dnf install httpd -y
podman commit test-centos-stream-9 commit-test-centos-stream-9    ## 실행중인 컨테이너를 이미지화
podman save quay.io/centos/centos:stream9 -o stream9.tar          ## 컨테이너 이미지를 파일로 저장
podman save localhost/commit-test-centos-stream-9 -o modified-stream9.tar  ## 컨테이너 이미지를 파일로 저장
ls
anaconda-ks.cfg  modified-stream9.tar  stream9.tar
mkdir original
mkdir modified
tar xf modified-stream9.tar -C modified/
tar xf stream9.tar -C original/
ls -l modified/
ls -l original/

podman diff test-centos-stream-9 quay.io/centos/centos:stream9    ## 런타임이 이미지 diff 디렉터리를 확인 함.
```

OSTree: https://ostree.readthedocs.io/en/stable/

RedHat Podman Ebook: 141page

__Dockerfile:__ Docker 이미지 빌드를 도와주는 명령어(instruction) 셋(set) 파일. 구성할 내용들을 쭉 적어둠. 참고로 Dockerfile은 OCI에서 지원은 하나, 표준은 아님.

__Containerfile:__: OCI 이미지 빌드 도구 명령어. 앞으로 모든 컨테이너 이미지는 Containerfile기반으로 구성이 됨. Dockerfile과 서로 호환은 되나, 사용방법이 조금은 다름. 앞으로는 이 이름으로 이미지 빌드 파일 생성.

이미지 빌드 시 사용하는 도구는 __podman build__, __buildah bud__ 명령어 사용이 가능. 이미지 빌드시 권장은 buildah를 사용. 

```yaml
FROM centos
FROM ubi-init   
```

만약, 베이스 이미지에 '-init'라고 표시가 되어 있으면, 컨테이너에서 systemd, init사용이 가능함. 
본래 컨테이너에서 System V init, systemD사용이 불가능.


```bash
cd
nano Container-httpd
->FROM ubi8-init
->RUN dnf -y install httpd; dnf -y clean all
->RUN systemctl enable httpd.service
ln -s Container-httpd Dockerfile
podman build .
rm -f Dockfile
ln -s Container-httpd Containerfile
podman build .
dnf install buildah -y
buildah images                ## /var/lib/containers/storage/
buildah bud -f Container-httpd
```


```Containerfile
FROM ubi8-init
RUN dnf -y install httpd; dnf -y clean all
RUN systemctl enable httpd.service
_EOF
```

## Low/High level image build tool

### Podman
고수준 이미지 빌드 도구
- Dockerfile
- Containerfile

### Buildah
저수준 이미지 빌드 도구
- Dockerfile
- Containerfile
- "scratch", 이미지를 처음부터 빌드가 가능.


buildah 이미지 빌드 관련 정보
-----

[이미지 처음부터 빌드](https://buildah.io/blogs/2017/11/02/getting-started-with-buildah.html#building-a-container-from-scratch)

[이미지 크기, 왜 이미지가 docker 이미지보다 크게 보이는가?](https://github.com/containers/buildah/issues/532)



```bash
newcontainer=$(buildah from scratch)
echo $newcontainer     # scratch-3
buildah ps == buildah containers
buildah rm <ID>                               ## 필요 없는거 제거
buildah images
scratchmnt=$(buildah mount $newcontainer)  
echo $scratchmnt
ls /var/lib/containers/storage/overlay/1cf801765945a490af5316a7c77b47f87ebdb3184260692cce6f6328fe5d88cb/merged  ## 현재 컨테이너는 비어 있음. 그래서 bash가 실행이 안됨

dnf install --installroot $scratchmnt --setopt=tsflags=nodocs --setopt=override_install_langs=en_US.utf8 --setopt install_weak_deps=false -y --releasever=9 bash 
buildah run $newcontainer /bin/bash microdnf coreutils-single          ## bash가 동작
buildah run $newcontainer /bin/bash
-> ls
-> exit

# buildah config --cmd  /usr/bin/runecho.sh      ## 컨테이너 메타정보 생성, podman inspect, docker inspect 
buildah config --created-by "Tang"  $newcontainer
buildah config --author "CHOIGOOKHYUN at linux.com @tang" --label name=centos-9-stream $newcontainer
buildah inspect $newcontainer
buildah unmount $newcontainer
buildah commit $newcontainer choi-centos-9-stream-cus
buildah images
```


## share/unshare
unshare: Run a command inside of a modified user namespace
         -> 명령어 혹은 프로그램을 사용자 네임스페이스에서 실행

scratch(완벽하게 명령어 구현은 아님)

```bash
mkdir -p /scratch
chown 1000.1000 /scratch
unshare -S 1000 -G 1000 -w /scratch  ## bash 프로세스의 작업 디렉터리가 임의로 "/scratch/"로 변경
```

          .---> mount --bind /var/lib/containers/storage/overlay/<DIR>    ## USER
         /      mount --make-private <DIR>                                ## NAMESPACE
        /       touch /var/lib/containers/storage/overlay/scratch
       /        unshare --mount=/var/lib/containers/storage/overlay/scratch   ## buildah mount
--------------------
buildah from scratch == NAMESPACE(scratch(unshare(MOUNT((/VAR/LIB/CONTAINERS/STORAGE/OVERLAY))))
                                  ------- -------
                                  \        \
                                   \        \
                                    \        '---> syscall(function)
                                     '---> function
```bash
man -k unshare
man 1 unshare

adduser test1
echo centos | passwd --stdin test1
ssh test1@localhost
```
keywords
---------

1. namespace
2. unshare


# day 3번째 

## 주제
- 컨테이너 볼륨 생성 및 바인딩의 차이점 
- 쿠버네티스 런타임 살펴보기
  * crio
  * containerd
  * 무엇이 다른지??
- 쿠버네티스 설치
  * kubeadm init 
  * https://github.com/tangt64/training_memos/blob/main/opensource/kubernetes-101/command-collection.md


## 머여 backingFsBlockDev?!

- containers/storage/overlay
- volume/<ID>/backingFsBlockDev

컨테이너 내부에 접근을 하면..  

```
overlay         73364480 6772588  66591892  10% /
------
\
 `---> /var/lib/containers/storage/overlay ---> devicemapper(fuse)
```
"backingFSBlockDev", 컨테이너는 원칙상 블록장치를 가져갈수가 없어, backingFSBlockDev를 통해서, 마치 컨테이너가 블록장치를 가지고 있는것 처럼, 예뮬레이팅 함.


## 볼륨 및 바인딩 확인

--volumes-from: "podman volumes ls"에서 나오는 블록 장치를 연결. 런타임 엔진에서 가지고 있는 디렉터리는 연결.
--volume: 호스트 디렉터리를 바로 컨테이너로 마운트. 컨테이너가 시작 시, 런타임(일시적으로)으로 디렉터리 연결

쿠버네티스에서는 "pv(persistent volume)",            "pvc(persistent volume claim)"
                ----------------------              -----------------------------
                호스트 쪽에서 제공하는 논리 드라이버   요청 혹은 요구하는(Pod)
```bash
podman run -d -v <HOST>:<CONTAINER>
                 -----  -----------
                  \         /
                   `-------'
                   '

podman run --help
man podman-run                  
getenforce

## SELinux 동작중이면, Z로 해서 컨텍스트 올바르게 변경
podman run -d -v <VOLUME_NAME>:/var/www/html:Z --name test-volume centos /bin/sleep 10000  ## it's okay
podman run -d -v <HOST_DIR>/:/var/www/html:Z --name test-volume centos /bin/sleep 10000    ## it's problem.

podman exec -it <NAME> /bin/bash
>df
/dev/mapper/cs_podman-root  73364480 6772592  66591888  10% /var/www/html    ## bind, volume
     ------
     device mapper(DM)
>mount     

podman insepct <ID>
>Volume: rw,rprivate,nosuid,nodev,rbind
>Bind: rw,rprivate,rbind,

```

### podman volume

```bash
man podman-volume
podman volume create test-volume   ## 이름이 없으면 UUID마음대로 생성함
                                   ## 기본 드라이버는 local

## https://github.com/containers/podman/blob/main/vendor/github.com/containers/storage/storage.conf                                  
## CSI: Container Storage interface
```

### volume import/export

```bash
mkdir htdocs/
echo "hello this is volume httpd container server" > htdocs/index.html
tar cf volume-htdocs-index.tar htdocs/index.html
podman volume import test-volume volume-htdocs-index.tar
podman volume volume export test-volume > volume-htdocs-index-rev1.tar
```

### 작은 연습

1. test-httpd-volume
2. 연결할 볼륨의 이름 htdocs-files 생성
  - /var/lib/containers/storage/volumes/
  - podman inspect test-httpd-volume
  - ls
3. 웹 서버를 설치
4. 연결 및 포트 할당 80포트를 8080으로
5. index.html에는 "Hello Volume"출력

```bash
skopeo list-tags     ## centos-8-stream, 9-stream
echo "Hello Volume" > index.html
podman volume create htdocs-files
podman volume import htdocs-files index.tar
podman run -d -p8080:80 --name test-httpd-volume centos sleep 10000
podman exec -it test-httpd-volume dnf install httpd -y
curl localhost
```

위의 내용을 Containerfile로 변환
```yaml
# skopeo list-tags  docker://quay.io/centos/cetnos
                    docker://httpd
# nano Containerfile
FROM <BASE_IMAGE>       ## 1. centos, httpd
RUN dnf -y install httpd; dnf -y clean all
VOLUME /var/www/html
EXPOSE 80
CMD ['/usr/sbin/httpd', '-DFORGROUND']
```

```yaml
FROM centos:stream9
RUN dnf -y install httpd; dnf -y clean all
VOLUME /var/www/html         ## podman -v <VOLUME_NAME>:<CONTAINER_PATH>
                             ## docker -v source=,target=
EXPOSE 80
#CMD /usr/sbin/httpd -DFOREGROUND
#CMD ["/usr/sbin/httpd","-DFOREGROUND"]
#CMD ["/usr/sbin/httpd", "-DFOREGROUND"]`
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]

# ENTRYPOINT ["/usr/bin/httpd"]
# CMD ["-DFOREGROUND"]

# ENTRYPOINT + CMD
```

```bash
podman build -f Containerfile-volume -t localhost/test-httpd-volume:lastest
podman images | grep localhost
```

## podman + kube play

```bash
podman genereate kube <CONTAINER> --filename <YAML_NAME> --service
podman kube play <YAML_FILENAME>
podman kube down <YAML_FILENAME>
```

## docker/crio repository


[containerd](https://docs.docker.com/engine/install/fedora/#set-up-the-repository)

```bash
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
vi /etc/yum.repos.d/docker-ce.repo
fedora ---> centos 
%s/fedora/centos/g
sed -i "%s/fedora/centos/g" docker-ce.repo
dnf search containerd
dnf install containerd

dnf remove podman-docker
dnf install docker-ce        
systemctl start docker  
systemctl is-active docker
          status
systemctl is-active containerd
          status
systemctl is-active podman          
```
```text
docker     <--- API <--- CLI(docker)
  \
   `---> dockerd  <--- fd://<SOCKET>
           \
            `---> containerd
rpm -qa  containerd.io
>/etc/containerd/config.toml      ## TOML초기화 필요

ctr containers ls
ctr image ls
containerd config default > /etc/containerd/config.toml 
systemctl stop docker
systemctl restart containerd

wget -O /etc/yum.repos.d/libcontainers.repo https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/libcontainers.repo
wget -O /etc/yum.repos.d/stable_crio.repo https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/stable_crio.repo

dnf install cri-o -y
systemctl enable --now crio
systemctl start crio


ctr images =/= podman images == crictl images     ## OCI 표준 이미지 디렉터리
crictl ps     =/= podman ps       ## 엔진이 다르게 정보를 관리함
```


1. podman(지원,k8s 사용불가)
2. docker(표준미지원,k8s 사용불가))
3. containerd(호환, 어뎁터를 통한 지원)
4. crio(지원)
5. cri-docker(지원,mirantis-container)


## FOR 경민님 :)

```bash
swapoff -a
swapon -s
nano /etc/containers/policy.json
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
kubeadm reset --force
kubeadm init


```

## crio

```bash
systemctl stop firewalld && systemctl disable firewalld
dnf install iproute-tc -y ## centos-9-stream

sed -i 's/enforcing/permissive/g' /etc/selinux/config
setenforce 0

vi /etc/fstab
# 스왑 라인 주석처리
# swap
swapoff -a
swapon -s

hostnamectl set-hostname master.example.com
hostnamectl
cat <<EOF>> /etc/hosts
<SERVER_IP_ETH0> master.example.com master        
EOF
ping -c2 master.example.com

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

systemctl status kubelet
systemctl enable --now kubelet

dnf install wget -y
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/libcontainers.repo -O /etc/yum.repos.d/libcontainers.repo
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/stable_crio.repo -O /etc/yum.repos.d/stable_crio.repo
dnf install cri-o -y
systemctl enable --now crio
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/policy.json -O /etc/containers/policy.json

modprobe br_netfilter    ## bridge for iptables or nftables, L2/L3
modprobe overlay         ## cotainer image for UFS(overlay2), Disk(UFS)
cat <<EOF> /etc/modules-load.d/k8s-modules.conf
br_netfilter
overlay
EOF

cat <<EOF> /etc/sysctl.d/k8s-mod.conf
net.bridge.bridge-nf-call-iptables=1    
net.ipv4.ip_forward=1                   
EOF
sysctl --system                           ## 재부팅 없이 커널 파라메타 수정하기

kubeadm init phase preflight 
kubeadm init

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes


crictl ps
```
podman ---> kube play ---> containerd ---> crio = {kubernetes}
                              CNCF

## containerd

```bash
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=10250/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-port

containerd config default > /etc/containerd/config.toml && systemctl restart containerd
vi /etc/containerd/config.toml
>disabled_plugins = [] ---> # disabled_plugins = []
>enabled_plugins = ["cri"]  ## CRI 인터페이스와 호환, 이것만!!
>[plugins."io.containerd.grpc.v1.cri".containerd]
>  endpoint = "unix:///var/run/containerd/containerd.sock"
>root = "/var/lib/containers"
systemctl restart containerd 

ctr containers ls

swapoff -a
swapon -s
kubeadm init phase preflight 
cat /etc/hosts
ip a s eth0
cat <<EOF>> /etc/hosts
172.22.224.169 podman.example.com podman             ## Bind9서버나 혹은 Dnsmasq로 DNS서비스 구성(A Recode)
EOF

-----김민정님-----
cat <<EOF>> /etc/hosts
172.20.0.244 master.example.com podman
EOF

ping -c2 master.example.com
-----------------

dnf install bind-utils -y
host podman.example.com
kubeadm init phase preflight 
systemctl enable --now kubelet ## systemctl restart kubelet
kubeadm config images pull

modprobe br_netfilter    ## bridge for iptables or nftables, L2/L3+L4
modprobe overlay         ## cotainer image for UFS(overlay2), Disk(UFS)
cat <<EOF> /etc/modules-load.d/k8s-modules.conf
br_netfilter
overlay
EOF

cat <<EOF> /etc/sysctl.d/k8s-mod.conf
net.bridge.bridge-nf-call-iptables=1    ## container ---> link ---> tap ---> bridge
net.ipv4.ip_forward=1                   ## pod <---> svc
EOF
sysctl --system

kubeadm init    ## init가 실패한 경우 다시 kubeadm reset --force
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes

journalctl -fl -u kubelet -perr -p warning   ## 시스템 로그에서 런타임 엔진 오류 확인
journalctl -fl -u containerd -perr -p warning

systemctl status kubelet
systemctl status containerd
kubeadm ---> 컨테이너 이미지 기반의 쿠버네티스 서비스 <--- kubelet(컨테이너 기반의 쿠버네티스 서비스 구성, 일종의 프록시 서버)

systemctl status kubelet

ps -ef | grep conmon
```


# day 4

__master:__ 2 NICs
__하이퍼바이저:__ 추가 네트워크 구성 꼭 해주세요!!

eth0: external, 외부에서 필요한 패키지 혹은 이미지
eth1: internal <---> internal, 노드 통신

eth0: DHCP, IP Fixed No!! 
eth1: STATIC, IP fixed!!, POD 네트워크 구성을 위해서 고정이 필요.


PoC
------
master x 3, NIC x 2
node x 2, NIC x 2

infra_node{storageroute}

```bash
ip link
> eth0
> eth1


## 명령어
nmcli con add con-name eth1 ipv4.addresses 192.168.10.1/24 ifname eth1 type ethernet ipv4.method static
nmcli con down eth1
nmcli con up eth1
## TUI
nmtui
> eth1                    ## 고정 아이피 192.168.10.1/24 설정
                          ## 게이트웨이 사용하지 않음(랩에서만!!!)
+----------------------------+
| IPv4 CONFIGURATION: MANUAL                            |
| Addresses 192.168.10.1/24                             |
| Gateway        없음                                   |
| DNS servers    없음                                   |
| Search domains 없음                                   |
+-------------------------------------------------------+
| │ | [X] Never use this network for default route      |
| │ | [X] Ignore automatically obtained routes          |
| │ | [X] Ignore automatically obtained DNS parameters  |
+-------------------------------------------------------+
| Activate a connection                                 |
+-------------------------------------------------------+
> eth1만 다시 재적용!!

ip a s eth0  
ip a s eth1               ## 고정 API인터페이스 + POD네트워크

kubeadm reset --force
kubeadm init <OPT>        ## API 서버가 바라볼 인터페이스 설정          
```

```bash
kubeadm init --help
kubeadm --apiserver-advertise-address <IP_ADDRESS>     ## kubectl eth0 ---> eth1
                                      192.168.10.1     ## pod network     
                                                       ## eth0는 외부에서 서비스 접근
                                                       ## eth1는 내부에서 서비스 관 리
        --image-repository                             ## 쿠버네티스 이미지 내려받기 주소
        --kubernetes-version                           ##  
        --node-name <NODE_NAME>                        ## 
        --service-cidr 10.96.0.0/12
        --service-dns-domain cluster.local             ## cgh.local

kubeadm init --apiserver-advertise-address 192.168.10.1 --pod-network-cidr 192.168.0.0/16 --service-dns-domain cgh.local

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/calico-quay-crd.yaml

kubectl get pods -wA   ## -w: wait, 갱신되면 화면에 출력, -A: 모든 네임스페이스 Pod출력
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes
kubectl get pods -A

0/1     Init:1/2     ## 이건 정상 
                     ## selinux, firewalld, pod network issue

journalctl -fl
kubectl describe pod -n calico-system <POD>
kubectl logs -n calico-system <POD>
```  


```bash
@master]# kubeadm token create --print-join-command
@node1]# kubeadm join 192.168.10.1:6443 --token ph550v.mkmgptvx62wqs2du --discovery-token-ca-cert-hash sha256:3a27e75663ed35d94013e90bbec36c24cc57023708375a21eabbe529b9b00c69


## 노드1번에 kubeadm 명령어를 사용할 수 있도록 구성
## 구성이 완료가 되면, join 명령어로 클러스터에 노드 추가
## 완료가 되시면 마스터/노드 다시 리셋 후 재구성
```

## 터널링 네트워크 구성

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/calico-quay-crd.yaml
kubectl get pods -wA   ## -w: wait, 갱신되면 화면에 출력, -A: 모든 네임스페이스 Pod출력
```


## 명령어 모음(노드 및 마스터(컨트롤) 공통 사항)

### 공통 설정

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

### kubeadm join(single)

```bash
@master]# KUBECONFIG=/etc/kubernetes/admin.conf kubeadm token create --print-join-command
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


수정된 podman YAML

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: centos-apache-pod-srv-port
  name: centos-apache-pod-srv-port
spec:
  ports:
  - name: "centos-apache-srv-port"
    nodePort: 31033
    port: 80
    targetPort: 80
  selector:
    app: centos-apache-pod-deploy
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: centos-apache-pod-deploy
  name: centos-apache-pod-deploy

spec:
  replicas: 1
  selector:
    matchLabels:
      app: centos-apache-pod-deploy
  template:
    metadata:
      labels:
        app: centos-apache-pod-deploy
    spec:
      containers:
      - image: quay.io/redhattraining/httpd-parent:latest
        name: centos-apache
        ports:
        - containerPort: 80
```

```bash
kubectl delete svc centos-apache-pod-srv-port
kubectl create -f centos-apache-deploy.yaml
kubectl get svc
kubectl get pod
kubectl get deploy
```

## 쿠버네티스 쉽게 접근하기


```bash
dnf search fish
dnf install epel-release
dnf install fish -y
```

개인적으로 "fish"를 좀 더 선호 합니다. 


```bash
rpm -qa bash-completion
complete -rp
kubeadm completion bash > k8s-completion.sh
kubeadm completion fish > k8s-completion.sh

kubectl completion bash > k8s-completion.sh
kubectl completion fish > k8s-completion.sh

kubectl completion fish > ~/.config/fish/completions/kubectl.fish

source k8s-completion.sh
complete -rp
```

## 명령어 및 쿠버네티스 서비스 설명


podman pod ls == crictl pods
podman container ls == crict ps

## 간단한 구성 설명 및 명령어 


쿠버네티스 클러스터의 기본값은 __"kubernetes"__ 일반적으로 프로젝트의 이름

설치시 변경하려면 YAML기반으로 설치하는 경우, 설치시 변경이 가능. 

클러스터 이름을 확인 및 변경하기 위해서는 다음과 같은 명령어로 확인이 가능함.

```bash
kubeadm config print init-defaults | grep cluster
kubectl config view
```

혹은, 설치후에 /etc/kubernetes/admin.conf에서도 간단하게 확인이 가능.

```bash
grep kubernetes /etc/kubernetes/admin.conf
  name: kubernetes
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
- name: kubernetes-admin
```

kubectl명령어는 사용자를 생성 및 설정하지 않으면, "kubernetes-admin"으로 클러스터 접근해서 사용. 명령어는 다음과 같이 동작한다. 'kubeadm'의 기본값

```bash
kubectl {kubernetes-admin@kubernetes+TLS} get pods
```

kubectl 명령어 사용방법은 아래 주소를 참조한다.

[명령어 레퍼런스](https://kubernetes.io/docs/reference/kubectl/)

자주 사용하는 명령어는 보통 아래와 같다.

```
kubectl get po     ## Pod 목록 확인
kubectl get svc    ## 서비스 목록 확인(아이피 및 포트)
kubectl get dep    ## 컨테이너 구성설정 목록 확인
```

컨테이너 및 Pod는 동일한 컨테이너이지만, 자원 성격 및 구성이 다름. 
- POD + Container, POD는 POD 아이피를 가지고 있고, 컨테이너는 루프백 장치로 POD에 구성 및 연결.
- container는 서비스 애플리케이션을 가지고 있음.
- 쿠버네티스에서 사용하는 기본 Pod 애플리케이션은 Pause를 사용하고 있음.

```bash
crictl images
```

kubectl get pod
- Pod 애플리케이션으로 컨테이너 격리
- 컨테이너 애플리케이션으로 직접적으로 접근을 할 수 없음


kubectl get svc(service)
- iptables, nftables하고 관계가 있음.
- pod는 svc하고 연결이 됨.

```bash
kubectl describe service <NAME>
Endpoints:                192.168.11.66:80   ## POD 아이피
IP:                       10.97.36.205       ## NAT 아이피

iptables-save | grep 10.97.36.205
```

create apply


kubectl describe svc <객체>
                 pod <객체>


get: 자원 목록
describe: 자원 구성 내용 확인


### 네임스페이스 생성 및 제거

```bash
kubectl create namespace <NAME>
kubectl get ns | namespaces
kubectl delete namesapce <NAME>
kubectl run --image quay.io/redhattraining/httpd-parent:latest <POD_NAME> -n <NAMESPACE_NAME>

## 같은 네임스페이스에서는 같은 리소스에 같은 이름으로 생성이 안됨!!
kubectl run --image quay.io/redhattraining/httpd-parent:latest test -n test1
kubectl run --image quay.io/redhattraining/httpd-parent:latest test -n test1

## 다른 네임스페이스에서는 같은 이름에 자원을 생성이 가능
kubectl run --image quay.io/redhattraining/httpd-parent:latest test -n test1
kubectl run --image quay.io/redhattraining/httpd-parent:latest test -n test2

kubectl delete namespace test2                         ## 내부에 있는 자원도 한번에 제거
```

### 네임스페이스 고정적으로 변경하기

```bash
kubectl config get-context
kubectl create namespace main-project
kubectl config set-context --current --namespace main-project
kubectl config get-context
kubectl run --image quay.io/redhattraining/httpd-parent:latest test
kubectl get pods -owide
kubectl get pods -A
```

# DAY 4 :(

쿠버네티스에서는 제일 중요한것은 "자원 설정"
- 여러 애플리케이션을 한번 배포 및 유지 관리 하는게 주요 목적
- podman 혹은 런타임 기반으로 서비스 구성
  * CRI런타임 기준으로
  * 쿠버네티스가 런타임, 즉 컨테이너를 생성하지 않음.
- 미들웨어와 같은 플랫폼 애플리케이션
- 엔지니어 혹은 개발자에게 다음과 같은 기술을 요구
  * 리눅스 관련 명령어 혹은 지식을 요구
  * 런타임 관련 지식
  * 스토리지 및 네트워크 
  * SRE수준의 기술 요구 ---> Dev/Ops(한국은 아직..ㅠㅠ)
- 명령어가 중요한게 아니라, 이 개념이 어떤식으로 동작하는지
- 설명이 가능한 엔지니어
  * 설명이 안되면 SRE가 안됨.
  * 다이어그램 혹은 그림으로 어느정도 스스로 증명


## run 명령어

Pod를 실행.(Pod(container))

```bash
kubectl run hello-nginx --image=quay.io/redhattraining/hello-world-nginx:latest                   ## 실제 생성
kubectl run hello-nginx --image=quay.io/redhattraining/hello-world-nginx:latest --dry-run=client  ## 실행이 되는지 확인
kubectl run hello-nginx --image=quay.io/redhattraining/hello-world-nginx:latest --dry-run=client -oyaml > hello-world-nginx.yaml  ## 실제로 생성하지 않고 YAML으로 생성 및 구성
```

## create, apply + replace
create: Pod를 만들기(생성), 일회성으로 자원 생성(YAML기반)
  - apply를 추후에 적용하는 경우, annotation(메모)가 빠져있기 때문에 추가 후, 다시 변경 내용 적용.
apply: Pod를 적용
  - apply가 된 경우에는, 변경 내용(선언자)에 대해서 확인 및 추적이 가능
replace: 기존에 사용하였던 자원을 다른 내용으로 갱신할때 사용한다.
  - kubectl replace -f <FILE> 

```bash
kubectl create namespace applycreate
kubectl get ns
kubectl create -f hello-world-nginx.yaml -n applycreate
kubectl get po -n applycreate
```

## describe
etcd에 있는 내용을 사용작 보기 편하게 렌더링

```bash
kubectl describe pod hello-nginx -n applycreate
```

## edit
ETCD에 있는 내용을 실시간으로 편집

```bash
kubectl edit pod hello-nginx -n applycreate
```

## pod delete

```bash
kubectl get pods 
kubectl delete po --all -n applycreate 
kubectl delete -f <YAML> -n applycreate
```

##  replace 

YAML로 작성되어 있는 자원의 내용을 업데이트.

```bash
kubectl replace -f <DEPLOYMENT_YAML>
```

## deployment

구성설정을 관리하는 영역

```bash
kubectl get deploy
nano nginx.yaml
---
- apiVersion: apps/v1

kubectl create deployment nginx --image=nginx --dry-run=client -oyaml > nginx.yaml
kubectl create -f nginx.yaml         ## 이전에 사용하였던 rs, revision #1
nano nginx.yaml
    image: nginx ---> quay.io/redhattraining/hello-world-nginx:latest
kubectl replace -f nginx.yaml        ## 현재 사용중인 rs, revision #2
kubectl get pods
kubectl describe pod nginx-<ID>
kubectl describe deploy nginx

```


## config set-context 

말 그대로 문맥 ~/.kube/config 혹은 /etc/kubernetes/admin.conf파일에서 네임스페이스 값 수정

```bash
cp /etc/kubernetes/admin.conf ~/.kube/config
unset KUBECONFIG
echo $KUBECONFIG
kubectl get nodes
kubectl config get-contexts          ## 현재 사용자가 사용중인 네임스페이스 확인
grep -A5 -i context ~/.kube/config   ## 컨텍스트=사용자+네임스페이스+클러스터
kubectl config set-context --namespace applycreate --current    ## 기존 내용에서 네임스페이스만 변경
                                                                ## kubectl는 다중 클러스터 접근 가능
```



Deployment ---> ReplicaSet  ---> POD
[volume]        [pod_count]      pod x <COUNT>
[container]     [container]
[pod]           [pod]
[limit/quota]


## 네임스페이스

default: 기본 프로젝트 혹은 네임스페이스
kube-system: 주요 쿠버네티스 서비스가 동작하는 영역
kube-public(openshift): 공유 쿠버네티스 자원


1. 구축 테스트 할때는 명령어로 만들어도 괜찮음.
2. 실 구축에 들어 갈때는 네임스페이스도 YAML기반으로 생성.

```bash
kubectl create namespace threenamespace --dry-run=client -oyaml   ## YAML파일로 생성
kubectl create -f <YAML_NAME>
kubectl create namespace threenamespace


kubectl get pod -n <NAMESPACE>
kubectl get pod -A 
kubectl get all -A
kubectl delete all -A
```


## apply/create



```bash
kubectl create deploy public-vsftpd --image vsftpd --port=21 --dry-run=client --namespace=first-namespace -o yaml
```

## cp + volume binding + debug + exec

cp로 복사해서 파일을 컨테이너에 밀어 넣으면, 특정 호스트에 "/var/lib/containers/storage/overlay"에 복사하는거와 똑같음. kubelet에 사용자가 보낸 파일을 전달 받아서 특정 노드에 저장.


컨테이너 디스크는 실제로 존재하지 않고, 일반적으로 디렉터리 형태로 오버레이 장치로 구성.


### 신방식(권장)

컨테이너 프로세스가 출력하는 메시지 확인
```bash
kubectl log <PODNAME>   ## 표준 오류 및 출력내용
## kubectl exec -it 직접 접근. 하지만, debug는 간접으로 접근.
kubectl debug -it hello-httpd-5f49689664-rwgxd --image=busybox --target=hello-httpd
```


### 구형방식
```bash
kubectl exec -it <PODNAME>
# -i: interactive
# -t: tty(가짜)
kubectl cp <FILE> <POD> 
# ssh root@<NODE1>
node1@ find / -name findme.html -type f -print 
```


### SVC

```bash

@node1#] iptables-save | grep SEP  ---> nft list table filter

                  # kubectl get po
                   [SEP]       # kubectl get ep
                  +-----+     +-----+
| container | --- | POD | --- | SVC | -------------- (USER)
                  +-----+     +-----+   # watch -n1 curl
                    | POD |    [L/B]
                    +-----+
                     | POD |
                     +-----+
                      | POD | RS=4
                      +-----+
```

## debug + shareprocess(PID 1)

1. 격리 역할
2. 네임스페이스 자원(ls -l /proc/self/ns)
3. PID 1(dummy init, dumb init)
  - 컨테이너 전용 init가 있음

```bash

Debugger Container + POD 1 + Container 2

systemd <-> PID 1(POD(pause == infra container)

+ shareProcessNamespace: true

+-----------+
| container |  ---.
+-----------+      \      +-----+
 [prg1]             > --- | POD |
+-----------+      /      +-----+
| container |  ---'
+-----------+
 [prg2]

```
- binding 타입은 아님
```bash

                                             # mount -obind  <DIR> ---> <DIR> 바인딩
                                            .---> NODE:/run/containers, /var/lib/containers(rbind,rprivate)
                                           /
                                         [host]         [container]
podman run --name test-container -v /opt/storage/www/:/var/www/html/     ## 다시 연결 하려면 re-create
                                 ----
                                 PVC(host에서 제공)
```
Persistent Storage: 고정(static)  ---> PVC == volume
Storage Class: 정적(dynamic)      ---> PVC == volume


```bash
# docker volume, podman volume ---> pv, pvc같은 역할
# podman -v /etc/hosts:/etc/hosts   ## 변경이 불가능
# podman volume create test
# podman volume ls      
# local(driver)                     ## PV
# podman -v test:/etc/hosts         ## 변경이 가    

# crictl ps 
          "destination": "/run/secrets",    ## kubectl get secret, 컨테이너가 생성 시 전달(ETCD)
          "type": "bind",
          "source": "/run/containers/storage/overlay-containers/fa2a2872e196c414079ecaeb91df736c6313146078d140a8d4c5673b417ebbd5/userdata/run/secrets",
          "options": [
            "bind",
            "rprivate",
            "bind"
          ]
        },
```


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  shareProcessNamespace: true
  containers:
  - name: nginx
    image: nginx
  - name: shell
    image: busybox:1.28
    securityContext:
      capabilities:
        add:
        - SYS_PTRACE
    stdin: true
    tty: true
```


## 동향


- openstack(IaaS)
- kubernetes + kube-virt(PaaS)


+ ONOS
+ OpenDaylight(ODL)
  - OLD 5G
  - NFV


* OS-Tree
* systemd
  - crontab, rsyslog, at, logrotate, iptables, network-script, firewalld, NetworkManager
  - Linux Bridge ---> OVS
  - journalctl
  - hostnamectl, timedatectl
  - /etc/resolve.conf ---> systemd에 관리(아마존 리눅스)
* XFS, btrfs
* KERNEL(Module) ---> systemd 
* dbus/udev
