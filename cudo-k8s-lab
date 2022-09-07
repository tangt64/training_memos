## VM Gateway Server
----------------------
cudo1~6, cudo
  ID          PW

ssh://console.dustbox.kr, port: 7722


## VM DashBoard
-----------------
https://con.dustbox.kr

cudo1~6, cudouser
  ID        PW

https://github.com/tangt64/training_memos

## VM ID 

root/centos


'''
-> skt-ansible-intermediate ->  k8s-crio-stable-repository, 
                                        k8s-libcontainer-stable-repository  -> RAW -> URL COPY
'''
## 시작

아래서 수행하는 작업은 [master/node1/node2]에서 수행이 되어야 됨.

'''bash
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
# wget https://raw.githubusercontent.com/tangt64/training_memos/main/skt-ansible-intermediate/k8s-crio-stable-repository -O  k8s-crio-stable-repository.repo
# wget https://raw.githubusercontent.com/tangt64/training_memos/main/skt-ansible-intermediate/k8s-libcontainer-stable-repository -O k8s-crio-stable-repository.repo
# yum search cri
cri-o.x86_64 : Kubernetes Container Runtime Interface for OCI-based containers
# yum install cri-o -y

# swapoff -a            --> nano /etc/fstab
# setenforce 0          --> nano /etc/selinux/config
# systemctl stop firewalld
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
# systemctl enable --now kublet 
'''
