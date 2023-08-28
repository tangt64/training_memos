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


### OpenELA/CIQ

```
- https://www.suse.com/news/OpenELA-for-a-Collaborative-and-Open-Future/
- https://openela.org/
- https://www.reddit.com/r/linux/comments/15ynpwc/prediction_openela_trade_association_is_likely_to/
- https://www.reddit.com/r/RockyLinux/comments/15nhra5/ciq_oracle_and_suse_create_open_enterprise_linux/

ubuntu -> debian 
rhel   -> suse, rocky, alma

```


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

http://172.16.0.84/rocky.iso

https://github.com/tangt64/training_memos/
>opensource/kubernetes-101/20230828-kubernetes-shinhan.md

[하이퍼브이 설치 방법, 마이크로소프트](https://learn.microsoft.com/ko-kr/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v)

[로키 리눅스 9.2, 네이버 미러사이트](http://mirror.navercorp.com/rocky/9/isos/x86_64/Rocky-9.2-x86_64-minimal.iso)

## 리눅스 및 런타임

### namespace/cgroup

__namespace(ns):__ 프로세스 격리(범위), 커널 버전별로 범위가 다름.

__cgroup:__ 프로세스 추적 및 감사(제한(systemd(.slice))).

#### namespace

PID --> namespace ID(NSID)

```bash
ps -e -ocmd,pid | grep bash
-bash                          1635

cd /proc/$$/ns
        [1635]
ls -l
---
cgroup -> 'cgroup:[4026531835]'
ipc -> 'ipc:[4026531839]'
mnt -> 'mnt:[4026531841]'
net -> 'net:[4026531840]'
pid -> 'pid:[4026531836]'
pid_for_children -> 'pid:[4026531836]'
time -> 'time:[4026531834]'
time_for_children -> 'time:[4026531834]'
user -> 'user:[4026531837]'
uts -> 'uts:[4026531838]'

lsns
ip netns
```

### cgroup

1. cgroup은 systemd에 통합(.slice)
2. /usr/lib/systemd/system(.slice)

```bash
systemctl -t slice
systemd-cgls
systemd-cgtop
```

### runtime

1. podman(docker호환)

```bash
dnf install podman -y
systemctl status podman
systemctl is-active podman
dnf module list
dnf install epel-release -y
dnf search podman
dnf install podman-docker podman-compose podman-tui -y
```

/etc/docker
/etc/sysconfig/docker

설정파일
---
/etc/containers/registries.conf: 저장소 관련 설정
/etc/containers/policy.json: 접근을 허용할 저장소 위치

```bash
podman container ls        # docker ps
podman pod ls              # -
podman ps                  # docker ps

grep -Ev '^#|^$' /etc/containers/registries.conf
systemctl enable --now podman
systemctl is-active podman
> active
podman-tui                 # 종료는 ctrl+c
```

podman(crun(conmon))


# day 2
# day 3
# day 4
# day 5