# day 1

**문서 및 자료 주소**
1. https://github.com/tangt64/training_memos/tree/main/opensource/kubernetes-101
2. https://github.com/tangt64/training_memos
3. https://github.com/tangt64/duststack-k8s-auto
   3-1. 설치도구(프로비저닝 부분은 제외)


총 4일 동안 진행하는 과정은 전부 기초적인 내용에 중심. 

교육환경
1. 윈도우 10 pro(hyper-v)
2. master x 1EA, work node(compute) x 2 EA
  2-1. utility(bootstrap node(kubernetes images from docker, k8s.io, quay.io))
  2-2. storage server(pNFS(4.1/2), Ceph Storage(Rook))
  3-3. single master -> multi masters(H/A)
3. 가상머신(CentOS 7기반으로 설치, ISO내려받기)  
  - http://mirror.kakao.com/centos/7.9.2009/isos/x86_64/
  - keyword: 'google centos 7 iso '


**강의 주제:** 쿠버네티스 기초
**강사 이름:** 최국현
**메일 주소:** bluehelix@gmail.com, tang@linux.com

## 랩 설명

- minikube, kind: docker, containerd, hypervisor기반으로 클러스터 구현

VM 총 3대 사용.

  - 내부 네트워크(API, Node to Node)
  - 외부 네트워크(ExternalIP, kubectl, 관리 네트워크)
    * 스토리지 네트워크
    * 외부 네트워크
    * 관리 네트워크

### 쿠버네티스 설치시 자원 고려 사항

Intel: vCPU ratio == pCPU == 12 vCPU(8 vCPU)

vCPU: 2개 이상을 요구(이번 교육에서는 권장 4 vCPU)
  - 1번 core: OS(namespace, cgroup, seccomp + k8s)
  - 2번 core: RUNTIME(crio, conainerd, docker)

메모리는
  - CentOS 7 최소 메모리가 2GiB(systemd + ramdisk) 올바르게 동작
  - 4GiB(이번 교육에서는 4기가)


설치시 호스트 이름은 다음처럼 미리 바꾸셔도 상관 없음.
- 아이피는 dhcp로 그냥 받아 오셔도 됨.
- 호스트 이름도 바로 설정 하셔도 되고, 추후에 변경하셔도 됨.

**만약 메모리가 16기가 이라서 부족한 경우 이래처럼 메모리 설정 변경**
네트워크
- External(기본으로 구성이 되어 있음)
- internal(이 네트워크는 내부 네트워크로 구성이 필요함)

>master: master.example.com, 4 vcpu, 4096
>worker node1: node1.example.com. 4 vcpu, 2048 
>worker node2: node2.example.com, 4 vcpu, 2048


메모는 여기에서 확인이 가능 합니다!!

https://github.com/tangt64/training_memos/blob/main/opensource/kubernetes-101/20221128-kubernetes-tmax.md


만약 아이피 주소 확인이 안되는 경우 다음처럼 실행 합니다.
절대 'ip up', 'ifconfig up' 사용하지 마세요.

```bash
nmcli con up eth0
ip a s eth0
```

CentOS7: 네트워크 스크립트 지원 --> 8/9-Stream/Rocky/RHEL
NetworkManager를 무조건 사용하셔야 됨. 


### 커널과 관계

컨테이너를 사용하기 위해서는 다음과 같은 기능이 필요함.

- namespace
  * 커널에서 사용자 프로세스를 격리하는 공간. 네임스페이스는 말 그대로 이름만 존재하는 공간이며, 실제 장치들 혹은 자원은 존재하지 않는다.
  * cmd: lsns, nsenter
  * cmd:ls -l /proc/$$/ns

- cgroup
  * 사용자가 생성한 프로세스에서 자원 분류별로 추적 및 감사를 한다. 컨테이너 런타임에서는 cgroup를 통해서 컨테이너 자원 사용상태를 추적 및 모니터링 한다. 쿠버네티스 kubelet은 systemd-cgroup으로 통합된 cgroup driver를 사용하고 있다. 
  * systemd-cgls
  * cmd: cgget -n -g cpu /
  * 
- seccomp
  * seccomp는 컨테이너에서 실행을 허용할 시스템 콜 목록을 가지고 있다. 허용하지 않는 시스템 콜이 호출이 되는 경우 컨테이너는 eBPF를 통해서 콜 실행이 차단된다. 
  *  BPF (Berkeley Packet Filter) facility
   + focus on the extended BPF version (eBPF)
   + https://docs.kernel.org/bpf/index.html


```bash
lsns 
cd /proc/$$/ns
```

### 포드만 설치(컨테이너/POD)
```
yum install podman -y
podman run -d --pod new:httpd --name httpd-8080 -p 8080:80 httpd
firewall-cmd --add-port=8080/tcp 
podman container ls == podman ps 
podman pod ls 

 Open Container Image/Inititive(OCI**)
 Open Container Network(OCN)
 Container Storage Interface(CSI)                                  
                                                                   .---> conmon: container monitor
                                                                   |
 POD == Pause                                                      v
                                                           .---> runc ---> <container>
 /usr/bin/conmon                                          /      (golang), crun(c lang)
-r: runc (runtime container)                        -------------
    ----                                              podman
     -> /var/lib/containers/                        -------------
     -> /run/containers/                                  |
                                .--- NAMESPACE            |
                               /                          |                 /var/lib/containers
                              +-----+                +---------+          +-------+
        | USER |     --->     | POD |       ----     | RUNTIME |   ---    | IMAGE |
                    mnt       +-----+                +---------+          +-------+
                    net   ---> [ namespace ] ---> veth ---> [ Linux Bridge ]                          
                    uts        
                    ipc
ipc: container ---> host kenrel call share
mnt: container ---> filesystem, device(binding)                
uts: System Time(in kernel)
net: POD에서 외부와 통신시 사용하는 네트워크 장치(veth, vpair)

```

rootless container: 
 - 부팅 과정이 없음(init 1)
 - ring structure가 없음(0~3)

backingFsBlockDev:
 - 컨테이너 이미지를 마치 블록 장치처럼 구성해주는 기능
 - "l, link"를 통해서 이미지 레이어 링크를 구성함
```
                 .---> COPY index.html /htdocs/index.html
                /
               .---> RUN mkdir /htdocs
              /
             .---> yum install httpd -y
            /
+----------------+
| CentOS7:latest |
+----------------+
```


```                                     
                                             <container>
                                                  |                                          .---> Redhat, SuSE, Google, IBM
                                                  |                                         /
                                                  |                                     ---'
      .------------------.                    [runtime] ---> docker(x), crio(v)
     /   isolate area     \                       |          =containerd(v)
   [ ISOLATE ] --- [namespace] --- mnt            |
                  <kernel space>   net  --- | application |  --- limit --- cgroup --- CPU(*)
                                   ipc                                            MEM(*)
                                   uts                                            DISK(-)
```


### 설치 준비


쿠버네티스 공식 설치 가이드 문서
https://kubernetes.io/ko/docs/setup/production-environment/tools/kubeadm/install-kubeadm/


### 조건사항

0. 쿠버네티스 저장소 등록
```
# yum install kubeadm --disableexcludes=kubernetes
# cat kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
```

1. firewalld,   nftables, iptables
```
    + nftables            (rhel 7)
     (d)

  6443, 10250/tcp: firewall-cmd --add-port=6443/tcp     
                                           10250/tcp
                   systemctl stop firewalld
                   systemctl stop iptables
```                   
2. SWAP부분
```
   RSS 메모리 + 페이지 메모리(swap off)
  -----------
  cgroup audit
  # swapoff -a, swapon -s 
  # vi /etc/fstab 
```
3.  [WARNING Hostname]: hostname "master1.example.com" could not be reached
```  
   /etc/hosts
   <MASTER_IP>    <FQDN>   <HOSTNAME>
   <NODE1>        <FQDN>   <HOSTNAME>
   <NODE2>        <FQDN>   <HOSTNAME>
```
4. [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
```
   yum install kubeadm kubelet kubectl
   systemctl enable --now kubelet.service 
```  

5. [ERROR CRI]: container runtime is not running:
   **containerd**
```
   https://download.docker.com/linux/centos/
   yum install wget
   cd /etc/yum.repos.d/
   wget https://download.docker.com/linux/centos/docker-ce.repo
   yum install containerd
   containerd config default > /etc/containerd/config.toml
   systemctl enable --now containerd
```
   **CRIO**
```   
   https://cri-o.io/
   OS=CentOS_7
   VERSION=1.17
   curl x 2
   파일이 내려받기가 안되는 경우 아래서 그냥 저장소 파일 받으세요.
   https://github.com/tangt64/duststack-k8s-auto/tree/master/roles/kubernetes/k8s-prepare/files
```
6. kernel module and parameters
```bash
## centos 7
# vi /etc/modules-load.d/99-kubernets-modules.conf
br_netfilter (v)
overlay      (v)
ip_vs_rr
ip_vs_wrr
ip_vs_sh
ip_vs
nf_conntrack_ipv4(rhel 8/9(x))
# dracut -f 
-----------------
POD/SVC에서 발생한 연결(connection) 추적

net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
```


```
ansible-galaxy collection install ansible.posix

```
