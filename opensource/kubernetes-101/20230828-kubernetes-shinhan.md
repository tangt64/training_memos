# day 1

## 강의 주제: 쿠버네티스 기초

강사 이름: 최국현

메일 주소: 
- bluehelix@gmail.com
- tang@linux.com


## 문서 및 자료 주소
1. https://github.com/tangt64/training_memos/tree/main/opensource/kubernetes-101
2. https://github.com/tangt64/training_memos
3. https://github.com/tangt64/duststack-k8s-auto

## 선수 사항

1. 컨테이너 런타임 기본 지식 및 이해
2. OCI표준 도구에 대한 기본 지식 및 이해
3. 리눅스 시스템

## runtime

리눅스 배포판(GPL2/3)
---
1. 일반적인 배포판
2. 보안이 강화된 배포판(읽기전용)
3. 하지만 최근에...

- https://www.suse.com/news/OpenELA-for-a-Collaborative-and-Open-Future/
- https://openela.org/
- https://www.reddit.com/r/linux/comments/15ynpwc/prediction_openela_trade_association_is_likely_to/
- https://www.reddit.com/r/RockyLinux/comments/15nhra5/ciq_oracle_and_suse_create_open_enterprise_linux/

* ubuntu --> debian 
* rhel   --> suse, rocky, alma

리눅스 커널
---
1. namespace(ipc, net, mount, time): 자원 격리
2. cgroup(google): 자원 추적
3. selinux(call): 시스템 콜 접근 제한

OCI표준도구
---
1. podman
2. buildah
3. skopeo

쿠버네티스 표준 런타임(CRI지원)
---
- cri-docker
- crio-o
- containerd(docker-engine)

## 랩준비

하이퍼브이 
- https://learn.microsoft.com/ko-kr/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v


# day 2
# day 3
# day 4
# day 5