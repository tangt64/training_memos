# day 1

이름: 최국현
메일: tang@linux.com

**GITHUB:**  http://github.com/tangt64/training_memos/opensource/podman

## PPT 및 교재 
[PPT](https://github.com/tangt64/training_memos/blob/main/opensource/podman/OPENSOURCE%20CONTAINER.pdf)
[PDF BOOK](https://github.com/tangt64/training_memos/blob/main/opensource/podman/Podman-in-Action-ebook-MEAP-Red-Hat-Developer-All-Chapters.pdf)


**ISO파일 내려받기:** http://172.16.8.31/

## 설치(빠르게)

```bash
hostnamectl set-hostname podman.example.com
dnf install podman -y
dnf install podman-docker -y   ## 도커 호환성 명령어 패키지
```

```bash
dnf install bash-completion epel-release -y
complete -r -p
exit
ssh root@
```

```bash
dnf install fish
chsh -s /bin/fish 
fish
```

```bash
dnf install tmux -y

```

**Ubuntu/REHL(centos)/Rocky/Oracle Linux** 저장소에는 더 이상 docker를 지원하지 않음.
오픈소스 표준 런타임 사양(runtime spec.) **CRI+OCI**

현재 도커는 CRI사양을 따르지 않음. 최신 버전의 containerd기반 docker는 CRI를 충족함.
OCI는 보통, 컨테이너에서 사용하는 이미지(파일). 현재 다수 오픈소스 리눅스는 'podman'으로 전환.

podman는 docker를 대체하는게 주요 목적.

```bash
                .---> 쿠버네티스에서 사용
               /
docker ---> containerd ---> CRI-Docker 
            ----------      [새로운 도커]
            [표준 런타임]
```

도커 명령어 및 이미지는 현재 산업 표준.


ifconfig ---> ip addr show 
route    ---> ip route 
netstat  ---> ss 
---------
NAMESPACE조회를 지원하지 않음


## seccomp

시스템콜 확인하기.

```bash
dnf install strace
strace ls
```


## namespace

1. 격리의 목적(가상화의 하이퍼바이저와는 다름)
  - 하이퍼바이저 type-1, 컨테이너와 비슷함(유닉스에서는 하드웨어 파티션)
2. 프로세스의 안전성 강화  
  - mnt, ipc, net등의 프로세스 자원들을 분리하여 시스템에 치명적인 영향을 줄인다.
3. 컨테이너에서 사용하는 런타임은 네임스페이스를 통해서 프로세스 격리 및 맵핑을 한다.

```bash
                               <RING STRUCTURE>

     +--------+                        |              +------+
     | KERNEL |                        |              | USER |        [APPLICATION]
     +--------+              <--- | DRIVER | --->     +------+          - net
                                  +--------+
     [KERNELSPACE]                     |             [USERSPACE]
                                       |
                                       v
                                  [NAMESPACE,ns]
                                  # echo $$
                                  # cd /proc/$$/ns/

```     
## virtual machine vs container

### virtualization type-1 tech.(vServer)
- 부팅하는 단계가 있음.
- require to hardware V/T
  * CPU
  * Mainboard
- namespace: 자원격리, kernel             <---> 프로세스 격리 및 자원 격리 + 가상장치 제공
- cgroup: 자원 감시 및 제한, kernel        <---> 자원 제한 용도로 사용
- seccomp/SELinux: 가상머신 자원 접근 제한  <---> 컨테이너에서는 매우 의존성이 강함
- 링 구조 자체 구현  <---> 링을 호스트에서 공유 받음

- qemu, 예뮬레이터(disk, network, cpu, memory, bios) <---> runc, crun, kata와 같은 컨테이너 생성자가 필요함. 
- kvm, 가속기(kernel module(mainboard, cpu))     <---> 컨테이너는 가속기가 필요하지 않음
- libvirtd, 가상머신 런타임(라이프 사이클) 관리자  <---> podman

```bash

dnf groupinstall "Virtualization Host" -y

```

### container tech.(vServer)
- 부팅하는 단계가 없음. 
- namespace: 자원격리, kernel
- cgroup: 자원 감시 및 제한, kernel
- seccomp/SELinux: 가상머신 자원 접근 제한(시스템 콜 제한)
- 링 구조를 호스트와 공유
- podman, crio, cri-docker, containerd같은 런타임으로 컨테이너 라이프사이클 관리

kubernetes HPA: MSA, H: Horizontal 
kubernetes VPA: 3Tires V: Vertical


```bash


| process | ---> <driver> --->  | kernel | ---> | device |

OpenFlow(ovs,ovn)
+---------+     
| process | ---> {{ [tap device] --- [namespace] ---> [tap device] --- }}[BRIDGE] --- | kernel | 
+---------+                          <net,veth>                         <podman0>
                                      

``` 


### seccomp(virtual, container)

```bash
systemctl enable --now libvirtd
systemctl start libvirtd
systemctl is-active libvirtd
dnf install guestfs-tools virt-install -y
virt-builder --list
virt-builder --format=qcow2 --size=1 --output=/var/lib/libvirt/images/cirros.qcow2 cirros-0.3.5
virt-install --vcpus=1 --memory=100 --disk=path=/var/lib/libvirt/images/cirros.qcow2 --network=default --import --noautoconsole --virt-type=qemu --osinfo detect=on,require=off
```
