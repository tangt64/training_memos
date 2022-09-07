## VM Gateway Server

USERNAME: cudo1~6

PASSWORD cudo<br/>
URL: ssh://console.dustbox.kr <br/>
PORT: 7722<br/>

## VM DashBoard

URL: https://con.dustbox.kr<br/>
USERNAME: cudo1~6<br/>
PASSWORD: cudouser<br/>

__MEMO URL:__ https://github.com/tangt64/training_memos

## VM ID AND PASSWORD

USERNAME: root
PASSWORD: centos


### 저장소 파일

skt-ansible-intermediate 밑에서 아래 두개 파일 다운로드

* k8s-crio-stable-repository, 
* k8s-libcontainer-stable-repository

확장자 반드시 .repo붙여야 됨.

## 시작

아래서 수행하는 작업은 [master/node1/node2]에서 수행이 되어야 됨.

```bash
# yum install nano tmux 
# vi /etc/hosts             ---> master/node1/node2
<IP> master.example.com master
<IP> node1.example.com node1
<IP> node2.example.com node2

# hostnamectl set-hostname master.example.com
                           node1.example.com
                           node2.example.com

# yum install wget -y
# cd /etc/yum.repos.d/
# wget https://raw.githubusercontent.com/tangt64/training_memos/main/skt-ansible-intermediate/k8s-crio-stable-repository -O  /etc/yum.repos.d/k8s-crio-stable-repository.repo
# wget https://raw.githubusercontent.com/tangt64/training_memos/main/skt-ansible-intermediate/k8s-libcontainer-stable-repository -O /etc/yum.repos.d/k8s-libcontainer-stable-repository.repo
# yum search cri
cri-o.x86_64 : Kubernetes Container Runtime Interface for OCI-based containers
# yum install cri-o -y
# yum repolist
devel_kubic_libcontainers_stable                                      Stable Releases of Upstream github.com/containers packages (CentOS_7)
devel_kubic_libcontainers_stable_cri-o_1.18_1.18.3                    Release 1.18.3 (CentOS_7)
kubernetes                                                            kubernetes repository

# swapoff -a            --> nano /etc/fstab
# setenforce 0          --> nano /etc/selinux/config
# systemctl stop firewalld --> systemctl disable firewalld
# nmcli connection show --> nmcli co sh 
# nmtui                 --> Network Configure Modification command 
# cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
# yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

```
### master
```
# systemctl enable --now kubelet 
# systemctl is-active kubelet
activating
# systemctl -t service 
# systemctl enable crio --now
# kubeadm init 

# cat <<EOF> /etc/sysctl.d/kubernetes-sys.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# sysctl -p --system

# cat <<EOF> /etc/modules-load.d/kubernetes-mod.conf
br_netfilter
overlay
EOF
# systemctl restart systemd-modules-load

# kubeadm init

```

```
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# kubectl get nodes
# kubectl get pods -A
# kubectl get svc -A
# kubectl get deployment -A
```

### 쿠버네티스 초기화

```
# kubeadm reset --force

```

