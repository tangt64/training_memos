# BOOTCAMP, DO288 - Red Hat OpenShift Developer II: Building Kubernetes Applications

## 랩

메모파일 위치
---
https://github.com/tangt64/training_memos/
>redhat/DO288/20230602-memo-serim.md

1. 레드햇 개발자 계정
2. RHEL, Code Ready Container, IDE...

https://rol.redhat.com    ## 이 주소로 접근 부탁 드립니다.


## RHEL
- root/redhat
- student/student

## OCP
- developer/developer
- admin/redhat

**가상머신은 "workstation"만** 사용합니다.

**student/student** ## 이 계정에서 모든 랩을 진행 합니다.


Kubernetes에서는 ingress라고 부름
- nginx, TCP
- haproxy, TCP/IP
- kubernetes-ovn

오픈시프트에서는 'route'라고 부름
- haproxy + service(svc, kubernetes)
- 추가적으로 쿠버네티스 ingress도 지원
- kubernetes-ovn


## 자원 정리

OpenShift Origin: VM기반
OpenShift Origin --> OKD: Container기반(판매용은 Openshift Kubernetes Engine)

- OKD는 내부적으로 PoC혹은 테스트용도로 충분
- 단점이라고 하면, 버전 고정이 안됨(rolling-update)

namespace
---
1. 시스템 영역(리눅스 커널에서 격리)
2. 쿠버네티스에서 추상적으로 격리
3. 오픈시프트는 이걸 한번 더 "project"라고 변경

OCP
---
1. namespace --> 시스템 영역 자원(operator)
- 템플릿 혹은 이미지 스트림

2. project   --> 사용자 영역 자원(container application)
- pv, pvc, secret
- oc project 

label/selector
---
기본적으로 같은 자원.

1. Deployment/ReplicaSet
2. 기존은 DeploymentConfig(dc), ReplicationController  ## 더 이상 사용하지 않음
3. 위의 두 개의 큰 차이점은, 단일 선택이냐 혹은 복합적인 선택(레이블)
4. 초기 쿠버네티스는 RC(ReplicationController)만 있었음.

label: 선언을 하는 부분이 레이블
selector: 선언된 자원을 선택하는 영역

```yaml
- apiVersion: apps/v1
  metadata:
    name: testapp
    labels:
      name: testapp
      version: v1

  specs:
  template:
    selector:
      name: testapp
      version: v1
```

## 쿠버네티스 리소스 정리

OCP == kubernetes(CR) + OCP(CR+CRD)

io.kubernetes: 코어 API 컴포넌트
io.openshift: 확장 API 컴포넌트

BuildConfig(bc): OCP의 확장 기능. 이 부분이 개발자 분들이 제일 접근하는 영역. 이미지 + 소스코드 빌드가 발생. CI/CD PIPE
ImageStream(is): 이미지 저장소. docker-registry. 이미지 레지스트리. 특정 프로젝트(네임스페이스)에서 빌드된(bc) 이미지를 저장하는 위치. 다른 이름으로 internal registry라고 부르기도 함. 
route: 본래 쿠버네티스에서는 'ingress'라고 부름. DNS서버와 연동이 되어서 애플리케이션 도메인을 자동으로 구성 및 할당(wildcard domain). L/B 및 A/B, Blue/Green와 같은 기능을 제공. 카나리아(Canary)기능을 사용하기 위해서는 라우트(route)가 필요. 


쿠버네티스는 nodeport, externalip, externaldns를 통해서 접근. 개발자가 빠르게 확인이 어려운 부분이 있음. 

[카나리아 동작방식](https://developer.harness.io/docs/continuous-delivery/deploy-srv-diff-platforms/kubernetes/kubernetes-executions/create-a-kubernetes-canary-deployment/)


## 애플리케이션 배포

```bash
kubectl run <IMAGE>
        create <YAML>

oc      run
        create
        new-app   <TEMPLATE_기반>     

oc login -u developer -p developer https://api.ocp4.example.com:6443

oc new-app https://github.com/RedHatTraining/DO288/tree/main/apps/apache-httpd            
```


간단하게 테스트

```bash
## workstation student계정
## 
oc login -u admin -p redhat            ## 개발자 계정이 잘 안되시면
git clone https://github.com/RedHatTraining/DO288-apps
cd DO288-apps/php-helloworld
ls -l 
> index.php                            ## buildah 이미지를 빌드(dockerfile, container)
oc new-app .                           ## php-template를 사용해서 애플리케이션 빌드(이미지+소스코드)
oc get bc                              ## 쿠버네티스에는 해당 CR은 없음
```
is(docker-registry)+quay.io

is + habor + gitlab

IS: 네임스페이스 안에서 빌드된 이미지를 저장
외부: Quay.io 혹은 Habor.io 통해서 외부 이미지 레지스트리 구성


```bash
oc get is                              ## imagestream 확인
oc get is -n openshift                 ## 'openshift'가 공용 프로젝트
oc get templates -n openshift | grep php
oc get bc
oc get rs
oc get deploy
oc get pod

    .----------------------- OCP -----------------------------------.
   /                                                                 \
## git(source) --> build-start --> (source+image) --> bc(POD(source+image)) --> deployment --> replicaset --> pod


oc new-app --docker-image              ## 템플릿을 참조
kubectl run --image                    ## 기본 deploy설정 구성

oc new-app php~http://gitserver.example.com/mygitrepo
           wildfly~http://
           ruby~http://
           python~http://

```

오픈시프트 Dockerfile, Container 두가지 지원. **Dockerfile**은 앞으로 사용하지 않을 예정. 표준으로 **Containerfile**이름으로 사용.

docker-ce/ee: 개발중지 --> cri-docker
- podman으로 이전 권장
- 이미지 빌드는 buildah기반으로 이미지 빌드
- 이미지 미러링/복사 그리고 확인은 skopeo.

```bash
dnf install podman
podman run -d --name httpd-k8s httpd
podman container ls
podman pod ls
podman generate kube httpd-k8s --service --filename httpd-k8s.yaml
oc create -f httpd-k8s.yaml
oc new-app <GIT_URL>
```


```yaml
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
```

openshift POD 형식

- [init pod](https://docs.openshift.com/container-platform/4.13/nodes/containers/nodes-containers-init.html
)

>OpenShift Container Platform provides init containers, which are specialized containers that run before application containers and can contain utilities or setup scripts not present in an app image.

- deploy pod

- [build pod](https://docs.openshift.com/container-platform/4.13/cicd/builds/creating-build-inputs.html)
>


## 애플리케이션 컨테이너화

바이너리 + 라이브러리를 이미지화

컨테이너 이미지: centos, rhel(ubi), ubuntu, suse
- 본래는 컨테이너에 배포판은 의미가 없음.
- 라이브러리나 혹은 특정 바이너리 위치가 다름.
  + LD LINK, 바이너리 호출
  + LD_PATH에서 계속 지속적으로 문제가 발생
- OS템플릿 기반으로 구성된 이미지를 사용
- 바이너리 및 라이브러리 구성
- init 1번에 대한 이슈

https://github.com/Yelp/dumb-init

이미지 빌드 도구 및 방식
- Dockerfile --> Containerfile
- https://github.com/containers/buildah/tree/main/docs/tutorials

```bash
## 루트에서 httpd이미지 저장

podman images
podman save -o httpd.tar <IMAGE_ID>
mkdir httpd
tar xf httpd.tar -C httpd/


oc new-app --name hola quay.io/redhattraining/hello-world-nginx:v1.0
oc get bc          ## hola는 bc에 존재하지 않음.
oc get deploy
oc get rs
```

debug모드 들어가는 방법
---

```bash
oc new-app --name hola quay.io/redhattraining/hello-world-nginx:v1.0
oc get nodes
oc debug node/master01
> chroot /host/
> bash
> master01@> crictl ps | grep hola     # cri-o, crictl명령어 관리
> master01@> crictl inspect <CONTAINER_ID> | grep -A2 root
> MASTER01@> cd /var/lib....
```

configmap, secret 암호화
---
https://docs.openshift.com/container-platform/4.13/security/encrypting-etcd.html


podman build == buildah

- buildah, CD자동화
- podman build, 개발자분들이 로컬에서 빌드 시



configmap
---
사용하시는 애플리케이션, wildfly사용하는 경우, jvm.conf있는 경우 혹은 .xml 를 여러 컨테이너에 동시에 배포 및 업데이트 할때

secret
---
base64로 인코딩 되어서 저장. pod를 실행하면, pod를 통해서 애플리케이션에 데이터 제공.

좀 더 민감하게 보안이 필요한 경우, etcd(configmap,secret)를 암호화가 필요.
>https://docs.openshift.com/container-platform/4.13/security/encrypting-etcd.html


## 쿠버네티스 리소스

YAML: 앞으로 모든 리소스는 YAML으로만 입력(kubectl create, oc create)
JSON: 이전에는 가능하였으나, 지금은 내부적으로 핸들링(API, oc/kubectl(x))
TOML: 설정은 앞으로 TOML으로 구성.
- /etc/containers가 대표적

```bash
oc describe build/build-halo      ## oc describe build build-halo
```


## 이미지 레지스트리

quay.io: OCP는 Quay기반으로 이미지 레지스트리 구성을 권장.
>https://github.com/quay
>다른 레지스트리로 사용이 가능.

ImageStream(is)는 docker-registry기반으로 동작.
>내부 레지스트리 라고 부르기도 함.
>
>
## 애플리케이션 배포

페이지 11 --> 177페이지 연습문제 진행(1번만!!)


## BC

BUILD IMAGE: 애플리케이션 타입별로 이미지가 다름
 - ruby
 - python
 - wildfly

OCP --> K8S(x), BC?? 
new-app --docker, k8s와 호환성
        php~http://, OCP에서만


```
# oc new-app http://git~~~
# oc new-app --docker-image
-> /etc/containers/regsitries.conf
-> grep -Ev '^#|^$' /etc/containers/regsitries.conf

+-----------------------
| BC
| +------- POD -------------+
| | image(external registry)|    ## 내부 레지스트리(IS)
| | source(git_server)      |    ## 내부 혹은 외부
| | = BUILD POD             |
| +-------------------------+
+-----------------------

```


### triggers


