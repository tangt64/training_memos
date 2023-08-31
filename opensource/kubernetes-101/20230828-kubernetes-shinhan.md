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
> node1.example.com
hostnamectl set-hostname master.example.com         ## PTR도 권장
                         node1.example.com
                         node2.example.com

cat <<EOF>> /etc/hosts                              ## FQDN에 맞추어서 구성
192.168.90.250 master.example.com master 
192.168.90.110 node1.example.com node1
192.168.90.120 node2.example.com node2
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


master: eth1, 192.168.90.250
node1: eth1, 192.168.90.110
node2: eth1, 192.168.90.120

```bash
systemctl stop firewalld
systemctl disable firewalld

swapon -s
swapoff -a
swapon -s

ls -l /etc/containers/policy.json
cat /etc/containers/policy.json
> registry.access
> registry.redhat
rm -f /etc/containers/policy.json
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/files/policy.json

kubeadm init

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

kubectl명령어의 KUBECONFIG설정이 번거로울때...

```bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config 
```

kubeadm명령어 completion
---
```bash
kubeadm completion bash > kubeadm_rc.sh
source kubeadm_rc.sh
````

노드 조인 명령어
---
```bash
master]# export KUBECONFIG=/etc/kubernetes/admin.conf
master]# kubeadm token create --print-join-command
kubeadm join 172.20.132.64:6443 --token p4dyt8.evuhs3qz2k2jdyho --discovery-token-ca-cert-hash sha256:6ec1cd787606d32e5326b4f75a870bbbc311b4962a45c2fcd33f359560ed40c2  
```

```bash
nodeX]# kubeadm join 172.20.132.64:6443 --token p4dyt8.evuhs3qz2k2jdyho --discovery-token-ca-cert-hash sha256:6ec1cd787606d32e5326b4f75a870bbbc311b4962a45c2fcd33f359560ed40c2  
```

kubectl + export KUBECONFIG
---
1. 클러스터 정보(주소 및 포트)
2. 클러스터에 접근 할 사용자
3. 클러스터 인증 시 사용할 TLS

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl(TLS(ADDRESS+PORT))
-------
\
 `---> ~/.kube/config
       SHELL($KUBECONFIG)

```


싱글 마스터 + 인터페이스 명시(API)
---
```bash
kubeadm init --apiserver-advertise-address=192.168.90.250 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16
```

Pod(pause) 컨테이너 [소스코드](
https://github.com/kubernetes/kubernetes/blob/master/build/pause/linux/pause.c)


pod+container 테스트
---

```bash
cat <<EOF> shareprocess-pod-container.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  shareProcessNamespace: true
  containers:
  - name: nginx
    image: quay.io/redhattraining/hello-world-nginx  
  - name: shell
    image: quay.io/quay/busybox
    securityContext:
      capabilities:
        add:
        - SYS_PTRACE
    stdin: true
    tty: true
EOF
kubectl apply -f shareprocess-pod-container.yaml
kubectl attach -it nginx -c shell
```

## 오늘의 목표

1. pod, runc, conmon, pause
2. 쿠버네티스 서비스 확인
3. 쿠버네티스 설치 설명 및 리눅스와 관계(노드 추가)
4. 기본적인 사용 방법




# day 3

- quay.io/redhattraining/hello-world-nginx
- quay.io/centos/centos:stream8
- quay.io/centos7/httpd-24-centos7

### 연습문제 풀이

```bash
kubectl run --image=quay.io/centos/centos:stream8 centos8-stream-test-1
kubectl describe pod/centos8-stream-test-1
kubectl run --image=quay.io/centos/centos:stream8 centos8-stream-test-1 --dry-run=client -o yaml > centos8-command.yaml
nano centos8-command.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pod-centos-8-test
  name: pod-centos-8-test
spec:
  containers:
  - image: quay.io/centos/centos:stream8
    name: container-centos-8
    resources: {}
    command: ["sleep"]
    args: ["10000"]
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```
```bash

kubectl run --image=quay.io/redhattraining/hello-world-nginx nginx-test --dry-run=client -o yaml > nginx-test.yaml
kubectl apply -f nginx-test.yaml
kubectl get pods
nano nginx-test.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-test
  name: nginx-test
spec:
  containers:
  - image: quay.io/redhattraining/hello-world-nginx
    name: nginx-test
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```



```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get pods
kubectl run --image=quay.io/redhattraining/hello-world-nginx test-nginx
kubectl get pod
kubectl run --image=quay.io/centos/centos:stream8 -i --tty --rm test-centos

kubectl run --image=quay.io/redhattraining/hello-world-nginx yaml-nginx --dry-run=client -oyaml > yaml-nginx.yaml


podman run -d -n test-nginx quay.io/redhattraining/hello-world-nginx 

podman generate kube elated_kepler
podman generate kube elated_kepler --filename test-nginx.yaml
kubectl apply -f nginx.yaml

```

vi/nano설정
---

### vi/vim

```bash
master]# cat <<EOF> /$($USER)/.vimrc
au! BufNewFile,BufReadPost *.u{yaml,yml} set filetype=yaml foldmethod=indent
EOF
```

### nano

```bash
master]# curl https://raw.githubusercontent.com/serialhex/nano-highlight/master/yaml.nanorc -o /usr/share/nano/yaml.nanorc

master]# cat <<EOF> /$($USER)/.nanorc
syntax "YAML" "\.ya?ml$"
header "^(---|===)" "%YAML"
set tabsize 2
set tabstospaces
EOF
```

### ale(vim)
```bash
curl -sS https://webi.sh/vim-ale | sh
```


```bash
cat <<EOF> basic-deployment-nginx.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: quay.io/redhattraining/hello-world-nginx
        ports:
        - containerPort: 80
EOF
kubectl create -f basic-deployment-nginx.yaml 
```


설명용
---
```yaml
---
#
# 메타정보
#

apiVersion: apps/v1
kind: Deployment        ## 자원(resource)
metadata:
  name: nginx           ## 자원 이름(deployment, pod)
    labels:             ## 최소 한개 이상 레이블(추후 selector로 사용)
      app: nginx        ## Pod도 위의 이름 사용 "nginx"
      auth: choigookhyun

#
# 컨테이너 생성 및 설정
#
spec:
  replicas: 3                # 복제 개수
    selector:                # replicaset에서 생성 및 관리
      matchLabels:
        app: nginx

  template:                  # replicaset이라는 복제자 자원에서 사용
    metadata:
      labels:
        app: nginx
    
    spec:                      # 컨테이너 사양
      containers:              # 런타임에서 동작하는 컨테이너
      - name: nginx-80            # 컨테이너 이름
        image: nginx:1.14.2    # 컨테이너 이미지
        ports:                 # 컨테이너 포트
        - containerPort: 80    # 추후 svc(service)하고 맵핑
        - containerPort: 82
      - name: nginx-82
        image: nginx
        ports:
        - containerPOrt: 82
```

시험대비
---
https://kodekloud.com/courses/certified-kubernetes-administrator-cka/



```yaml
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-80-8080
        image: quay.io/redhattraining/hello-world-nginx
        ports:
        - containerPort: 80
        - containerPort: 8080
      - image: quay.io/centos/centos:stream8
        name: container-centos-8
        command: ["sleep"]
        args: ["10000"]
        ports:
        - containerPort: 8081
```
#### 연습문제

- quay.io/redhattraining/hello-world-nginx
- quay.io/centos/centos:stream8
- quay.io/centos7/httpd-24-centos7

문제1 문법을 아래와 같이 수정한다.

basic-deployment-nginx.yaml파일을 수정해서 구성한다.

1.  자원의 이름을 nginx에서 apache로 변경한다.
2.  모든 메타정보의 레이블을 nginx에서 apache로 변경한다.
3.  컨테이너 이미지를 quay.io의 아파치로 변경한다.
4.  pod의 갯수는 10개로 변경한다.
5.  올바르게 생성이 되었는지 개수를 확인한다.
6.  pc-app 혹은 default에다가 생성.

문제2 네임스페이스를 아래와 같이 생성한다.

1.  쿠버네티스에서 네임스페이스를 "basic”라는 이름으로 생성한다.
2.  생성된 "basic” 네임스페이스를 기본 네임스페이스로 설정한다.
3.  올바르게 생성이 되면 kubectl get pods 그리고 kubectl config current-context 명령어로 올바르게 전환이 되었는지 확인한다.
4.  해당 네임스페이스 basic-nginx라는 이름으로 nginx pod를 생성한다.

문제3 다음과 같은 이름으로 네임스페이스를 만든다. 만든 후, set-context로 네임 스페이스 변경을 한번씩 한다. 완료가 되면 현재 어떤 네임스페이스에 있는지 get-context으로 확인한다.

1.  hello-namespace
2.  second-namespace
3.  third-namespace
4.  각각 pod에 quay.io/eformat/openshift-vsftpd사용하여 vsftp-server라는 pod를 생성한다.

문제4 run명령어로 아래와 같이 자원을 생성한다.

1.  quay.io의 nginx이미지를 사용한다.
2.  네임스페이스 hello-namespace에 생성한다.
3.  올바르게 생성이 되었는지 확인한다.

pod네트워크 설정(calico)
---

```bash
master]# kubectl expose deployment apache --type NodePort --port=8080 -n pc-app
master]# kubectl create -f https://raw.githubusercontent.com/tangt64/duststack-k8s-auto/master/roles/cni/cni-calico/files/tigera-operator.yaml
master]# curl https://raw.githubusercontent.com/tangt64/duststack-k8s-auto/master/roles/cni/cni-calico/templates/custom-resources.yaml -o /root/custom-resources.yaml
master]# vi custom-resources.yaml
> ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
> registry: quay.io
master]# kubectl apply -f custom-resources.yaml
master]# kubectl get pods --all-namespaces -w
master]# curl localhost:<PORT>
```

# day 4

```bash

   +---------+                   +-------+
   |   POD   |   =============   |  POD  |
   +---------+                   +-------+

```

1. my-nginx-second라는 이름으로 컨테이너 포트 80/TCP로 my-nginx-second디플로이먼트 및 서비스를 ClusterIP로 구성한다.
2. my-nginx-second라는 이름으로 포드 포트는 8500/TCP로 접근이 가능한 디플로이먼트 및 서비스를 NodePort는 알아서 할당.
3. 생성되는 위치는 pc-app에 생성이 된다.

참고
---
```bash
# container port: 8080/tcp
# pod port: 8500/tcp
# node port: 자동 혹은 32676

## 참고용
kubectl create service nodeport --tcp=8080:80 -o yaml --dry-run=client test-httpd > svc-test-httpd.yaml

kubectl run -n pc-app --image quay.io/redhattraining/hello-world-nginx --expose --port 8080 my-nginx-second
kubectl describe -n pc-app pod my-nginx-second

kubectl -n pc-app expose pod my-nginx-second --name my-nginx-second-nodeport --type NodePort --target-port 8080 --port 8500

```


### 컨테이너 보안

[참고자료](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-as-noneroot
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox:1.28
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      allowPrivilegeEscalation: false
```

```bash
kubectl exec -it security-context-demo-2 -- sh
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-as-root
spec:
  securityContext:
    runAsUser: 0
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox:1.28
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /
    securityContext:
      runAsUser: 0
      allowPrivilegeEscalation: true
```


### delete/edit/debug/exec 연습문제

1. 네임 스페이스 willbegone 생성시 레이블 "flag=deleteme"레이블을 같이 할당한다.
2. 네임 스페이스 willbegone에 기존에 사용하던 basic-deployment-nginx.yaml를 사용하여 POD 20개를 생성한다
3. willbegone에 생성되는 모든 Pod에는 레이블 flag=dead를 가지고 있다.
4. apache이미지로 동작하는 debug-me라는 Pod를 생성한다.
quay.io/centos7/httpd-24-centos7

5. debug-me Pod에 다음과 같은 옵션으로 debug를 시도한다. 내부에서 apache프로세서가 보이는지 확인한다. curl명령어로 아파치 서비스 접근을 시도한다. 
--share-process --copy-to=debug-me-copy

6. exec명령어로 basic-deployment-nginx Pod중 하나에 curl명령어로 8080 접근 후 웹 페이지가 잘 뜨는지 확인한다.
7. edit명령어를 사용하여 debug-me에 company=shinhan이라고 추가한다.
8. 작성된 모든 Pod 및 namespace를 삭제한다.




# day 5

