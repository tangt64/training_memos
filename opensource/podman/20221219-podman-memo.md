# day 1

## 가상머신 웹 대시보드
<https://con.dustbox.kr>

(화이트보드)[https://wbd.ms/share/v2/aHR0cHM6Ly93aGl0ZWJvYXJkLm1pY3Jvc29mdC5jb20vYXBpL3YxLjAvd2hpdGVib2FyZHMvcmVkZWVtLzA3MmRkNDAxZTA0ZjQ1ODhhN2RiMTU0YTM2YWIyMjI0X0JCQTcxNzYyLTEyRTAtNDJFMS1CMzI0LTVCMTMxRjQyNEUzRF85N2QyODU5YS0xZWQ3LTQ1YTQtYmNlMi0wOTk3NjE5ZWJhNzE=]

## 게이트웨이 터미널 서버
<ssh://console.dustbox.kr>

"putty", 혹은 "powershell"로 접근 가능

아이디는 **"container1~29"**번
비밀번호는 **"container"**으로 공통

교재 관련된 주소는 http://github.com/tangt64/training_memos/
                                                          opensource/podman

"Podman-in-Action-ebook-MEAP-Red-Hat-Developer-All-Chapters.pdf"
https://www.informit.com/articles/article.aspx?p=29961&seqNum=2

https://people.redhat.com/~jupittma/cheatsheets/podman.html

google: people redhat jupittma

## podman vs docker

OCI: Open Container initiative, (https://opencontainers.org/)
     컨테이너 런타임 사양을 지정 및 배포
     format: 컨테이너 이미지
     runtime: 컨테이너 실행(containerd, crio, podman, ~~lxc~~ )

kubernetes runtime:
  - containerd(standalone, k8s engine)
  - crio(k8s에서는 crio가 표준)

0. Podman
  - docker의 오픈소스 대안.
  - io.podman, podman.service daemon, API를 제공.
  - 기존 도커와 호환성 유지.
    * docker-compose
    * docker-build
    * volume
    * network
  - OCI, CRI, CSI, CNI전부 다 지원.
  - kubernetes에서는 사용이 불가능함.      
  - kubernetes에서 지원하는 기능들을 자체적으로 구현함.
  - POD, YAML형식도 지원.

1. docker
  - docker CE/EE는 같은 구성원으로 되어 있음.
  - docker-swarm 같은 기능이 내장이 되어 있음.
  - docker는 shim라는 구조를 사용함. 
  - docker --> dockerd --> containerd --> CRI구조를 현재 사용중.
  - docker에서는 컨테이너 및 POD분리가 안됨.
  - 제한적인 네트워크 기능 제공 및 확장(CNI, Container Network Interface)
  - 제한적인 스토리지 기능 제공 및 확장(CSI, Container Storage Interface)
  - 현재 도커에서 사용하는 이미지는 컨테이너 표준 이미지로 지정(OCI 이미지)
  - 도커 명령어는 거의 대다수 런타임(runtime)에서 표준으로 사용함

현재 도커는 미란티스라는 회사로 인수가 되고, 개발 및 유지보수가 중지. docker-cri기반으로 개발중.


## podman/kubernets/crio

표준적으로 리눅스에서 가상화는 "qemu/kvm".
**qemu**: 예뮬레이터(vcpu, vmem, vdisk, vnet, bios, pci..)
**kvm**: CPU 가속기


```bash
       <ovirt>           <kubernetes>      
                              | 
-----------[middleware]------ | -
[USER]                        |
                     +--------+----+
        <QEMU>       |OCI Spec     |
        <PODMAN>     +-------------+
                     |<cri-o>      | 
                     |<contaierd>  |
                     +--------+----+
-----------[systemd]--------- | -
               \              |
[KERNEL]        \     +-------+--+
        kvm.ko   \    |namespace |
          |       `---|cgroup    |
          |           |seccomp   |
      <hardware>      +----------+
```
### 가상화

scale-up, 최대한 일반 호스트 서버와 동일하게 동작 혹은 워크로드 처리.

**qemu**:
vcpu, vmem, vdisk를 관리하기 때문에... 
언제든지 cpu, mem, disk, nic와 같은 부분을 추가/삭제가 가능

**kvm**:


### 컨테이너

scale-out 

backingFsBlockDev: 컨테이너 이미지 파일(압축파일)를 물리적 장치처럼 구현해주는 드라이버


```

L [ DIR ]
L [ DIR ]  ---> block ---> [FsBlockDev] <--- <APP>  
L [ DIR ]

```

```            
                               .---> namespace,cgroup
                              /
podman run ---> conmon ---> runc[container image] ---> memory loadup ---> APP RUN
```


```
process ---> subgid/uid ---> namespace(uts,ipc,mnt,net)
-------      ----------      --------------------------
ps -ef       /etc/subgid     lsns
                     uid     ip netns
```

```
podman pod create
podman pod start <ID>
ps -ef | grep conmon | less

```

자동완성 기능
```bash
yum install bash-completion
complet -r -p
bash
```

**namespace**: 
커널에서 프로세스를 위한 "이름공간". 이 안에서 시스템과 사용자의 프로세서스 서로 격리 및 분리. 
"vServer Project"의 결과물 중 하나. "BSD"의 "Jail"이라는 시스템과 비슷하게 구성하려고 했음. 

ipc  mnt  net  pid  uts  user

위의 자원으로 커널에서 분리 및 격리. 컨테이너는 직접적으로 장치를 재구현을 못함.
"x86의 보호모드" 재구성을 못함. 

생성속도가 빠름. 단점은 한번 생성이 되면 수정하기가 어려움. 
재구성하기 위해서는 재생성이 정답.
  - pod기반으로 구성시 재생성을 조금 더 줄여 줌. 
  - docker 스토리지 연결...?


이전에는 컨테이너가 모든 namespace자원을 관리 하였다면, 지금은 POD가 IPC를 제외한 나머지 자원들을 관리함. (마운트, 네트워크)
컨테이너 실행 시, CPU, MEM에 대해서 선언없음!

     <S: running>     <pause>
     <lib, app>       <S, R>
    +-----------+     +-----+
    | container | --- | POD | ---  network  --- [콜 공유 중]  --- [커널]
    +-----------+     +-----+      mount
       [IPC]                       uts(clock)
    [isolate]         [isolate]

**cgroup**:
컨테이너에서 사용하는 모든 프로세스에 대해서 감사 및 제한혹은 제약을 한다. 
기본 크기에 대해서는 런타임(runtime)이 가지고 있음. 

**seccomp**:
시스템 콜 제한

**bpf**:
네트워크 콜 제한



**SELinux**: 

### 오케스트레이션
**kubernetes**: 


```bash
podman stop -a 
podman rm -a
podman run -d --pod new:pod-apache --name container-apache -p8080:8080 quay.io/centos7/httpd-24-centos7
```

# 연습문제

1. nginx이미지를 quay.io 혹은 hub.docker.com에서 찾으세요.
2. 포트번호 몇번을 사용하는지 확인 후 포트 맵핑(-p)로 접근이 가능해야 됨.
3. 'inspect'로 컨테이너 포트 번호 정보 확인이 가능.
  - expose라는 값이 일반적으로 애플리케이션에서 사용하는 포트
4. '-v'사용해서 "hello nginx"라는 메세지를 출력
  - /srv/nginx/htdocs/hello.html
    * 내용은 반드시 "this is nginx service"
    * SELinux가 반드시 켜져 있어야 됨
5. pod도 생성. "pod-nginx"로 컨테이너 "container-nginx"와 함께 실행.



# day 2

## 기타 잡지식+
```bash
                           <FILE>,<DIR>,<PORT>
   podman                           |
=============                       |
                                    v
pod/container --- namespace --- [seccomp] kernel
                  cgroup        [selinux]

```
**get/setenforce:** selinux 상태확인
  - 0: 임시적으로 꺼져있는 상태
  - 1: 동작중인 상태(강제로 프로세스 정책 적용)

```bash
getenforce
semanage fcontext -l | grep container_
chcon
semanage fcontext -a -t container_file_t "/root/nginx-htdocs(/.*)?"
# -a: append, 추가
# -t: context, 레이블 혹은 컨텍스트
# semanage로 실행하면, 적용되는게 아니라, selinux 상태db에 등록
restorecon -RFvv /root/nginx-htdocs
ls -aldZ /root/nginx-htdocs
```

## directory binding or mount binding
```bash

```

## container image structure(as runtime)

```
podman run -d ~~~
podman container ls --size

     Changed/Modifed/Added: 12B
    +-------------------
    |merge, upper, diff    ## 최상위 레이어, 파일 변경 및 추가 수정 여기에 기록
    +-------------------
            |
       [link layer]
            |
 [3]=================== -- 
 [2]===================   |[layers, virtual 736kB]
 [1]===================   |ReadOnly, lower
 [0]=================== --
```


## 스타벅스 걸리 문제!! :)

systemctl stop, service stop  == podman stop 
kill 

podman stop <CID>
  1. namespace isolate(kernel)
  2. stop ---> exit 
     (-15)      (-f, -9)
               Overlay에 저장을 못할 가능성이 높음. 

왜!? stop후에 container종료를 할까요? (1)
             ---------
              [process] <--- kill (2)
                          1. -15   
                          2. -9: Z/D 상태(process)
                          



```bash
 HOST         ----->      CONTAINER
======       [BINDING]   ===========
            -v: volume                                       <curl>
[1] /root/test/index.html < -------------------------------------.
                           [0] /usr/share/nginx/html/index.html   `------ :)-<-<
                              <index.html>        [HTTP]

$ curl localhost:8080 ## /usr/share/nginx/html 
```

커밋된 이미지를 컨테이너로 생성 후 서비스 호출

JSON: 메타정보를 가지고 있음. 
```

dataStore: /var/lib/containers/storages
                          \
Cow: Copy On Write == backingFsBlockDev
                            \
                             '--- <overlay>, runtime 정보(commit전)
                                    /
  podman create    --->   <overlay-containers>
                                   |\
                                   | `---> containers.json
                                   |       # podman container ls
                           <overlay-images>
                                    \
                                     `---> images.json
                                           # podman images 


```  
```
podman run -d -p8081:80 
localhost/commit-container-nginx
curl localhost:8081

```
## 이미지 빌드(연습용)


현재 만든 컨테이너에, content.html대신 index.html으로 교체.

```
vi Containerfile
FROM quay.io/centos/centos:stream8
LABEL type="devel"
MAINTAINER CHOI GOOK HYUN,<bluehelix@gmail.com>
RUN yum install httpd vsftpd php -y && yum clean all
USER root
WORKDIR /var/www/html/
COPY content.html .            ## index.html
#COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY root-httpd.conf /root/httpd.conf
EXPOSE 80
VOLUME /var/www/html
CMD /usr/sbin/httpd -DFOREGROUND -f /root/httpd.conf

echo "Hello My first container" > content.html
cp /etc/httpd/conf/httpd.conf .

podman build . -t quay.io/xinick/containerlab/httpd:first
podman tag <IMAGE_ID> quay.io/xinick/containerlab/httpd:first

podman run -d -p8080:80 quay.io/xinick/containerlab/httpd:first
curl localhost:8080
curl localhost:8080/content.html

```

## 연습문제


1. nginx를 centos-9-stream기반으로 구성. [v]
  - quay.io/centos/centos:stream9 [v]
2. 빌드된 이미지안에서 content.html를 nginx웹 디렉터리에 추가.
  - "Hello my nginx" [v]
  - nginx프로그램도 설치가 되어야 됨 [v]
  - Dockerfile, Containerfile 둘 중 하나 이용해서 빌드 [v]
3. 컨테이너 접근 포트번호는 80/tcp, nginx
  - 외부에서 접근하는 포트는 9797/tcp
4. 외부에서 nginx /usr/share/nginx/html으로 외부 디렉터리 바인딩.
  - 이 위치에 반드시 content.html이 있어야 됨.
  - /usr/share/nginx/html [v]
5. 이미지는 여러분 quay.io에 업로드.
  - my-nginx:1.0
6. 올바르게 컨테이너로 실행이 되어야 됨.[v]
  - cmd에다가 nginx 실행명령어  [v]
  - nginx -g 'daemon off;'    [v]



**MAC:** Mandatory Access Control
> SElinux, AppArmor
> context, boolean(syscall), port, senstive level

DAC: Discretionary Access Control
> chown, chmod, uid, gid     

Docker ---> Docker-shim   (x,k8s)
            Dockerd       --->   Containerd(support, k8s)
                                 ----------
                                 runc(OCI)  



# day 3

```bash
cat <<EOF> entrypoint.sh
#!/bin/sh
/usr/sbin/nginx -g 'daemon off;'
EOF
chmod +x entrypoint.sh
```

meta:
  name:sdsds
  labels:
    app: test
```Containerfile
FROM quay.io/centos/centos:stream9
LABEL TYPE="test"                    ## CONTAINER ENV(metadata + selector)
LABEL RUNTIME="podman"
ENV ANNOTATION_COMPANY="TMAX"        ## SHELL ENV(metadata + application config)
ENV ANNOTATION_DIVSION="MIDDLEWARE"
MAINTAINER CHOI GOOK HYUN,<bluehelix@gmail.com>
RUN yum install nginx -y && yum clean all
RUN mkdir /entrypoint/
VOLUME /usr/share/nginx/html /etc/nginx    ## -v, binding, volume 
COPY entrypoint.sh /entrypoint/run.sh
COPY nginx-data/content.html /usr/share/nginx/html/content.html
EXPOSE 80
ENTRYPOINT /entrypoint/run.sh
```
+ENV
+VOLUME

```bash
podman build -f Containerfile-nginx -t quay.io/xinick/containerlab/httpd:nginx-rev2
```

```bash
podman images 
podman run -p8081:80 quay.io/xinick/containerlab/httpd:nginx-rev2
curl localhost:8081/content.html
```

run: 컨테이너 빌드시 실행하는 명령어
cmd: 컨테이너 실행시 실행하는 명령어
  - cmd명령어는 컨테이너의 ENV를 사용함
    * httpd -DFOREGROUND
  - entrypoint: 컨테이너 실행시 실행하는 명령어 [v]
    * 가급적이면 절대경로로 실행
  - "entrypoint" + "cmd"
    = httpd         -DFOREGROUND

entrypoint, cmd: 실행 시, 컨테이너 런타임이 'sh -c'로 명령어 실행    
  - 'podman inspect'로 command확인이 가능


  ### 제가 잘못 설명한 부분

  1. "-v": 굳이, "containerfile"에서 "VOLUME"으로 선언할 필요가 없음.
    - 그냥 '-v'옵션으로 바인딩이 됩니다.
      * podman -v /var/www/html/:/usr/share/nginx/html/
      * 이건 바인딩(binding, mount -obind /var/www/html/ /usr/share/nginx/html)
      * /usr/share/nginx/html ---> /var/lib/containers/container-overlay

  2. "VOLUME"의 역할은, 컨테이너 런타임에서 관리하는 "VOLUME"자원을 디바이스 형태로 영구적으로 저장이 필요한 경우 사용한다.
    - local, devicemapper와 같은 컨테이너 스토리지 드라이버 사용
    - /etc/containers/storage.conf, container.conf 설정이 가능
    - 영구적으로 데이터 저장
    - VOLUME생성된 장치를 컨테이너 안에 맵핑을 하려면 반드시 "VOLUME"에서 선언이 되어 있어됨
      * podman volume create nginx-htdocs
      * 기본적으로 "local driver"
      * /var/lib/containers/storage/volume/
    - 위치 변경은 "/etc/containers/storage.conf"에서 "graphroot"값으로 변경 가능
      * "driver: local"으로만 적용
      * xfs, btrfs, devicemapper, overlay(with fuse), nfs
    - podman CSI driver
      * CSI: Container Storage Interface
      * Kubernetes도 위의 사양을 따름

    [드라이버 참고](https://github.com/dell/csi-unity/blob/main/Dockerfile.podman)



```containerfile
CMD nginx 
CMD httpd -DFOREGROUND
    ## bash httpd -DFOREGROUND
    ## ----
    ## bash_profile, bashrc
    ## 컨테이너 안쪽에서 실행
ENTRYPOINT nginx
ENTRYPOINT /usr/sbin/nginx    
      ## sh -c /usr/bin/nginx  --- post ran ---> ENV APPLY 
      ## $PATH
      ## (NULL ENV)
      ## 컨테이너 안쪽에서 실행, 대신 환경변수가 적용되기 전
```


https://github.com/goharbor
https://github.com/quay/quay
https://www.open-scap.org/


## rootless

1. 말 그대로 루트가 없음. 
  - 일반 사용자에서 컨테이너 실행 시.
  - 컨테이너 내부에서는 root권한이 필요함. 
    + 특정 서비스 혹은 프로그램에서 요구하는 경우
    + 사용자가 nginx인 경우

2. 예를 들어서 사용자 이름이 "tmax". 현재 사용중임
  - DAC기반으로 리눅스는 시스템이 동작함.
  - tmax]$ podman run --name tmax-nginx nginx:latest
  - nginx
    + nginx(uid,gid)
    + init(pid, root)
  - namespace 

## rootless 2(드라이버, 소프트웨어 드라이버(추상 드라이버))

1. 부팅 과정이 없음
2. 드라이버 초기화가 없음

```bash
ssh rootless@localhost
$ podman run -d -p 8080:80 --name nginx <IMG ID>     ## .service파일 생성하기 전까지 실행
$ mkdir -p ~/home/.config/systemd/user/
$ podman generate systemd --new --files --name nginx
$ mv nginx.service ~/home/.config/systemd/user/
$ systemctl --user daemon-reload
$ systemctl --user enable nginx.service
$ systemctl --user status nginx.service
$ podman stop -a 
# loginctl linger loginctl enable-linger rootless
```



# day 4

**저장소 본래 주소:** https://github.com/gotmax23
> https://github.com/gotmax23/Containerfiles/blob/main/Containerfiles/systemd/CentOS/CentOS.7.Containerfile



컨테이너에서 "systemd"혹은 "init"사용하는 케이스
> https://wiki.openstack.org/wiki/Kolla
> systemd를 사용하는 컨테이너는 컨테이너 안에서, init호출이 필요한 경우 

### 사용예제(systemd)
https://hub.docker.com/layers/kolla/ubuntu-source-nova-novncproxy/pike/images/sha256-5cfd84ae1ee26b43a50aec224a80ed4fb7597efeb213f781ea033d339570b595?context=explore




### 총정리 2


1. 컨테이너 이미지 빌드
  - ubuntu로 원하시는 버전 사용 [v]
  - apache가 설치가 되어 있어야 됨 
  - /var/www/html/  [v, "volume import", tar]
    + index.html [v]
    + content.html [v]
    + data.dat [v]
    + 위의 파일들은 volume혹은 디렉터리 바인딩으로 제공 [v]
2. apache컨테이너를 포트 9090:80으로 서비스 구성 [v]
3. curl접근이 가능해야 되며 index.html, content.html의 아무 내용이나 출력이 되면 됨. [v]
4. 반드시 SELinux가 활성화가 되어 있어야 됨. 
5. quay.io서버에 "ubuntu-apache:v1"으로 업로드
6. 최종적으로 사용자 ubuntu-apache생성 후 .service으로 동작이 되어야됨.     


## 미니큐베(podman 버전)

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
install kubectl /usr/local/bin/

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
install minikube /usr/local/bin/


minikube config set rootless true(==rootless ALL=(ALL) NOPASSWD: /usr/bin/podman)
./minikube start --driver=podman --container-runtime=cri-o


