# kube-virt installation 

1. 쿠버네티스 설치
2. CNI네트워크 설치 및 구성(ovs, multus상관 없음)
3. 최소 한 개의 CSI인터페이스 구성(local, NFS)

```bash
virt-host-validate qemu
virt-host-validate

export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
kubectl -n kubevirt wait kv kubevirt --for condition=Available
```