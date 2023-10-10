# DAY1

## 강사 정보

- __이름:__ 최국현
- __메일주소:__ tang/앙/linux.com
- __점심시간:__ 
- __쉬는시간:__ 

> https://github.com/tangt64/training_memos/
> LinuxFoundation/

__메모 주소:__ [링크](https://github.com/tangt64/training_memos/blob/main/LinuxFoundation/)

## Registration Link

__주소:__ [등록링크](https://linux.thoughtindustries.com/redeem)

__코드:__ lfs458fastlanekorea20231010

## Course Survey Link 

__주소__: [서베이 주소](https://www.surveymonkey.com/r/KK7Z3SR?course=LFS458_20231010_PART_VIRT_FASTLANEKOREA)


### 쿠버네티스/런타임 소개

CSI: Container Storage Interface (CSI) Specification 
> NFS(nfs 4.x(pnfs, ganesha-nfs))
> san/nas
> shared type FS

CNI: Container Network Interface
> vxlan, geneve, vlan...
> flanned, calico...

OCI: Open Container Initiative
> Runtime Specification (runtime-spec), 
> the Image Specification (image-spec, docker-image --> OCI Image) 
>> Dockerfile --> Containerfile
>> docker build Dockefile --> buildah bud 
> Distribution Specification (distribution-spec). 
>> /var/lib/containers/
>> /run/containers/
> The Runtime Specification outlines how to run a “filesystem bundle” 
>> Overlay2 Filesystem

CRI: Container Runtime Interface
1. docker-shim(cri-docker, keyword: docker-cri) 
2. CRI-O
> Google, IBM/Redhat, SuSE
3. containerd(CRI adapter, standard container runtime) 


https://www.ianlewis.org/assets/images/768/runtimes.png


```bash
dnf install epel-release -y
dnf search tmux
dnf install tmux -y
vi ~/.tmux.conf
> set -g mouse on
dnf search podman                                          ## podman container engine
dnf install podman podman-compose podman-docker -y
systemctl enable --now podman                            ## podman.service for API
podman pod ls
podman container ls
ps -ef | grep podman
ps -ef | grep runc

podman run -d --name httpd quay.io/centos7/httpd-24-centos7 

cd /var/lib/containers/
> stoage
podman container ls
cd overlay-containers
ls -l 
> [CONTAINER_ID_DIRECTORY]
ps -ef | grep httpd
ps -ef | grep conmon
lsns
```

CR: deployment, replicaset, pod...
CRD: configmap, secret...

### 랩 설치 준비

[설치 명령어 모음](https://raw.githubusercontent.com/tangt64/training_memos/main/LinuxFoundation/LFS458/command-collection.md)

```bash
setenforce 0
hostnamectl set-hostname bare.cka.example.com
dnf install git ansible -y
git clone https://github.com/tangt64/duststack-k8s-auto.git
cd duststack-k8s-auto
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
vi /etc/ssh/sshd_config
> PermitRootLogin yes

systemctl reload sshd
ssh-copy-id root@127.0.0.1

vi playbooks/lab-provisioning.yaml
> remote_user: tang --> root
./provin-k8s.sh

virsh list
> k8s_utility_node
virsh domifaddr 40 
virsh domifaddr k8s_utility_node
> 192.168.122.135/24
ssh root@192.168.122.200                                             ## 암호는 kubernetes

curl https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_7/devel:kubic:libcontainers:stable.repo -o /etc/yum.repos.d/libcontainers.repo
curl https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.28:/1.28.1/CentOS_7/devel:kubic:libcontainers:stable:cri-o:1.28:1.28.1.repo -o /etc/yum.repos.d/crio.repo
yum repolist
yum search cri-o
yum install cri-o -y

systemctl enable --now crio

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

kubeadm init 

export KUBECONFIG=/etc/kubernetes/admin.conf

kubeadm init --apiserver-advertise-address=192.168.90.200 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16 

kubeadm token create --print-join-commnad

1. /etc/hosts(node2)
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.90.200 master.example.com master
192.168.90.250 node2.example.com node2

2. hostnamectl set-hostname node2.example.com

nodeX]# kubeadm join 192.168.90.200:6443 --token etyc27.bx82vp6zyfx83wc4 --discovery-token-ca-cert-hash sha256:8eba1a36e4c528ea60b6942b6abe1a52b0cf06aa70892eb61a289e78906857da 
```
# DAY 2
# DAY 3
# DAY 4