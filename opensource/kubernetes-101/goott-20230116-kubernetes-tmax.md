# day 1

강사: 최국현
메일: tang@linux.com

과정은 "쿠버네티스 설치+간단한 명령어 운영"


## 랩을 위한 필요한 도구

### 리눅스 배포판
https://github.com/tangt64/training_memos/
                                          opensource/  
                                                     kubernetes-101/
                                                                    goott-20230116-kubernetes-tmax.md
__레드햇 계열__            

__centos-stream:__ https://www.centos.org/centos-stream/
__rocky linux:__ https://rockylinux.org/ko/download

``` bash
Fedora Core(upstream(rolling)) --- CentOS(upstream) --- RHEL(downsteam)
                                   ------               -----
                                    \                     \
                                     \                     `---> Rocky Linux
                                      \
                                       `---> CentOS-Stream(EOL,EOS 3 years)

            
```
__데비안 계열__
```bash
Debian --- stable
       \   ------
        \   \  
         \   `---> Ubuntu stable
          \
           `---> unstable
                 --------
                 \
                  `---> Ubuntu(bugfix)
```
* Debian Linux: 권장은 데비안 리눅스
* Ubuntu: 비권장
  - ".deb"패키지의 고질적인 질병(?)중 하나가, 의존성 검사가 상대적으로 약함
  - 이전에는 지원이 안됨, 현재는 지원합니다. 


- 하이퍼브이
  * overcommit 지원이 안됨
  * nested 

- 버추얼박스
  * Intel
  * AMD(오동작)

- VMware Workstation, Player
  * 라이센스 문제



# 
