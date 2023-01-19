# day 1

강사: 최국현

메일: tang@linux.com

과정은 "쿠버네티스 설치+간단한 명령어 운영"

### 내부 ISO내려받기 주소

http://172.16.8.31/


## 랩을 위한 필요한 도구

### 리눅스 배포판 설명

#### WSL2(필요하신 경우)

```powershell
wsl --install
wsl 
```

CentOS-Stream-9의 WSL2은 아래에서 내려받기 가능.

<WSL2 내려받기>(https://github.com/mishamosher/CentOS-WSL/releases)


#### 내부 PoC용도로 다음처럼 구성

1. H/A부분(LB)
  - Master x 3EA 
  - 이번 교육에서는 이 부분은 제외
  	* HAProxy, Nginx(선호) 
  	  + Kubernetes Metal Loadbalancer(SaaS)
  	* Keepalive 
  	* Pacemaker 

2. 스케일링 부분
  - 'kubeadm'명령어로 노드 추가(controller, worker)
  - ansible, terraform기반으로 확장
    * ansible 많이 선호
3. 보안
  - 쿠버네티스 사용자(ldap)
  - SELinux 공식적으로는 지원하지 않음
    * setenforce 0
  - 반드시 설치 전 swap이 꺼져있어야 됨
    * cgroup기반으로 메모리 사용량 측정시 문제
    * 추후에는 swap도 지원할 예정

4. 네트워크
  - RHEL 8/9
  - iptables는 더 이상 사용하지 않음
  - nftables(nft)
  - firewalld가 기본 방화벽
    * firewalld, nftables 사용 안하셔도 됨
    * POD + SVC = S/D NAT ==> nftables, firewalld
    * firewall-cmd명령어 학습
    * nft명령어 학습

5. 런타임
  - containerd
  - cri-o
  - cri-docker(needs compiling)

__네트워크__

외부 네트워크: NAT, eth0
내부 네트워크: API, eth1
+ 스토리지 네트워크
+ 백업/ingress 네트워크
+ 관리 네트워크

__마스터 1개__
  - vcpu 2개(1 O/S, 1 runtime)
  - vmem 4096MiB(8192MiB)
  - vdisk 13GiB(50~80GiB)
 
__워커노드 2개__
  - vcpu 2개(1 O/S, 1 runtime)
  - vmem 4096MiB(8192MiB)
  - vdisk 13GiB(50~80GiB)


#### 레드햇 계열

__centos-stream:__ https://www.centos.org/centos-stream/
__rocky linux:__ https://rockylinux.org/ko/download


#### OCI

1. 본래는 그냥 'docker'명령어로 전부 해결이 되었음
  - docker build   ---> buildha
  - docker search  ---> skopeo
  - docker run     ---> crio, containerd(standard)
  - docker volume  ---> csi
  - docker network ---> cni

``` bash
Fedora Core(upstream(rolling)) --- CentOS(upstream) --- RHEL(downsteam)
                                   ------               -----
                                    \                     \
                                     \                     `---> Rocky Linux
                                      \
                                       `---> CentOS-Stream(EOL,EOS 3 years)

            
```
__데비안 계열__
```bash
Debian --- stable
       \   ------
        \   \  
         \   `---> Ubuntu stable
          \
           `---> unstable
                 --------
                 \
                  `---> Ubuntu(bugfix)
```
* Debian Linux: 권장은 데비안 리눅스
* Ubuntu: 비권장
  - ".deb"패키지의 고질적인 질병(?)중 하나가, 의존성 검사가 상대적으로 약함
  - 이전에는 지원이 안됨, 현재는 지원합니다. 


- 하이퍼브이
  * overcommit 지원이 안됨
  * nested 

- 버추얼박스
  * Intel
  * AMD(오동작)

- VMware Workstation, Player
  * 라이센스 문제

## 쿠버네티스 설치 준비

1. 쿠버네티스는 A레코드에 민감하다.
  - IP <---> DNS A Recode
  - DNS(bind9)에 'IN A' 구성 및 선언
  - /etc/hosts
    * 192.168.90.100 master1.example.com
    * 192.168.90.120 node1.example.com
    * 192.168.90.130 node2.example.com
  - swap off가 필요

```bash
vi /etc/hosts
192.168.90.100 master1.example.com
--------------
    <eth0>
#192.168.90.130 node1.example.com
#192.168.90.140 node2.example.com

swapon -s
swapoff -a
vi /etc/fstab
#/dev/mapper/cs-swap     none                    swap    defaults        0 0

systemctl stop firewalld
```
## kubernetes 저장소 및 설치 준비
```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# permissive 모드로 SELinux 설정(효과적으로 비활성화)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes ## 업데이트 장애 방지
systemctl enable --now kubelet ## 'activing..'

firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=10250/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all --zone=public
systemctl stop firewalld
```
## netfilter 참고 그림
```bash
  .----netfilter----.
 /                   \
iptables ---> nftables <---> <backend> <--- firewalld
  \                           /
   `-------------------------'
       [kernel parameter]
```

## 커널 파라메타 정보 수정 및 모듈 추가
```bash

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

systemctl daemon-reload  ## dracut 정보갱신
dracut -f                ## 램-디스크 강제 재생성
```

### CRIO(centos-9-stream) 기반 설치

```bash
cd /etc/yum.repos.d/
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable.repo
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable_cri-o_1.24_1.24.4.repo
dnf search cri-o 
dnf install cri-o
systemctl enable --now crio
kubeadm init 
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes
```

## containerd 기반 설치 
```bash
dnf install epel-release -y ## 선택사항
dnf search containerd
dnf install yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf repolist

dnf install containerd -y
containerd config default > /etc/containerd/config.toml
systemctl enable --now containerd
systemctl is-active containerd
kubeadm init
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes
```

## node1 구성

```bash
hostnamectl set-hostname node1.example.com

vi /etc/hosts
172.29.220.234 master1.example.com   ## eth0, ip addr show eth0
172.29.210.238 node1.example.com
               node2.example.com

cd /etc/yum.repos.d/
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable.repo
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/devel_kubic_libcontainers_stable_cri-o_1.24_1.24.4.repo
wget https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/kubernetes.repo
swapon -s
swapoff -a
vi /etc/fstab
#/dev/mapper/cs-swap     none                    swap    defaults        0 0

systemctl stop firewalld && systemctl disable firewalld

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes 
systemctl enable --now kubelet 


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

systemctl daemon-reload  ## dracut 정보갱신
dracut -f                ## 램-디스크 강제 재생성

dnf search cri-o 
dnf install cri-o
systemctl enable --now crio


@master]# kubeadm token create --print-join-command
kubeadm join 172.29.220.234:6443 --token ja57hx.4n6g9cbnmcqxjrxk --discovery-token-ca-cert-hash sha256:fa772f99cd9b5385ae3bd9f2fbb3f7f85ec75ed9faf6ddf35540a93e1e3f2c7c
@node]# kubeadm join 172.29.220.234:6443 --token ja57hx.4n6g9cbnmcqxjrxk --discovery-token-ca-cert-hash sha256:fa772f99cd9b5385ae3bd9f2fbb3f7f85ec75ed9faf6ddf35540a93e1e3f2c7c

```

# day 2

## 단순설치(master + two nodes, one node)
- kubeadm init, join
  * master(init), node(join)
- @master]# kubectl get nodes 
- cluster=control+worker 


1. runtime

kubectl ---> crictl 

```bash
dnf install cri-o
            -----
            \
             `---> /etc/containers/


  crictl ps               .---> crictl pods ls
    ^                    /
    |                +---+
+-----------+        | P |                                      
| APP + LIB |  ----  | O |   <--- [CRIO] ---> |  kubelet  |    <---    [kubeadm init] 
| container |  ----  | D |                      <systemd>                image pull
+-----------+        +---+                          

                    | kubeproxy |   <--- | kubelet |  <--- <kubectl>
                    +-----------+
                          \
                           '---> netfilter(linux bridge, namespace)
                                 runtime interactive 
```

coredns: 쿠버네티스 내부의 pod끼리 서로 통신을 할수가 없음. 서비스 통신시에 매우 중요.

런타임은 컨테이너 라이프 사이클를 관리하는 도구
- cri-o(recommend)
  * client tool: crictl 
  * pod, container

- containerd
- cri-docker

### bash 자동완성
```bash
kubectl completion bash > k8sbash
source k8sbash
```

### fish 자동완성
```bash
dnf install fish -y
fish 
chsh 
kubectl completion fish > k8sfish
source k8sfish
```


기본 노드들 구성이 완료가 되면, 아래 명령어로 네트워크 생성 및 구성

### calico
calico기반으로 pod네트워크 구성

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/calico-quay-crd.yaml
```

### flannel

docker.io를 사용하기 때문에 사용하지 않을 예정
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
```

'flanned' 경우에는 버그가 있음. 아래 내용대로 수정이 필요함
```bash
https://github.com/flannel-io/flannel/issues/728
```

```bash
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/mysql-wordpress-pd/local-volumes.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/mysql-wordpress-pd/mysql-deployment.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/mysql-wordpress-pd/wordpress-deployment.yaml
```


# day 3


### 멀티 마스터 구성(rocky linux)


__master1(24시간 안에는 유효, bootstrap node)__

- control-plane-endpoint
'master끼리 서로 정보를 주고 받을때 사용하는 아이피 주소'. 아이피 주소는 보통은 'Loadbalancer(l4/l7)'
ex: --control-plane-endpoint 192.168.90.250(192.168.10.0.1/2/3/4/5)

- upload-certs
공개 인증서 etcd서버에 업로드. master설치시 인증서 전달 및 제공.

- apiserver-advertise-address
'master, worker'가 API를 전달 받는 인터페이스.

**nic카드는 최소 2장**

```bash
@master1]# kubeadm init --control-plane-endpoint 192.168.90.100 --upload-certs --apiserver-advertise-address 192.168.90.100 --pod-network-cidr=192.168.0.0/16 --service-dns-domain=tmax.project --image-repository=192.168.90.250/

@master1]# kubeadm init --apiserver-advertise-address 192.168.90.100 --pod-network-cidr=192.168.0.0/16 --upload-certs 

```

__24시간 이후__
```bash
@master1]# kubeadm certs certificate-key   ## 마스터 노드에서 사용할 cluster TLS
@master1]# kubeadm init phase upload-certs --upload-certs ## 인증서를 etcd에 저장. 다른 마스터 노드가 연결시 내려받기 함
@master1]# kubeadm token create --print-join-command
kubeadm join 192.168.90.100:6443 --token hhjg3n.nmfs94gop1aeom0n --discovery-token-ca-cert-hash sha256:01e7f7dee3594c99fa1cb50ad20f3b0b6e1f74d2afaf5f5dc1892bc1b6f247b1 "--control-plane --certificate-key 8dc065689de5eb04b57f5538d46bcda977df33b586bcbf4b922fd676eeb0d41e"
@master2]# kubeadm join 192.168.90.100:6443 --token hhjg3n.nmfs94gop1aeom0n --discovery-token-ca-cert-hash sha256:01e7f7dee3594c99fa1cb50ad20f3b0b6e1f74d2afaf5f5dc1892bc1b6f247b1 \ 
  --control-plane \ 
  --certificate-key 8dc065689de5eb04b57f5538d46bcda977df33b586bcbf4b922fd676eeb0d41e
```


__nginx.yaml__
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```bash
kubectl create -f nginx.yaml
kubectl expose deploy nginx-deployment --type loadbalancer --external-ip 172.29.220.234
```

```bash
cat << EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
```

bash completion(minial installation)
```bash
dnf install bash-completion -y && complete -r -p && source k8sbash
bash
complete -r -p && source k8sbash

```

### ifconfig vs ip, netstat vs ss

ifconfig: namespace 장치 지원 안함.
ip: namespace 장치

netstat: namespace (x)
route ---> ip r(oute)

# day 4


## metric service

```bash
kubectl create -f https://raw.githubusercontent.com/tangt64/training_memos/main/opensource/kubernetes-101/metrics.yaml
kubectl get pods
kubectl top pods
kubectl top nodes
```

.vimrc(yamllint + ale)
```bash
dnf install yamllint vim -y 
yum install epel-release -y
yum install neovim fish -y 
yum install yamllint tmux -y 
alias vim="nvim"
alias vi="nvim"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
mkdir ~/.config/nvim/


```

~/.config/nvim/init.nvim
```
"Plug list
call plug#begin()
" fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" airline
Plug 'vim-airline/vim-airline'     " vim status bar
" git
Plug 'airblade/vim-gitgutter'      " git change status
Plug 'tpope/vim-fugitive'          " vim git wrapper
" tree
Plug 'scrooloose/nerdtree'         " tree plugin for vim
Plug 'Xuyuanp/nerdtree-git-plugin' " nerd tree git plugin
" search
Plug 'ctrlpvim/ctrlp.vim'          " ctrl p search
" auto pair
Plug 'jiangmiao/auto-pairs'        " pairs quotes or braket
" dev icon
Plug 'ryanoasis/vim-devicons'      " dev icons for vim
" tagbar
Plug 'majutsushi/tagbar'           " browse tag plugin
" ale linter
Plug 'w0rp/ale'

" javascript
Plug 'pangloss/vim-javascript'

" typescript
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'

" indent
Plug 'Yggdroot/indentLine'

" smooth scroll
Plug 'terryma/vim-smooth-scroll'

" multi cursor
Plug 'terryma/vim-multiple-cursors'

" coc.nvim
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" vim surround
Plug 'tpope/vim-surround'

" vim theme
Plug 'mhartington/oceanic-next'

Plug 'dense-analysis/ale'
Plug 'Yggdroot/indentLine'
Plug 'pedrohdz/vim-yaml-folds'

call plug#end()

" Vim Config
set number
set ai
set si
set shiftwidth=2
set tabstop=2
set ignorecase
set hlsearch
set expandtab

"" NERD Tree Config
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

"" Ctrl+n NERD Tree Toggle
map <C-t> :NERDTreeToggle<CR>

" hidden file show tree
let NERDTreeShowHidden=1

"" Ctrl p ignore list
let g:ctrlp_custom_ignore = {
\ 'dir':  '\.git$\|public$\|log$\|tmp$\|vendor$\|node_modules$',
\ 'file': '\v\.(exe|so|dll)$'
\ }


set encoding=UTF-8

"" easir window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

"" Indentation rules
augroup vimrc-javascript
  autocmd!
  autocmd FileType javascript set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType vue set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType jsx set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType tsx set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType typescript set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType less set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType scss set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType html set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
  autocmd FileType css set tabstop=2|set shiftwidth=2|set expandtab softtabstop=2 smartindent
augroup END

"" Git
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gr :Gremove<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gd :Gvdiff<CR>

"" ale linters
let b:ale_linters = {
 \ 'javascript': ['eslint'],
 \ 'typescript': ['eslint']
 \}

let g:ale_javascript_eslint_use_global = 1
let g:ale_javascript_eslint_executable = 'eslint_d'

"" ale fixers
let b:ale_fixers = {
\ '*': ['remove_trailing_lines', 'trim_whitespace'],
\ 'javascript': ['eslint'],
\ 'tsx': ['eslint'],
\ 'typescript': ['eslint']
\}

let g:ale_fix_on_save = 1

autocmd BufWritePost *.ts,*.tsx,*.js,*.jsx,*.scss ALEFix eslint

" indent line
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" Or if you have Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif


" For Neovim 0.1.3 and 0.1.4
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Theme
syntax enable
colorscheme OceanicNext

let g:airline_theme='oceanicnext'


set foldlevelstart=20

let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'never'
```


.nanorc
```bash

# Supports `YAML` files
syntax "YAML" "\.ya?ml$"
header "^(---|===)" "%YAML"

## Keys
color magenta "^\s*[\$A-Za-z0-9_-]+\:"
color brightmagenta "^\s*@[\$A-Za-z0-9_-]+\:"

## Values
color white ":\s.+$"
## Booleans
icolor brightcyan " (y|yes|n|no|true|false|on|off)$"
## Numbers
color brightred " [[:digit:]]+(\.[[:digit:]]+)?"
## Arrays
color red "\[" "\]" ":\s+[|>]" "^\s*- "
## Reserved
color green "(^| )!!(binary|bool|float|int|map|null|omap|seq|set|str) "

## Comments
color brightwhite "#.*$"

## Errors
color ,red ":\w.+$"
color ,red ":'.+$"
color ,red ":".+$"
color ,red "\s+$"

## Non closed quote
color ,red "['\"][^['\"]]*$"

## Closed quotes
color yellow "['\"].*['\"]"

## Equal sign
color brightgreen ":( |$)"


set tabstospaces
set autoindent
set linenumbers
set tabsize 

```

## replicaset

```            
                           .-------------.
                          /               \
                   +------------+      +-----+
   | deploy | ---> | replicaset | ---> | POD |
              <--  +------------+      +-----+
                         |
                         v
                       <HPA>  ---> POD자원이 한계치에 다다르면 수평적인 생성을 시작
                       <VPA>  ---> POD자원이 한계치에 다다르면 수직으로 확장을 시작
```

1. label/selector 기반
2. deployment서로 상호관계
3. replicaset만 사용도 가능은 함

quay.io/centos7/httpd-24-centos7:latest
quay.io/redhattraining/hello-world-nginx:latest

                      RBAC

                                    <ingress>
                                       /
                                    role
                                     /
                                  [SA]
                                   |
                  namespace <--- role ---> user(testuser)
                  (project)
                     |
                     |
                     v
                   [POD]

# 참고자료
[오퍼레이터 가이드, 쿠버네티스](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/#writing-operator)
[오퍼레이터 SDK](https://sdk.operatorframework.io/docs/overview/)
[명령어 가이드](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run)

[한국어 에코 설명](https://blog.siner.io/2021/10/23/container-ecosystem/)

[OCI 사양 설명](https://medium.com/@avijitsarkar123/docker-and-oci-runtimes-a9c23a5646d6)	

[OCI 사양](https://github.com/opencontainers/distribution-spec/blob/main/spec.md)

[RKT, Rocket](https://en.bmstu.wiki/index.php?title=Rocket_%28rkt%29&mobileaction=toggle_view_desktop)

[DevSecOps(Legacy Ver)](https://devopedia.org/container-security)

[Kubernetes Containerd Integration Goes GA](https://kubernetes.io/blog/2018/05/24/kubernetes-containerd-integration-goes-ga/)


[Openshift vs Kubernetes](https://spacelift.io/blog/openshift-vs-kubernetes)
