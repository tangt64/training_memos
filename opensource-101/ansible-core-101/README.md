이 스크립트 앤서블 랩 구성 테스트 및 설치를 위한 스크립트 입니다. 스크립트 실행시 다음과 같은 작업을 수행 합니다.

1. 가상 스위치 생성
2. "c:\VMs" 디렉터리 생성
3. 가상머신 이미지 생성

단, 가상머신 시작 시, CD-ROM으로 부팅이 되지 않기 때문에, 4개가 전부 켜진 경우, 종료 후 "CD-ROM"부팅으로 변경 후 다시 가상머신을 시작합니다.

또한, 자원이 부족한 경우, 4대가 전부 동작이 되지 않기 때문에, 하드웨어 사양을 올리시거나 혹은 최소 가상머신 3대를 구성을 권장 합니다.

스크립트 실행 시, 파워쉘에서 다음과 같이 작업을 수행 합니다.

1. 보안모드 상태 확인
---
```powershell
executionpolicy
```
2. 보안모드 일시적으로 변경
---
```powershell
set-executionpolicy unrestricted
```
3.스크립트 실행
---
```powershell
\.setup-lab-2.ps
```

4. 보안모드 복구
---
```powershell
set-executionpolicy restricted
```