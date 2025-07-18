# 변경 내용

## 20250714

1. offline 설치 내용 강화
2. rancher dashboard 내용 강화
3. harvester 내용 추가
4. rancher CLI

## 20250511

1. rancher-demo 업데이트

## 20250425

1. kubectl 사용자 추가 부분 제거. 이 부분은 rancher명령어로 통일.
2. 자잘한 랩 버그 수정
3. CSI 및 TKN부분 수정

## 20250416

1. DNSMASQ의 lab.conf의 내용 수정하였습니다.
- 내부/외부 구별
2. config.yaml에서 POD/SVC의 아이피 대역 및 인터페이스를 명확하게 선언 및 표시 하였습니다.
3. rancher cli부분에서 인증서 부분을 수정 하였습니다.


## 20250414

1. DNSMASQ의 lab.conf에 누락된 부분을 추가 하였습니다.

```text
127.0.0.1,192.168.10.250,192.10.10.250
```

## 20250411

다음과 같은 부분에 대해서 변경이 되었습니다.

1. 랩 구성을 변경 하였습니다. 

네트워크는 총 3개로 구성이 되었습니다.

- ens3: node-ip로 사용합니다. 이 영역은 POD 및 SVC가 구성이 됩니다.
- ens4: external-ip로 사용합니다. 이 영역은 API 및 LoadBalancer 그리고 rke2-ingress가 사용합니다.
- ens5: 기존에 사용하였던 infra-net 입니다.

2. HeatStack 변경

네트워크 및 로드밸런서 아이피를 미리 생성하도록 변경 하였습니다. 수동으로 생성이 필요하지 않습니다.

1. 192.10.10.251
2. 192.10.10.252
3. 192.10.10.253
4. 192.10.10.254

총 4개의 아이피를 사용 합니다. rke2-ingress는 192.10.10.251번을 사용합니다.

3. rke2-ingress, ingress-nginx 내용 추가

rke2-ingress 사용을 원하지 않는 경우, ingress-nginx로 전환하는 부분을 추가 하였습니다.

4. 사용자 부분

rke2, kubernetes의 차이점에 대해서 설명을 추가 하였습니다. rke2에서 사용이 가능하도록 랩을 재구성 하였습니다.

5. rancher-cli, rancher-dashboard

명령어 및 대시보드를 통해서 관리 및 구성 부분을 현재 업데이트 하고 있습니다. 
