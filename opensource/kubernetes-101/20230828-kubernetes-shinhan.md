# day 1

## 강의 주제: 쿠버네티스 기초

강사 이름: 최국현

메일 주소: 
- bluehelix@gmail.com
- tang@linux.com


## 문서 및 자료 주소
1. https://github.com/tangt64/training_memos/tree/main/opensource/kubernetes-101
2. https://github.com/tangt64/training_memos
3. https://github.com/tangt64/duststack-k8s-auto

## 선수 사항

1. 컨테이너 런타임 기본 지식 및 이해
2. OCI표준 도구에 대한 기본 지식 및 이해
3. 리눅스 시스템

## runtime

리눅스 배포판(GPL2/3)
---
1. 일반적인 배포판
2. 보안이 강화된 배포판(읽기전용)
3. 하지만 최근에...


### OpenELA/CIQ

```
- https://www.suse.com/news/OpenELA-for-a-Collaborative-and-Open-Future/
- https://openela.org/
- https://www.reddit.com/r/linux/comments/15ynpwc/prediction_openela_trade_association_is_likely_to/
- https://www.reddit.com/r/RockyLinux/comments/15nhra5/ciq_oracle_and_suse_create_open_enterprise_linux/

ubuntu -> debian 
rhel   -> suse, rocky, alma

```


리눅스 커널
---
1. namespace(ipc, net, mount, time): 자원 격리
2. cgroup(google): 자원 추적
3. selinux(call): 시스템 콜 접근 제한

OCI표준도구
---
1. podman
2. buildah
3. skopeo

쿠버네티스 표준 런타임(CRI지원)
---
- cri-docker
- crio-o
- containerd(docker-engine)

## 랩준비

http://172.16.0.84/rocky.iso

https://github.com/tangt64/training_memos/
>opensource/kubernetes-101/20230828-kubernetes-shinhan.md

[하이퍼브이 설치 방법, 마이크로소프트](https://learn.microsoft.com/ko-kr/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v)

[로키 리눅스 9.2, 네이버 미러사이트](http://mirror.navercorp.com/rocky/9/isos/x86_64/Rocky-9.2-x86_64-minimal.iso)

## 리눅스 및 런타임

### namespace/cgroup

__namespace(ns):__ 프로세스 격리(범위), 커널 버전별로 범위가 다름.

__cgroup:__ 프로세스 추적 및 감사(제한(systemd(.slice))).

#### namespace

PID --> namespace ID(NSID)

```bash
ps -e -ocmd,pid | grep bash
-bash                          1635

cd /proc/$$/ns
        [1635]
ls -l
---
cgroup -> 'cgroup:[4026531835]'
ipc -> 'ipc:[4026531839]'
mnt -> 'mnt:[4026531841]'
net -> 'net:[4026531840]'
pid -> 'pid:[4026531836]'
pid_for_children -> 'pid:[4026531836]'
time -> 'time:[4026531834]'
time_for_children -> 'time:[4026531834]'
user -> 'user:[4026531837]'
uts -> 'uts:[4026531838]'

lsns
ip netns
```

### cgroup

1. cgroup은 systemd에 통합(.slice)
2. /usr/lib/systemd/system(.slice)

```bash
systemctl -t slice
systemd-cgls
systemd-cgtop
```

### runtime

1. podman(docker호환)

```bash
dnf install podman -y
systemctl status podman
systemctl is-active podman
dnf module list
dnf install epel-release -y
dnf search podman
dnf install podman-docker podman-compose podman-tui -y
```

설정파일
---
- /etc/containers/registries.conf: 저장소 관련 설정
- /etc/containers/policy.json: 접근을 허용할 저장소 위치

```bash
podman container ls        # docker ps
podman pod ls              # -
podman ps                  # docker ps

grep -Ev '^#|^$' /etc/containers/registries.conf
systemctl enable --now podman
systemctl is-active podman
> active
podman-tui                 # 종료는 ctrl+c
```

tmux사용하실 분은 아래처럼 설치 및 설정하세요.

```bash
dnf install tmux -y
cat <<EOF> ~/.tmux.conf
set -g mouse on
EOF
tmux
```

간단하게 컨테이너 실행하기
---
```bash
podman run -d httpd   # podman run docker.io/library/httpd:latest
                      # 저장소 위치는 registries.conf의 내용 출력
podman ps
>CONTAINER ID  IMAGE                           COMMAND           CREATED        STATUS        PORTS       NAMES   2b13f90dd82c  docker.io/library/httpd:latest  httpd-foreground  6 seconds ago  Up 6 seconds              gifted_rhodes

```


컨테이너 프로세서 동작 방식(detach(-d))
---
```bash
 +------+
 | HOST | -- ps -- > [container]
 +------+               (bin)
     \                    /
      `-------- X -------`
      userspace disconnected
```


컨테이너 저장 위치
---
```bash
cd /var/lib/containers/storage                ## 컨테이너 파일이 저장되는 위치
cd overlay/
ls -l
> backingFsBlockDev                           ## 컨테이너 COW생성 장치

podman run -d centos /bin/sleep 10000
podman ps
podman exec -it faa3845b109f /bin/bash
```


crun/conmon(podman(crun(conmon)))
---

```bash
pstree -ap
> sleep
  ├─conmon --api-version 1 -c faa3845b109f41f4494b92f99161ad33440e7688f728f62db5a1447ad5a0a8c0 -ufaa3845b10        
  │   
  └─sleep --coreutils-prog-shebang=sleep /bin/sleep 10000  
man conmon

crun: c언어 만들어진 표준 런타임(2,redhat,suse)
runc: go언어 만들어진 표준 런타임(1)

podman(engine) 
  \
   `--->[exec] $ podman stop centos
           \
            `---> conmon(loader(image(app+lib)))
                    \
                     `--->[fork](runtime)
                             \
                              `---> [crun] ---> (hello.aout)
podman images
podman search pause
podman pull docker.io/google/pause

podman save 279dc3ec850c -o podman-pause.tar   
podman save f9d5de079539 -o kubernetes-pause.tar 

pod --> pause --> pause/catat                            
```

https://buildah.io/blogs/2017/11/02/getting-started-with-buildah.html


### <a name="osinstall"></a>쿠버네티스 설치 및 OS설정

```bash
## 네트워크 아이피 설정

# 방법1
nmtui edit eth1
nmcli con up eth1

# 방법2
nmcli con add con-name eth1 ipv4.addresses 192.168.90.250/24 type ethernet ifname eth1
nmcli con up eth1


## A recode 구성

hostnamectl
> master.example.com
hostnamectl set-hostname master.example.com         ## PTR도 권장

cat <<EOF>> /etc/hosts
192.168.90.250 master.example.com master 
EOF

# ping yahoo.com 
# 1. /etc/hosts
# 2. /etc/resolve.conf


## 커널 모듈 자동 불러오기
#
# br_netfilter: netfilter(iptables,nftables)에서 브릿지 관련 모듈
# overlay: 컨테이너 파일시스템 구성, 계층으로 파일 시스템 구성
#     \
#      `-->mount -t overlay 
# systemd는 부팅 시 커널 모듈을 추가적으로 "modules-load.d"에서 불러옴
#
cat <<EOF> /etc/modules-load.d/k8s-modules.conf
br_netfilter                      
overlay
EOF
modprobe br_netfilter
modprobe overlay

## 커널 파라메터 변경
#
# 라우팅 테이블 및 데이터 흐름 제어하기 위해서 커널 기능 활성화
# source:destination packet
# 
cat <<EOF> /etc/sysctl.d/99-k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
# net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

## 쿠버네티스 저장소 등록
# /etc/yum.repos.d/  -->  /etc/dnf/repos.d/
# "exclude=" 패키지 업데이트 방지
# CNI: Container Network Interface(plugin)
# CRI: Container Runtime Interface(podman, buildah, skopeo)
cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
dnf install kubeadm kubelet kubectl -y --disableexcludes=kubernetes

#
# CRI-O저장소 구성 및 설치
# 쿠버네티스 전용 런타임(혹은 엔진 설치), 저수준의 런타임
# 
cat <<EOF> /etc/yum.repos.d/libcontainer.repo
[devel_kubic_libcontainers_stable]
name=devel_kubic_libcontainers_stable
type=rpm-md
baseurl=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_9_Stream/
gpgcheck=1
gpgkey=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_9_Stream/repodata/repomd.xml.key
enabled=1 
EOF

cat <<EOF> /etc/yum.repos.d/crio_stable.repo
[crio]
name=cri-o for derivatives RHEL
type=rpm-md
baseurl=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.6/CentOS_8/
gpgcheck=1
gpgkey=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.6/CentOS_8/repodata/repomd.xml.key
enabled=1
EOF
yum install crio -y

## kubelet 및 crio시작

systemctl enable --now kubelet
systemctl enable --now crio
```

## 오늘의 목표

1. podman기반으로 pod, runc, conmon, pause
2. 표준 컨테이너 동작 방식 및 관련 디렉터리/서비스 확인
3. 쿠버네티스 설치을 위한 준비
4. 컨테이너 이미지 및 표준 도구

# day 2

위의 설치 내용 계속 이어서...[이전내용](#osinstall)


```bash
systemctl stop firewalld
systemctl disable firewalld

swapon -s
swapoff -a
swapon -s

kubeadmin init

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes
kubectl describe node master.example.com
>Taints: node-role.kubernetes.io/control-plane:NoSchedule
kubectl taint nodes master.example.com node-role.kubernetes.io/control-plane:NoSchedule-
kubectl run --image=nginx nginx
kubectl get pods -w                   ## 생성이 완료가 되면 ctrl+c
kubectl delete pod --all

kubeadm reset --force                 ## 노드 초기화
```


## 오늘의 목표

1. pod, runc, conmon, pause
2. 쿠버네티스 서비스 확인
3. 쿠버네티스 설치 설명 및 리눅스와 관계
4. 기본적인 사용 방법




# day 3
# day 4
# day 5