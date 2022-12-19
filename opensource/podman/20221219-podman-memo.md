# day 1

## 가상머신 웹 대시보드
<https://con.dustbox.kr>

## 게이트웨이 터미널 서버
<ssh://console.dustbox.kr>

"putty", 혹은 "powershell"로 접근 가능

아이디는 **"container1~29"**번
비밀번호는 **"container"**으로 공통

교재 관련된 주소는 http://github.com/tangt64/training_memos/
                                                          opensource/podman

"Podman-in-Action-ebook-MEAP-Red-Hat-Developer-All-Chapters.pdf"

## 알면 좋은것?

MAC: Mandatory Access Control
> SElinux, AppArmor
> context, boolean(syscall), port, senstive level

DAC: Discretionary Access Control
> chown, chmod, uid, gid     

Docker ---> Docker-shim   (x,k8s)
            Dockerd       --->   Containerd(support, k8s)
                                 ----------
                                 runc(OCI)



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
5. pod도 생성. "pod-nginx"로 컨테이너 "container-nginx"와 함께 실행.
