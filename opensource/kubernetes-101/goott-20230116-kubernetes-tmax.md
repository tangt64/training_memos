# day 1

강사: 최국현

메일: tang@linux.com

과정은 "쿠버네티스 설치+간단한 명령어 운영"

### 내부 ISO내려받기 주소

http://172.16.8.31/


## 랩을 위한 필요한 도구

### 리눅스 배포판 설명

#### WSL2(필요하신 경우)

```powershell
wsl --install
wsl 
```

CentOS-Stream-9의 WSL2은 아래에서 내려받기 가능.

<WSL2 내려받기>(https://github.com/mishamosher/CentOS-WSL/releases)


#### 내부 PoC용도로 다음처럼 구성

1. H/A부분(LB)
  - Master x 3EA 
  - 이번 교육에서는 이 부분은 제외
  	* HAProxy, Nginx(선호) 
  	  + Kubernetes Metal Loadbalancer(SaaS)
  	* Keepalive 
  	* Pacemaker 

2. 스케일링 부분
  - 'kubeadm'명령어로 노드 추가(controller, worker)
  - ansible, terraform기반으로 확장
    * ansible 많이 선호
3. 보안
  - 쿠버네티스 사용자(ldap)
  - SELinux 공식적으로는 지원하지 않음
    * setenforce 0
  - 반드시 설치 전 swap이 꺼져있어야 됨
    * cgroup기반으로 메모리 사용량 측정시 문제
    * 추후에는 swap도 지원할 예정

4. 네트워크
  - RHEL 8/9
  - iptables는 더 이상 사용하지 않음
  - nftables(nft)
  - firewalld가 기본 방화벽
    * firewalld, nftables 사용 안하셔도 됨
    * POD + SVC = S/D NAT ==> nftables, firewalld
    * firewall-cmd명령어 학습
    * nft명령어 학습

5. 런타임
  - containerd
  - cri-o
  - cri-docker(needs compiling)

__네트워크__

외부 네트워크: NAT, eth0
내부 네트워크: API, eth1
+ 스토리지 네트워크
+ 백업/ingress 네트워크
+ 관리 네트워크

__마스터 1개__
  - vcpu 2개(1 O/S, 1 runtime)
  - vmem 4096MiB(8192MiB)
  - vdisk 13GiB(50~80GiB)
 
__워커노드 2개__
  - vcpu 2개(1 O/S, 1 runtime)
  - vmem 4096MiB(8192MiB)
  - vdisk 13GiB(50~80GiB)


#### 레드햇 계열

__centos-stream:__ https://www.centos.org/centos-stream/
__rocky linux:__ https://rockylinux.org/ko/download


#### OCI

1. 본래는 그냥 'docker'명령어로 전부 해결이 되었음
  - docker build   ---> buildha
  - docker search  ---> skopeo
  - docker run     ---> crio, containerd(standard)
  - docker volume  ---> csi
  - docker network ---> cni

``` bash
Fedora Core(upstream(rolling)) --- CentOS(upstream) --- RHEL(downsteam)
                                   ------               -----
                                    \                     \
                                     \                     `---> Rocky Linux
                                      \
                                       `---> CentOS-Stream(EOL,EOS 3 years)

            
```
__데비안 계열__
```bash
Debian --- stable
       \   ------
        \   \  
         \   `---> Ubuntu stable
          \
           `---> unstable
                 --------
                 \
                  `---> Ubuntu(bugfix)
```
* Debian Linux: 권장은 데비안 리눅스
* Ubuntu: 비권장
  - ".deb"패키지의 고질적인 질병(?)중 하나가, 의존성 검사가 상대적으로 약함
  - 이전에는 지원이 안됨, 현재는 지원합니다. 


- 하이퍼브이
  * overcommit 지원이 안됨
  * nested 

- 버추얼박스
  * Intel
  * AMD(오동작)

- VMware Workstation, Player
  * 라이센스 문제

## 쿠버네티스 설치 준비

1. 쿠버네티스는 A레코드에 민감하다.
  - IP <---> DNS A Recode
  - DNS(bind9)에 'IN A' 구성 및 선언
  - /etc/hosts
    * 192.168.90.100 master1.example.com
    * 192.168.90.120 node1.example.com
    * 192.168.90.130 node2.example.com
  - swap off가 필요

```bash
vi /etc/hosts
192.168.90.100 master1.example.com
192.168.90.130 node1.example.com
192.168.90.140 node2.example.com

swapon -s
swapoff -a
vi /etc/fstab
#/dev/mapper/cs-swap     none                    swap    defaults        0 0

systemctl stop firewalld
systemctl disable firewalld

firewall-cmd --list-all --zone=public
firewall-cmd --add-port=6443/tcp 

dnf install epel-release -y 
dnf search containerd
dnf install yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf repolist
dnf install containerd -y
systemctl start containerd
systemctl status containerd
systemctl enable containerd
```

# 참고자료

[한국어 에코 설명](https://blog.siner.io/2021/10/23/container-ecosystem/)

[OCI 사양 설명](https://medium.com/@avijitsarkar123/docker-and-oci-runtimes-a9c23a5646d6)	

[OCI 사양](https://github.com/opencontainers/distribution-spec/blob/main/spec.md)

[RKT, Rocket](https://en.bmstu.wiki/index.php?title=Rocket_%28rkt%29&mobileaction=toggle_view_desktop)

[DevSecOps(Legacy Ver)](https://devopedia.org/container-security)

[Kubernetes Containerd Integration Goes GA](https://kubernetes.io/blog/2018/05/24/kubernetes-containerd-integration-goes-ga/)


[Openshift vs Kubernetes](https://spacelift.io/blog/openshift-vs-kubernetes)
