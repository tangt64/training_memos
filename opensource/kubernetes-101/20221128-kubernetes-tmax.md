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
(https://kubernetes.io/ko/docs/setup/production-environment/tools/kubeadm/install-kubeadm/, 설치가이드)


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

# vi /etc/sysctl.d/99-k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
```

7. 노드 상태 확인하기


**이 작업은 마스터 서버에서 해주시면 됩니다**, **SELinux가 켜져 있는 경우 'setenforce 0'으로 꺼주세요**

/etc/selinux/config: 여기에서 selinux 영구적으로 끌수 있습니다.
/etc/fstab: 여기에서 스왑을 영구적으로 주석처리 혹은 삭제 

```
mkdir -p ~/.kube/
cp /etc/kubernetes/admin.conf ~/.kube/config
kubectl get nodes
kubectl get pods -A
```

8. 네트워크 추가하기

[칼리코](https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart)


```
ansible-galaxy collection install ansible.posix
```


# day 2

**수동 설치 진행**
PoC : master x 1, node x 2  (x)
Prod: master x 3, node x 2 (v)
- 네트워크 추가(터널링)
- 런타임(containerd --> crio)

1. 쿠버네티스는 SELinux를 공식적으로 지원하지 않음.
```
  1-1. SELinux 정책에 쿠버네티스가 등록이 안되어 있음. 
       ------------
       \
        `---> 별도로 구성 혹은 OpenShift(OKD)
  1-2. seccomp(BPF/eBPF)
```        
2. firewalld, 대체적으로 올바르게 동작하지 않음.
  - 6443이외 포트도 확인 후 등록이 필요.
  - systemctl stop firewalld(nftables)

3. kernel modules, parameters
  - modules-load.d/
    + modprobe <MODULE_NAME>
    + "br_netfilter" 이 모듈이 제일 중요함.
    + modprobe $(cat 99-k8s-modules.conf)
  - sysctl.d/
    + 99-k8s.conf
4. swapoff!!
  - swapon -s && swapoff -a


## 다중 마스터 서버 구축


요구사항: 3대의 마스터 서버 + 1
         1EA, Bootstrap Node(MultiMaster Deployment Done...remove..)
              --upload-certs
              --control-plane               
         3EA, MultiMaster Nodes

참고 메뉴얼
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/


### 준비물

http://github.com/tangt64/duststack-k8s-auto/
                                             roles/kubernetes/
**HAproxy** , Nginx 

Masters 3~4대가 준비가 되야 됨. +2
Master Node : kubeadm reset --force              
Compute Node: kubeadm reset --force

### 멀티 마스터 명령어 정리

```

kubeadm init --control-plane-endpoint 172.31.137.87  --upload-certs
                                      -------------
                                      \
                                       `---> 이 위치에 본래는 haproxy서버 정보가 들어감.
                                             우리 랩에서는 haproxy가 없기에 첫번째 서버가 그 역할을 함. 

kubeadm init phase upload-certs --upload-certs
                   ---------------------------
                   \
                    `---> init 이후 별도로 마스터 노드 추가 하는 경우 이 명령어 사용

kubeadm join 172.31.137.87:6443 --token sdhejm.ef26z515jnhgeeqd \
        --discovery-token-ca-cert-hash sha256:650a711d2854c764bb1565ed11dba174b3ed8189425a2aa1e4733cd31c36d8c8 \
        --control-plane --certificate-key aa820c2b9770ad2e7792cf91c9c4dcbf12a1f6724f5d37bb16151a9667e33a9a                    

kubeadm join 172.31.137.87:6443 --token sdhejm.ef26z515jnhgeeqd \
        --discovery-token-ca-cert-hash sha256:650a711d2854c764bb1565ed11dba174b3ed8189425a2aa1e4733cd31c36d8c8


```



### 최종 랩 설치

master x 3
node x 2

runtime: crio
API interface: eth1


``` bash
nmtui
eth1 active and link up


수동
nmcli con mod eth1 ipv4.addresses 192.168.90.78/24 ipv4.gateway 0.0.0.0 ipv4.method manual
nmcli con up eth1

yum install cri-o -y
systemctl stop containerd
systemctl disable containerd
systemctl enable --now cri-o
vi /etc/hosts
172.31.13x.* ---> 192.168.90.X
kubeadm reset --force ## 모든서버
                                          eth1                                                       eth1
                                      -------------                                              -------------
kubeadm init --control-plane-endpoint 192.168.90.87  --upload-certs --apiserver-advertise-address=192.168.90.87

cp /etc/kubernetes/admin.conf ~/.kube/config
kubectl get nodes
```

https://raw.githubusercontent.com/tangt64/duststack-k8s-auto/master/roles/cnis/cni-calico/files/tigera-operator.yaml


# day 3


## 네트워크 구성(POD) + 최종정리


```bash

eth0: nat, external
eth1: API, internal,static IP   <--- kubectl 

## firewalld
systemctl stop firewalld
systemctl disable firewalld

## selinux
vi /etc/selinux/config 
getenforce
setenforce

## swap
vi /etc/fstab
swapon -s
swapoff -a


                                                                    .---> ETCD서버에 업로드
## kubeadm for master                [PROXY IP(VIP)]               /
                                     --------------  --------------
kubeadm init --control-plane-endpoint=192.168.90.87  --upload-certs --apiserver-advertise-address=192.168.90.87 --pod-network-cidr=192.168.0.0/16 --svc-network-cidr=10.
+ --cri-socket="/var/lib/crio|contaienrd"
## rest of masters
kubeadm join --control-plane

## node 
kubeadm join 

```


```bash
## 잘 안되시는분들 아래처럼 진행 후 다시 시작!

## master 1~3, node 1~2
kubeadm reset --force
kubeadm init --control-plane-endpoint 192.168.90.87  --upload-certs --apiserver-advertise-address=192.168.90.87 --pod-network-cidr=192.168.0.0/16
nmcli con up eth1
nmcli con mod eth1 autoconnect yes
systemctl disable firewalld
systmctl stop firewalld
setenforce 0
vi /etc/selinux/config
SELINUX=permissive

## master 1~3 
kubeadm join --control-plane

## node 1~3 
kubeadm join 

# kubectl 명령어 안되시면(8080) 아래 명령어 실행
export KUBECONFIG=/etc/kubernetes/admin.conf   ## 실제 제품 환경에서는 공유하면 안됨.
kubectl get nodes

# 만약 dump가 안되면..
cat /etc/kubernetes/manifests/kube-controller-manager.yaml | grep cluster-cidr
ps -ef | grep cidr

기본 POD주소: 10.88.0.0/12  ## ip netns exec cni-<~~~> ip a  
             10.90

# 쿠버네티스 클러스터에서 사용하는 POD 네트워크 정보 확인
kubectl cluster-info dump | grep cidr
"--allocate-node-cidrs=true",
"--cluster-cidr=192.168.0.0/16",
"--allocate-node-cidrs=true",
"--cluster-cidr=192.168.0.0/16",
"--allocate-node-cidrs=true",
"--cluster-cidr=192.168.0.0/16",

# calico(vxlan) 터널링 네트워크 생성
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml

# calico에서 POD네트워크를 연결한 대역을 설정
vi custom-resources.yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
  registry: quay.io

---
# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}


# 설정 값 등록 
kubectl create -f custom-resources.yaml   ## 10.xx으로 되어 있으면 안됨 수정(192.168) 후 아래명령어 실행
kubectl replace -f custom-resources.yaml 
```

```
yum install epel-release
yum install ansible git 

git clone https://github.com/tangt64/duststack-k8s-auto/

cd duststack-k8s-auto/
vi inventory/YAML-kubernetes.yaml
console:
  hosts:
    172.31.137.87:   <--- eth0, master
k8s_master:
  hosts:
    172.31.137.87:   <--- eth0, master
      nodename: master1.example.com <--- hostname
      k8s_ip4: 192.168.100.87 <--- eth1, master
k8s_node:
  hosts:
    172.31.143.23: <--- eth0, node1 
      nodename: node1.example.com 
      k8s_ip4: 192.168.100.23 <--- eth1, node1
    172.31.135.150: <--- eth0, node2
      nodename: node2.example.com
      k8s_ip4: 192.168.100.150 <--- eth1, node2   

sh deploy_k8s.sh

```

#### bash 자동완성 활성화(쉘마다 다름)
```
kubectl completion -h
yum install bash-completion
kubectl completion bash > ~/.kube/completion.bash.inc
cat ~/.kube/completion.bash.inc >> ~/.bash_profile
source ~/.bash_profile
complete -r -p
bash
```

yaml/base_command/basic-deployment-nginx.yaml

# day 4


```bash

kubectl create namespace basic
kubectl get namespaces 
kubectl config set-context --current --namespace basic

vi basic-deployment-apache.yaml
vi basic-deployment-nginx.yaml

kubectl create -f basic-deployment-nginx.yaml
                  basic-deployment-apache.yaml

kubectl expose deploy nginx
                      apache

kubectl get endpoint       

@master> kubectl describe <POD>
         node, PODIP확인
@nodeX> crictl ps | grep <POD-NAME>
@nodeX> crictl pods ls | grep <POD-NAME>                         
```

container =/= POD
container: application
POD: resource(isolate)

https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt
https://www.docker.com/blog/mergediff-building-dags-more-efficiently-and-elegantly/

- LowerDir: these are the read-only layers of an overlay filesystem. For docker, these are the image layers assembled in order.
- UpperDir: this is the read-write layer of an overlay filesystem. For docker, that is equivalent to the container specific layer which contains changes made by that container.
- WorkDir: this is a required directory for overlay, it needs an empty directory for internal use.

- MergedDir: this is the result of the overlay filesystem. Docker effectively chroot's into this directory when running the container.

For more on overlay filesystems (overlay2 is a newer release, but I don't believe there are any user visible changes), see the kernel docs:


```
 (master, node1,2)
kubeadm --reset

yum remove kube* 
yum install git
git clone https://github.com/tangt64/duststack-k8s-auto

yum install epel-release -y
yum install ansible -y
cd duststak-k8s-auto
vi inventory/kubernetes.yaml
console:
  hosts:
    172.19.136.42: (eth0)
k8s_master:
  hosts:                                               * ssh_remote_password: centos
    172.19.136.42: (eth0)                              * ssh_remote_user: root
      nodename: master1.example.com          ---> vi inventory/group_vars/all/kubernetes  
      k8s_ip4: 192.168.100.42 (eth1)           ---> ansible-galaxy collection install -r requirements.yaml
k8s_node:                                    ---> ssh-keygent 
  hosts:                                     ---> sh deploy_k8s.sh
    172.19.142.239: (eth0)
      nodename: node1.example.com
      k8s_ip4: 192.168.100.239 (eth1)
    172.19.134.97: (eth0)
      nodename: node2.example.com
      k8s_ip4: 192.168.100.97 (eth1)
```



```
                    

       (deployment(o) RS =/= RC(deployconfig(x))          


                                   .---> configmap, secret, limit, quota....
                                  /
                                 /
                              DEPLOY           SVC               
                              ======          =====
                              label:          label:
                                ^             selector: ---------.
                                |             "deploy label"     |
                                |             "SEP"              |
                                |                                |
                                v                                v
                                RS --->    RUNTIME     --->     POD
                               ====                         =============
                               spec:                              3 == [SVCIP + PORT, ClusterIP]
                               replicas: 3 
                                 template:
                                 selector:



```


externalname 동영상




```bash
tang@linux.com

yum install epel-release
yum install git ansible 
git clone https://github.com/tangt64/duststack-k8s-auto
cd duststack-k8s-auto/

## eth0에 강제로 static으로 아이피 설정.

vi inventory/kubernetes.yaml
console:                        ### master 아이피
  hosts:
    172.19.136.42:              ### eth0
k8s_master:
  hosts:
    172.19.136.42:              ### eth0
      nodename: master1.example.com
      k8s_ip4: 192.168.100.42   ### eth1
k8s_node:
  hosts:
    172.19.142.239:             ### eth0
      nodename: node1.example.com
      k8s_ip4: 192.168.100.239  ### eth1
    172.19.134.97:              ### eth0
      nodename: node2.example.com
      k8s_ip4: 192.168.100.97   ### eth1

vi inventory/group_vars/all/kubernetes
ssh_remote_user: root
ssh_remote_password: centos

ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
ansible-galaxy collection install -r requirements.yaml
sh deploy-k8s.sh
sh remove-k8s.sh

```


메일주소

tang@linux.com
bluehelix@gmail.com
최국현, 연락처는 010-4126-8902

