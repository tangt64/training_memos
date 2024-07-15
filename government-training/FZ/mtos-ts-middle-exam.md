# 중간 평가 문제

```bash
dnf install hyperv-* -y && reboot
dnf install epel-release 
dnf install ansible -y

## 스냇샵 생성

curl -o /root/exam.yaml https://raw.githubusercontent.com/tangt64/training_memos/main/government-training/FZ/mtos-exam.yaml
ansible-playbook exam.yaml

## 동작조건
> /dev/sdb, 최소 10G
> NIC 3개
> OOM, CORE, C언어 소스를 다운로드 받아서 컴파일 후 실행

dnf install gcc -y

gcc -o /ust/local/bin/coredump core.c 
> 아래 소스코드 블록 참조
gcc -o /usr/local/bin/oom oom.c
> https://raw.githubusercontent.com/tangt64/codelab/main/C/oom/oom.c
```

```c
#include <stdio.h>
#include <stdlib.h>
int main()
{
  printf("\n");
  printf("Process is aborting\n");
  abort();
  printf("Control not reaching here\n");
  return 0;
}

```


1. 시스템이 정상적으로 부팅 및 로그인이 안되는 이유를 찾고 해결 하세요.
- 루트 패스워드를 정상적으로 mtos로 변경해야 합니다.
- 변경된 패스워드로 root 및 exam사용자에 로그인이 되어야 합니다. 
- 정상적으로 부트업이 되지 않는 경우, 정상적으로 부팅이 되도록 /etc/fstab 및 .mount 자원을 수정해야 합니다.(다음에 시험 평가 환경에 추가)

2. 네트워크가 올바르게 동작하도록 수정 합니다.
- eth0 인터페이스는 DHCP로 동작하도록 수정 합니다.
- eth1 인터페이스는 static, 192.168.10.250/24으로 설정 합니다.
- eth1 인터페이스는 대체 이름으로 storage를 가지고 있습니다.
- eth2 인터페이스는 static, 10.10.10.250/24으로 설정 합니다.
- eth2 인터페이스는 대체 이름으로 internal를 가지고 있습니다.
- 모든 네트워크는 자동화를 위해서 NetworkManager가 아닌, systemd-networkd기반으로 구성 합니다.

3. /dev/file1, file2의 배드블록을 확인한다.
- 문제가 발생한 장치의 커널 메세지를 확인한다.
  + 커널에서 발생한 메세지를 dmesg-block-log.txt에 기록을 남긴다.(jounrnalctl)
- 발생한 배드 블록에 대해서 bad-report.txt에 기록을 남긴다.

4. 디스크 데이터 접근이 되지 않는다. 백업 내용을 가지고 복구를 시도한다. 
- testvg에 있는 testlv데이터에 접근이 되어야 한다. 
- 파일 시스템은 xfs으로 구성이 되어 있으며, 올바르게 접근이 되지 않으면 마운트가 되도록 수정한다.
- 해당 디스크는 /dev/sdb에 구성이 되어있다. 

5. 커널에 다음과 같은 옵션을 적용합니다.
- 네트워크 장치 이름을 이전 방식으로 사용하도록 설정한다.
- st커널 모듈을 영구적으로 동작하도록 설정한다. 
- 커널 모듈 버퍼 크기 확장.(아직 진행하지 않음)

6. /dev/sdb장치의 문제를 해결하세요. 
- /dev/sdb에서 사용하는 LVM2의 PV(sdc3)가 배드블록 올바르게 동작하지 않음.
- /dev/sdb에 sdb4를 추가적으로 구성 및 생성 후, sdb3의 내용을 sdb4로 마이그레이션 한다.
- 문제 없이 옮겨지면 brokenvg의 brokenlv의 내용이 /mnt/brokenpv에 마운트 되도록 한다.
- 해당 장치는 영구적으로 구성이 되어야 한다. 

7. 웹 서비스가 올바르게 동작하지 않는다. 
- 올바르게 동작하도록 오류를 수정한다.

8. 특정 서비스가 OOM으로 종료가 되었다.
- 어떤 서비스가 OOM으로 종료가 되었는지 확인한다.
- OOM이 더 이상 적용되지 않도록 설정한다. 

9. 중앙 로깅 서버를 구성한다.(진행하지 않음)
- 앞으로 모든 서버는 더 이상 rsyslog 및 syslog-ng를 지원하지 않는다.
- 올바르게 중앙서버 로깅을 위해서 journald를 기반으로 구성한다.
- TLS키가 없기 때문에 TLS 없이 동작하도록 구성 및 설치한다.
- 문제가 없이 구성이 되면 각 서버에 hostname으로 로깅 파일에 기록을 남긴다.

10. 코어파일 생성이 되도록 구성한다.
- /usr/local/bin/core를 실행한다.
- 코어 파일이 생성이 되는지 확인한다.
- 올바르게 생성이 되지 않으면 생성이 되도록 설정한다.
- 생성이 되면 간단하게 gdb를 통해서 확인한다. 

11. SELinux 트러블 슈팅(부분적으로 진행)
- 구성 중 발생한 SELinux문제를 해결한다. 
- 수정된 모든 내용들은 리부팅 이후에도 적용이 된다. 

12. 디스크 스케줄러를 변경한다.
- /dev/sdb디스크의 스케줄러는 bfq로 변경한다.
- 해당 내용은 영구적으로 적용이 된다.

13. 모든 사용자의 콘솔 기록은 영구적으로 남도록 한다.