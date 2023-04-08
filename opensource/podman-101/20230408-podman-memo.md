# day1

## lab plan

```bash


  POD =|    |= Container

      wildfly
   +------------+
   | kubernetes |  <--- MIDDLE WARE(API, MASTER/NODE ROLES, ORCHESTRATION)
   +------------+                                           -------------
                                                              통합 시스템


-----------------------------------------------------------
container runtime layer
        EJB
    +---------+
    | runtime |
    +---------+
 # ps -ef | grep docker ---> docker(dockerd(containerd))
 # ps -ef | grep podman ---> conmon(OCI)

-----------------------------------------------------------
container create layer


     jdk(java)
    +---------+
    |  runc   |
    +---------+

        jvm
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


### 1~3일

runtime, 가상머신 1대만 필요. 
ubuntu,debian,rocky,centos-stream
가급적이면 centos-9-stream
podman만 기반으로 런타임 학습.

### 4~5일

runtime + kubernetes 조합 구조에 대해서 이야기

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
docker, podman: API서버를 가지고 있음. 

* podman은 io.podman혹은 podman.io라는 API서버를 가지고 있음.
* docker는 docker-ee(swam)서버를 가지고 있음.

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

centos: release ---> rolling update  ---> RHEL(stream)
          v9.1          (stream)          Phase 1/2/3/4
          v9.2        3 years(EOL)              1: centos/rhel(os update + hardware)       
                                                2/3/4: subscription update only 
RHEL7 RPM REPOS
----------------
baseos
os

RHEL8(9) RPM REPOS
----------------
baseos
appstream + module(PPA)
            SCL(Software Collection)

rocky: clone even bugs
       + module package

 
## 강사 소개

최국현, bluehelix@gmail.com, tang@linux.com

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


conmon(CONTAINER_IMAGE) == Image Loader == /var/lib/containers/storages  ## 컨테이너 이미지 및 레이어 파일 저장
------
\
 `---> OCI 사양

crun(CONTAINER(container_environment(PODMAN)))
----
\
 `---> OCI 사양
```



### 자동완성 기능
```bash
dnf search bash-completion
dnf install bash-completion -y
complet -rp
exit | bash
```
