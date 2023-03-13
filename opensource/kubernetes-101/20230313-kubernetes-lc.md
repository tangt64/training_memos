# day 1

**강의 주제:** 쿠버네티스 기초

* **강사 이름:** 최국현
* **메일 주소:** bluehelix@gmail.com, tang@linux.com

https://github.com/tangt64/training_memos/blob/main/opensource/kubernetes-101/20230313-kubernetes-lc.md

## 문서 및 자료 주소
1. https://github.com/tangt64/training_memos/tree/main/opensource/kubernetes-101
2. https://github.com/tangt64/training_memos
3. https://github.com/tangt64/duststack-k8s-auto

## 선수 사항

1. 컨테이너 런타임 기본 지식 및 이해
2. OCI표준 도구에 대한 기본 지식 및 이해
> container == docker ---> containerd(standard) ---> docker(deprecated) ---> cri-docker(kubernetes)
> OCI(image, command), podman, buildah, skopeo
> docker ---> podman, docker build ---> buildah, docker search ---> skopeo

## 내부 ISO내려받기 주소

http://172.16.8.31/

## 잠깐 잡담

kubernetes docker based

기존 리눅스 컨테이너는 vServer프로젝트에서 시작.

1. 가상머신(하드웨어 + 커널 + 소프트웨어)
  * 프로세스 격리(호스트하고 분리 운영)
  * dom0(코스트, 즉 비용이 높음)
  * vcpu, vmem 자원 활용을 제한

2. 컨테이너(커널 의존성이 강한 기술)
  * 프로세스 격리(호스트하고 분리 운영)
  * 낮은 비용으로 프로세스 격리 
  * namespace(process isolate(ing))
  * cgroup(자원제한)

3. google 먼저 시도(프로세스를 격리)
        
### runtime
- lxc(ring structure(x86))
- chroot(-)
- Jails(-, bsd)
- rkt(ring structure(x86))
- docker(rootless, ring shared)

### 이전 도커
- 컨테이너 관리
- 네임스페이스 및 cgroup를 관리
- dockerd 밑으로 모든 자원을 관리
  * containerd(컨테이너 생성, 분리요청)
  * kubernetes, CRI-O
  * docker(x), Podman
    - skopeo
    - buildah    

```bash

kubernetes
---------
docker(rootless)
---------
linux

```

## 랩 환경

Windows 10/11 Pro(HyperV)
- Virtulbox(VCPU(AMD)), VMware Workstation(license)
- VMware Player(personal free)

### 하이퍼브이 가상머신 설정
- ISO: CentOS-8-Stream
  * Rocky-8/9
  * RHEL-8/9
  * Oracle-8/9
- 3대 설치(1 마스터, 2 워커)
- 네트워크 2개
  * Default
  * internal(없으면, "가상 스위치 관리자"에서 생성 )
- 가상CPU 2개, 가상 메모리 4096MiB

### 가상머신 설정

- 루트 암호
  * centos
- 네트워크 시간 꼭 활성화(Time & Date)
  * Seoul, Korea
  * NTP활성화
- 소프트웨어 선택(software selection)
  * Minimal Instal
- 네트워크 설정(master, node1, node2)
  * eth0: DHCP
  * eth1: STATIC(manual)
    * master: 192.168.90.110/24, GW(x)
    * node1: 192.168.90.120/24, GW(x)
    * node2: 192.168.90.130/24, GW(x)
- eth1 ---> configure ---> IPv4
  * method: manual
  * IP: 192.168.90.X
  * NETMASK: /24, 255.255.255.0
  * GATEWAY: NONE
  * OFF ---> ON

[파워쉘 다운로드](https://learn.microsoft.com/ko-kr/windows/terminal/install)




