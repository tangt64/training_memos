# day 1

이름: 최국현
메일: tang@linux.com

**GITHUB:**  http://github.com/tangt64/training_memos/opensource/podman

## PPT 및 교재 
[PPT](https://github.com/tangt64/training_memos/blob/main/opensource/podman/OPENSOURCE%20CONTAINER.pdf)
[PDF BOOK](https://github.com/tangt64/training_memos/blob/main/opensource/podman/Podman-in-Action-ebook-MEAP-Red-Hat-Developer-All-Chapters.pdf)


**ISO파일 내려받기:** http://172.16.8.31/

## 설치(빠르게)

```bash
hostnamectl set-hostname podman.example.com
dnf install podman -y
dnf install podman-docker -y   ## 도커 호환성 명령어 패키지
```

```bash
dnf install bash-completion epel-release -y
complete -r -p
exit
ssh root@
```

```bash
dnf install fish
chsh -s /bin/fish 
fish
```

```bash
dnf install tmux -y

```

**Ubuntu/REHL(centos)/Rocky/Oracle Linux** 저장소에는 더 이상 docker를 지원하지 않음.
오픈소스 표준 런타임 사양(runtime spec.) **CRI+OCI**

현재 도커는 CRI사양을 따르지 않음. 최신 버전의 containerd기반 docker는 CRI를 충족함.
OCI는 보통, 컨테이너에서 사용하는 이미지(파일). 현재 다수 오픈소스 리눅스는 'podman'으로 전환.

podman는 docker를 대체하는게 주요 목적.

```bash
                .---> 쿠버네티스에서 사용
               /
docker ---> containerd ---> CRI-Docker 
            ----------      [새로운 도커]
            [표준 런타임]
```

도커 명령어 및 이미지는 현재 산업 표준.
