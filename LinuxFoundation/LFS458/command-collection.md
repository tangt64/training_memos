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
ssh root@192.168.122.135         ## 암호는 kubernetes

curl https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_7/devel:kubic:libcontainers:stable.repo -o /etc/yum.repos.d/libcontainers.repo
curl https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.28:/1.28.1/CentOS_7/devel:kubic:libcontainers:stable:cri-o:1.28:1.28.1.repo -o /etc/yum.repos.d/crio.repo
yum repolist
yum search cri-o
yum install cri-o -y
```
# DAY 2
# DAY 3
# DAY 4