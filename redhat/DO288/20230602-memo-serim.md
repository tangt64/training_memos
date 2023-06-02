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
git clone https://github.com/RedHatTraining/DO288-apps
cd DO288-apps/php-helloworld
ls -l 
> index.php       ## buildah 이미지를 빌드(dockerfile, container)
oc new-app .      ## php-template를 사용해서 애플리케이션 빌드(이미지+소스코드)

oc new-app https://github.com/RedHatTraining/DO288-apps/tree/main/php-helloworld


```