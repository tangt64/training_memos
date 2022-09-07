
__EMAIL:__ bluehelix@gmail.com
__NAME:__ CHOI GOOK HYUN

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

```


### 노드 조인하기

```
master# kubeadm token list
master# kubeadm token create --print-join-command
kubeadm join 192.168.90.171:6443 --token fkv0uf.2bzmt3rsu3ppa3lx --discovery-token-ca-cert-hash sha256:2fde3b6a891973ed7073a998385e1363eb9f38c67bd92ca24ec9ee5540004730


nodeX# kubeadm join 192.168.90.171:6443 --token fkv0uf.2bzmt3rsu3ppa3lx --discovery-token-ca-cert-hash sha256:2fde3b6a891973ed7073a998385e1363eb9f38c67bd92ca24ec9ee5540004730

master# kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
master.example.com   Ready    control-plane   52m   v1.24.3
node1.example.com    Ready    <none>          49m   v1.24.3
```


### 테스트 하기

https://kubernetes.io/docs/tutorials/hello-minikube/

```
master# mkdir -p $HOME/.kube
master# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
master# kubectl get nodes
master# kubectl get pods -A
master# kubectl get svc -A
master# kubectl get deployment -A
```

```
master# kubectl apply -f https://k8s.io/examples/service/load-balancer-example.yaml
master# kubectl get pods
master# kubectl get svc  --> pending때문에 외부에서 접근이 안됨
master# kubectl edit svc/hello-world
master# kubectl expose deployment hello-world --type=LoadBalancer --name=my-service
master# curl localhost:8080

```
### 쿠버네티스 초기화

```
# kubeadm reset --force

```

