# 연습문제(day 1/2/3/4/5)

시험 대비 연습문제 입니다. 버추얼 박스나 하이퍼브이에서 가상머신 구성 후 진행 합니다.
조건은 아래와 같습니다.

+ 사용중인 리눅스에서 가상 디스크가 3개 구성이 되어 있어야 됨.
+ 디스크 3개 전부 10기가 이상의 공간을 가지고 있어야 됨.
+ centos-9-stream 버전이나 혹은 RHEL 9 권장.
+ 모든 암호는 redhat으로 구성.

- 사용자 생성
  + user1 생성, 쉘은 csh를 사용, 그룹은 shared.
  + hacker 생성, 로그인이 되지 않음, 그룹은 hacker.
  + tester 생성, 쉘은 bash 사용, 그룹은 shared.
  + monitor 생성, 쉘은 false를 사용.
  
- 공유 디렉터리 생성
  + /shared 디렉터리 생성.
    * 이 디렉터리에서 생성되는 파일 및 디렉터리는 그룹으로 공유
  + /public 디렉터리 생성.
    * 이 디렉터리에서 생성한 디렉터리 및 파일은 생성자만 제거가 가능
  + /acl_dir 디렉터리 생성.
    * 이 디렉터리는 그룹 shared만 접근 및 쓰기가 가능
    * hacker, monitor는 접근 및 쓰기가 불가능
    

- SELinux
  + selinux를 항시 사용.
  + /srv/web디렉터리 생성 후 외부에서 접근이 되어야 됨.
  + 웹 서버의 포트 번호는 8999로 변경, 이 포트로 외부에서 접근이 되어야 됨.
  + 외부에서 사용자 웹 디렉터리에 접근이 되어야 됨.

- 성능
  + 서버의 프로파일은 balanced로 구성.
  + 이 설정은 영구적으로 적용이 되어야 됨.
  
- 예약작업
  + 사용자 hacker는 매초 "i am hacker"라는 메세지가 출력이 되어야 됨.
  + 사용자 monitor는 매 24시에 "turn over"라는 메세지가 출력이 되어야 됨.
  
- 컨테이너 이미지 생성
  + 컨테이너 이미지를 생성한다.
  + 파일의 내용은 변경하지 않는다.
  + https://raw.githubusercontent.com/tangt64/training_memos/main/redhat/RH199/Containerfile
  + 이미지 빌드 도구를 사용해서 이미지 생성한다.
  
- 사용자 컨테이너
  + user1사용자는 컨테이너 실행을 할 수 있다.
  + nginx이미지 quay.io/redhattraining/hello-world-nginx:latest 사용한다.
  + 해당 컨테이너는 data/라는 디렉터리를 컨테이너 /var/www/html/으로 연결한다.
  + 컨테이너가 올바르게 생성이 되면, 해당 컨테이너는 .service으로 시작되게 한다.
  + 해당 컨테이너는 부팅시 같이 시작이 되어야 한다.
  
- 디스크 작업1
  + 5기가 짜리 pv를 /dev/vdb에 생성.
  + vg는 모든 pv를 사용, 이름은 test-vg.
  + lv이름 test-lv로 하며 모든 공간을 사용.
  + 파일 시스템은 ext4로 한다.
  + 반드시 마운트가 /mnt/test-lv로 한다.
  
- 디스크 작업2
  + 5기가 영역을 pv로 /dev/vdb에 생성.
  + test-vg에 추가한다.
  + test-lv에서 5기가를 추가한다.
  + 파일 시스템도 확장이 되어야 한다.
  
- 디스크 작업3
  + 5기가 영역을 pv로 /dev/vdc에 생성.
  + test-vdo에 추가한다.
  + vdo를 5기가 크기로 vdo-lv라는 이름으로 추가한다.
  + 리부팅 이후에도 반드시 연결이 되어야 한다.
  
- 디스크 작업4
  + /dev/vdd에 stratis를 구성한다.
  + pool이름은 str-pool로 한다.
  + 파일시스템의 이름 fs-disk라고 한다.
  + 반드시 /srv/pool에 마운트가 자동으로 되어야 한다.
  
- 디스크 작업5 
  + 스왑 영역을 /dev/vdc에 생성한다.
  + lv로 구성하며 이름은 swapswap으로 한다.
  + 크기는 1기가.
  + 반드시 부팅시 올라와야 한다.

- 디스크 작업6
  + vfat를 생성한다.
  + 위치는 /dev/vdc.
  + test-vg를 사용하며 lv의 크기는 2기가.
  + 반드시 부팅시 올라와야 한다.
  
- 다음과 같은 쉘 스크립트를 만든다.
  + 파일크기가 30M메가 파일을 찾는다.
  + 파일의 소유자는 nobody.
  + 파일이 존재하면 /tmp/nobody/에 파일을 복사한다.
  
- ntp서버 주소를 다음처럼 수정한다.
  + 1.kr.pool.ntp.org
  + 3.asia.pool.ntp.org
  + ntp서버와 연결이 되면, 즉각 동기화를 시작한다.