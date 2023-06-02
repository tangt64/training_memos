# BOOTCAMP, DO288 - Red Hat OpenShift Developer II: Building Kubernetes Applications

## 랩

1. 레드햇 개발자 계정
2. RHEL, Code Ready Container, IDE...
3. 


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

