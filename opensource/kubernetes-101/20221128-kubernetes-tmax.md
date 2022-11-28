# day 1

**문서 및 자료 주소**
1. https://github.com/tangt64/training_memos/tree/main/opensource/kubernetes-101
2. https://github.com/tangt64/training_memos
3. https://github.com/tangt64/duststack-k8s-auto
   3-1. 설치도구(프로비저닝 부분은 제외)


총 4일 동안 진행하는 과정은 전부 기초적인 내용에 중심. 

교육환경
1. 윈도우 10 pro(hyper-v)
2. master x 1EA, work node(compute) x 2 EA
  2-1. utility(bootstrap node(kubernetes images from docker, k8s.io, quay.io))
  2-2. storage server(pNFS(4.1/2), Ceph Storage(Rook))
  3-3. single master -> multi masters(H/A)
3. 가상머신(CentOS 7기반으로 설치, ISO내려받기)  
  - http://mirror.kakao.com/centos/7.9.2009/isos/x86_64/
  - keyword: 'google centos 7 iso '


**강의 주제:** 쿠버네티스 기초
**강사 이름:** 최국현
**메일 주소:** bluehelix@gmail.com, tang@linux.com

## 랩 설명

- minikube, kind: docker, containerd, hypervisor기반으로 클러스터 구현

VM 총 3대 사용.

  - 내부 네트워크(API, Node to Node)
  - 외부 네트워크(ExternalIP, kubectl, 관리 네트워크)
  	* 스토리지 네트워크
  	* 외부 네트워크
  	* 관리 네트워크

### 쿠버네티스 설치시 자원 고려 사항

Intel: vCPU ratio == pCPU == 12 vCPU(8 vCPU)

vCPU: 2개 이상을 요구(이번 교육에서는 권장 4 vCPU)
  - 1번 core: OS(namespace, cgroup, seccomp + k8s)
  - 2번 core: RUNTIME(crio, conainerd, docker)

메모리는
  - CentOS 7 최소 메모리가 2GiB(systemd + ramdisk) 올바르게 동작
  - 4GiB(이번 교육에서는 4기가)


설치시 호스트 이름은 다음처럼 미리 바꾸셔도 상관 없음.
- 아이피는 dhcp로 그냥 받아 오셔도 됨.
- 호스트 이름도 바로 설정 하셔도 되고, 추후에 변경하셔도 됨.

**만약 메모리가 16기가 이라서 부족한 경우 이래처럼 메모리 설정 변경**
네트워크
- External(기본으로 구성이 되어 있음)
- internal(이 네트워크는 내부 네트워크로 구성이 필요함)

>master: master.example.com, 4 vcpu, 4096
>worker node1: node1.example.com. 4 vcpu, 2048 
>worker node2: node2.example.com, 4 vcpu, 2048
