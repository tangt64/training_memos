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
