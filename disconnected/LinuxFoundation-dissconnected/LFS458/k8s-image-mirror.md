```bash
kubeadm config images list

## k8s-fundamental images list
cat <<EOF> k8s-images.txt
registry.k8s.io/kube-apiserver:v1.27.6
registry.k8s.io/kube-controller-manager:v1.27.6
registry.k8s.io/kube-scheduler:v1.27.6
registry.k8s.io/kube-proxy:v1.27.6
registry.k8s.io/pause:3.9
registry.k8s.io/etcd:3.5.7-0
registry.k8s.io/coredns/coredns:v1.10.1
EOF

skopeo copy  docker://registry.k8s.io/kube-apiserver:v1.27.6 docker-archive:kube-apiserver-v1.27.6.tar:registry.k8s.io/kube-apiserver:v1.27.6


```