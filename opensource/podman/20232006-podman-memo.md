# day 1

이름: 최국현

메일: tang@linux.com

[GITHUB](http://github.com/tangt64/training_memos/opensource/podman)

## PPT 및 교재 
[PPT](https://github.com/tangt64/training_memos/blob/main/opensource/podman/OPENSOURCE%20CONTAINER.pdf)
[PDF BOOK](https://github.com/tangt64/training_memos/blob/main/opensource/podman/Podman-in-Action-ebook-MEAP-Red-Hat-Developer-All-Chapters.pdf)


[ISO파일 내려받기](http://172.16.8.31/)

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


### seccomp/namespace/cgroup(virtual, container)

```bash
systemctl enable --now libvirtd
systemctl start libvirtd
systemctl is-active libvirtd
dnf install guestfs-tools virt-install -y
virt-builder --list
virt-builder --format=qcow2 --size=1G --output=/var/lib/libvirt/images/cirros.qcow2 cirros-0.3.5
virt-install --vcpus=1 --memory=100 --disk=path=/var/lib/libvirt/images/cirros.qcow2 --network=default --import --noautoconsole --virt-type=qemu --osinfo detect=on,require=off --name cirros
virsh list
virsh console cirros
```

```
 docker ---> search  ---> skopeo
        ---> image   ---> buildah
        ---> build   ---> buildah
        ---> lifecycle 
```

# day 2

**pause:** application(pause.c). 응용프로그램 중 하나. 
       - 신호처리
```c
static void sigreap(int signo) {
  while (waitpid(-1, NULL, WNOHANG) > 0)
    ;
}

```   
       - 무한대기
```c
  for (;;)
    pause();
  fprintf(stderr, "Error: infinite loop terminated\n");
  return 42;
```       
       - 네임스페이스를 직접 관리하지 않음

**pod:** 쿠버네티스에서 추상적으로 격리하는 부분을 'Pod'라고 부름.
       - 실제로는 pause에서 구현
       - 네임스페이스도 같이 필요함
       - cgroup POD자원 제어를 함(cpu, memory)

**infra container:** infra_container{container(POD_APP)}
       - 시스템 엔지니어나 혹은 런타임 영역에서 "pod"라는 단어 대신, "infra container"라고함. 
       - 'puase' 격리 애플리케이션 중 하나.

```bash
   .---> APP
  /
pause == POD == infra container(shared namespace)
          |                    (shared network)
          |
      container
       (equal)
```       


podman run -d --name apache -v /root/htdocs:/var/www/html/ 
                               ---------------------------
                              # mount --bind /root/namespaces /root/namespaces
                              > # mount --bind /root/htdocs /var/lib/containers/overlay-container/??
                              > stat
                              # mount --make-private /root/namespaces
                              > flag
                              # touch /root/namespaces/mnt
                              # unshare --mount=/root/namespaces/mnt
                              > into namespace 
## podman command

```bash
dnf install epel-release
dnf install podman-docker podman-compose
podman build     # Dockerfile, Containerfile
docker build

```

### used case

docker: Nvidia Data/AI
       ---> podman Nvidia/AMD => local(x)
                                 nfs ---> data
                                 HBA ---> data

### podman volume

**podman -v:** 'unshare', binding + private = namespace
           -> mount --bind --private  ## high level
**podman volume:** 'backingFsBlockDev', overlayFS 
           -> mount -t overlay        ## low level
              /var/lib/containers/storage/volumes/, 'local'로 사용시, '-v'하고 별반 차이 없음.
                                                    'local'

# day 3


### 연습문제 

0. 기존에 생성이 되어 있는 컨테이너 및 POD모두 제거.

1. 컨테이너 centos, apache, nginx를 총 3개를 구성한다.
  - apache, nginx는 이미지나 혹은 quay.io에서 명시된 포트로 포워딩한다.
  - 포워딩 포는 apache, 8088/tcp, nginx, 8099/tcp로 구성한다.
  - centos의 이름은 debug-container
  - apache의 이름은 httpd-container
  - nginx의 이름은 nginx-container
  - apache, nginx는 중지가 되면 반드시 자동으로 제거가 되어야 한다.
  - curl명령어로 올바르게 동작하는지 확인.

2. POD가 구성된 apache서비스를 구성한다.
  - pod의 이름은 apache-pod라고 명시한다.
  - container의 이름은 apache-pod-container라고 명시한다.
  - 포트는 8085로 접근이 가능해야 한다.

3. 변경된 메인 페이지를 제공한다.
  - 기존에 생성된 컨테이너 및 POD는 전부 제거한다.
  - /var/www/html/에 /root/apache-htdocs를 연결한다.
  - /usr/share/nginx/htdocs/에 /root/ngninx-htdocs를 연결한다.
  - 이 두개의 컨테이너는 POD와 연결이 되어야 한다.
  - nginx는 포트는 8081, apache는 8082로 접근이 되어야 한다.
  - apache "welcome apache", nginx "welcome nginx"메세지가 출력이 되어야 한다.
  
4. 네임스페이스 확인
  - 컨테이너가 올바르게 POD 네임스페이스 연결이 되어 있는지 확인한다. 
  - 컨테이너에서 연결이 되어있는 mnt가 올바르게 unshare, private상태로 구성이 되어 있는지 확인한다.
  - kata, crun을 통해서 올바르게 pod, container가 구성이 되어 있는지 확인한다.

5. 네트워크 조회 및 확인
  - iptables(nftables)를 통해서 POD하고 Container데이터 경로 확인.
  - CNI네트워크 플러그인 확인. 

힌트: 
* crun --root=/var/run/crun/  
* POD(kata), df
* iptables-save, iptables, nft 


vCPU: 2
vMEM: 4


JBOSS(Wildfly) ---> init ---> ubi-init ---> dumb-init(openstack, wildfly)
                                            ---------
                                            + SECCOMP(추가가 몇게 필요함)

# day 4

master, node1, node2

1. 내부네트워크 추가
2. 호스트 이름 설정

```bash
cat <<EOF>> /etc/hosts
192.168.90.100 master.example.com
192.168.90.101 node1.example.com
192.168.90.102 node1.example.com
EOF
swapoff -a
sed -i '/\/dev\/mapper\/rl-swap/d' /etc/fstab
dnf install wget -y

cd /etc/yum.repos.d/
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable.repo
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable_cri-o_1.24_1.24.4.repo


cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes -y 
systemctl enable --now kubelet ## 'activing..'
systemctl stop firewalld

sysctl -a | grep forward
sysctl -w net.ipv4.ip_forward=1 
cat <<EOF> /etc/sysctl.d/k8s_forward.conf    ## 영구적인 설정(kernel parameter)
net.ipv4.ip_forward=1 
EOF

sysctl -p -f
modprobe br_netfilter     ## 일시적으로 메모리 상주

cat <<EOF> /etc/modules-load.d/k8s_modules.conf   ## 영구적으로 부팅시 자동 상주
br_netfilter
EOF

systemctl daemon-reload

cd /etc/yum.repos.d/
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable.repo
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable_cri-o_1.24_1.24.4.repo
dnf search cri-o -y
dnf install cri-o -y
systemctl enable --now crio
```



```bash
skopeo sync --src docker --dest dir --scoped k8s.gcr.io/ /tmp/
                                docker                   localhost.registry.io

registry.k8s.io/kube-apiserver:v1.26.1
registry.k8s.io/kube-controller-manager:v1.26.1
registry.k8s.io/kube-scheduler:v1.26.1
registry.k8s.io/kube-proxy:v1.26.1
registry.k8s.io/pause:3.9
registry.k8s.io/etcd:3.5.6-0
registry.k8s.io/coredns/coredns:v1.9.3
```


```
kubeadm init --apiserver-advertise-address=192.168.90.100 --control-plane-endpoint 192.168.90.100

```

- containerd (v, -)
- crio       (=, i)
+ cri-docker (x)

```
curl -s --unix-socket /run/podman/podman.sock  http://d/v1.0.0/libpod/images/json | jq
curl -s --unix-socket $XDG_RUNTIME_DIR/podman/podman.sock http://d/v1.0.0/libpod/pods/json | jq

```

## 연습문제

* 컨테이너 서비스를 POD기반으로 구성한다.
```
quay.io/eformat/openshift-vsftpd
quay.io/centos7/nginx-116-centos7

run -d --pod new: -p :8080 -p 21100
run -d --pod 
buildah bud -f 
podman generate
podman play 
kubectl get pods/svc
kubectl create
KUBECONFIG=/etc/kubernetes/admin.conf
```

- POD 1개, Container 3개
- 쿠버네티스 YAML 전환
- 쿠버네티스 POD, SVC로 등록
- podman만 서비스는 중지(제거가 아님)

** 이미지 빌드가 어려운 경우, 빌드는 제외하고 서비스 두개(ftp, www)만 올리세요.

1. 웹 서비스 아파치로 구성한다. 포트는 이미지에서 명시한 기본포트 8080를 사용한다.
2. ftp서비스를 구성한다. 포트는 이미지에서 명시한 기본포트 21100를 사용한다.
3. pod의 이름은 www_svc으로 구성한다.
4. mysql 서비스를 위한 컨테이너를 구성한다. 
5. 쿠버네티스에는 pv, pvc가 없기 때문에 바인딩을 사용해서는 안된다. 
6. centos7이미지 기반으로 mysql컨테이너 이미지를 빌드한다. 포트는 3306를 사용한다. 
```
from quay.io/centos/centos
run yum install <PACKAGE> -y && yum clean all
expose 3306
cmd mysqld_safe
entrypoint    ## 동작이 안되면 이걸로 변경
```
8. 구성된 서비스를 쿠버네티스로 전환한다.
9. 쿠버네티스로 서비스가 전환이 완료가 되면, yaml파일으로 모든 서비스를 동시에 중지한다.


# 추가 정보

https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/
