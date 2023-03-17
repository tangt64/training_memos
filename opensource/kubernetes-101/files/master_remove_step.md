# 마스터 노드 안전하게 제거 방법

장비 및 절차 문제로 구현이 잘 되지 않았던 멀티 마스터 제거 부분에 대해서 정리.



1. 제거할 마스터 서버가 더 이상 작업을 받지 않도록 스케줄러를 중지한다.

2. 스케줄러가 중지하면, 안전하게 etcd 맴버에서 master2, master3를 제외한다.

3. 제외가 되면 node delete로 노드를 제거한다.

4. drain은 실제로 마스터 노드에서 할 이유는 없다. 대다수 마스터는 DeamonSet기반으로 이미 자원을 구성 및 사용을 하고 있기 때문에, Pod 재구성이 필요 없다.
   
   

## 명령어

```bash
kubectl exec -n kube-system etcd-master.example.com -- etcdctl  --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/peer.crt --key /etc/kubernetes/pki/etcd/peer.key member list
kubectl exec -n kube-system etcd-master.example.com -- etcdctl  --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/peer.crt --key /etc/kubernetes/pki/etcd/peer.key member remove <ID>


kubectl get nodes
kubectl cordon master2.example.com
kubectl drain master2.example.com
kubectl cordon master3.example.com
kubectl drain master3.example.com
kubectl delete node master2.example.com
kubectl delete node master3.example.com

```

```bash
## 마스터 노드 구성
kubeadm init --apiserver-advertise-address=192.168.90.110 \
 --control-plane-endpoint 192.168.90.110 \
 --cri-socket=/var/run/crio/crio.sock \
 --upload-certs \
 --pod-network-cidr=192.168.0.0/16 --service-cidr=10.90.0.0/16 \
 --service-dns-domain=devops.project


## 컨트롤 마스터 추가

kubeadm init phase upload-certs --upload-certs   ## kube-system configmap에 저장
kubeadm token create --certificate-key <KEY_ID> --print-join-command
kubeadm join --control-plane --certificate-key


kubeadm join 192.168.90.110:6443 --token yspx54.k2076yehis972cng \
        --discovery-token-ca-cert-hash sha256:4743574ead43b14374be00496294bcb5ee85a3967724c0c3464ca9dcb576fb27
```
