연습문제

* 컨테이너 서비스를 POD기반으로 구성한다.

quay.io/eformat/openshift-vsftpd
quay.io/centos7/nginx-116-centos7

run -d --pod new: -p :8080 -p 21100
run -d --pod 
buildah bud -f 
podman generate
podman play 
kubectl get pods/svc
kubectl create
KUBECONFIG=/etc/kubernetes/admin.conf

1. 웹 서비스 아파치로 구성한다. 포트는 이미지에서 명시한 기본포트 8080를 사용한다.
2. ftp서비스를 구성한다. 포트는 이미지에서 명시한 기본포트 21100를 사용한다.
3. pod의 이름은 www_svc으로 구성한다.
4. mysql 서비스를 위한 컨테이너를 구성한다. 
5. 쿠버네티스에는 pv, pvc가 없기 때문에 바인딩을 사용해서는 안된다. 
6. centos7이미지 기반으로 mysql컨테이너 이미지를 빌드한다. 포트는 3306를 사용한다. 
```
from quay.io/centos/centos
run yum install <PACKAGE> -y && yum clean all
expose 3306
cmd mysqld_safe
```
8. 구성된 서비스를 쿠버네티스로 전환한다.
9. 쿠버네티스로 서비스가 전환이 완료가 되면, yaml파일으로 모든 서비스를 동시에 중지한다.
