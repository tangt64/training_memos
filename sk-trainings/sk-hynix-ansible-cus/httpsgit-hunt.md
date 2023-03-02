$ oc project <PROJECT_NAME>
$ oc create -f -n <PROJECT_NAME>

사용자 인증(257,271)
- 5개 사용자(cluster-admin, admin, basic-user) 
- 시크릿 구성(htpasswd)
- kubeadmin계정은 사용 금지(생성 후 계정 잠구기)

클러스터 퍼미션/프로젝트 퍼미션(271)
- 프로젝트 생성 권한(7개, 8개 생성...)
- 클러스터 관리 권한(cluster-admin)
- 프로젝트 관리 권한(admin)
- 역할 할당(cluster-admin, admin, basic-user)

그룹(273)
- 명시된 사용자를 명시된 그룹에 추가
  * developer:basic-user{developer1, developer2}
   * developer:view{user1, user2}

쿼터(리소스 제한)(399,412)
- 명시된 쿼터 이름으로 생성
- Pod 갯수, 메모리, CPU 갯수, 서비스 갯수
- 프로젝트 별로 올바르게 구성

제한(메모리 및 CPU)(399,412)
- Pod, Container의 CPU, Memory 제한
- 프로젝트 별로 올바르게 구성

애플리케이션 구성(115,337)
- 애플리케이션을 특정 URL(route)로 접근 가능
  * oc new-app 
  * oc expose 
  * oc create route
  * oc expose <DEPLOY>
              <SVC>
              <POD>

스케일링(수동 및 자동)(412)
- 수동으로 특정 애플리케이션 수동 실행(갯수, edit, scale)
- 자동으로 특정 애플리케이션 확장 실행(갯수 및 크기, HPA(YAML))

라우터(337)
- 라우터 명시된 이름으로 생성
- TLS키 구성(생성하는 프로그램 제공, CN/N정보만 잘 입력)
- edge으로만 구성하여도 상관 없음
  * oc expose 
  * oc create route

시크릿(293)
- 명시된 시크릿을 liter형태로 구성
   key:value(name=hello)
- 명시된 시크릿에 특정 메세지 문자열이 추가
- 특정 메세지 문자열를 애플리케이션을 통해서 화면에 출력
  key:value("text")

서비스 어카운트(302)
- 명시된 SA어카운트 생성
- 모든 사용자가 실행 및 사용이 가능(anyuid)

애플리케이션 1(304 참조)
- 서비스 어카운트로 실행***
- 설정 추가 및 제거가 되면 안됨
- 메세지가 출력이 되어야 됨(route)

애플리케이션 2
- 설정 추가 및 제거가 되면 안됨
- 메세지가 출력이 되어야 됨(route)

애플리케이션 3
- 설정 추가 및 제거가 되면 안됨
- 메세지가 출력이 되어야 됨(route)