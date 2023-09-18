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
```

kubeadm ---> 컨테이너 이미지 기반의 쿠버네티스 서비스 <--- kubelet(컨테이너 기반의 쿠버네티스 서비스 구성, 일종의 프록시 서버)


systemctl status kubelet

ps -ef | grep conmon
