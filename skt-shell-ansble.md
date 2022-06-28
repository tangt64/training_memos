```bash                                                            
                                                            .---> /etc/shells <--- # chsh -l 
                                                           /
                                                     ------
 login ---> /etc/passwd ---> <USER_ID/USER_PW>  ---> <SHELL>
            -----------                              ------
                 \                                   /bin/bash 
                  '---> /etc/shadow 

```

```bash
왜 "\"이걸 탈출문자라고 하는가?
           -----
           \
            '---> meta에서 제외                  

+ echo 
```


__""__: 문자열, 메타 문자를 인식
__''__: 문자열, 메타 문자를 인식하지 않음 == `\`
__``` ```__: 출력(문자열) <--- 실행파일         


```bash
`;`  :
`&&` :

make config && make && make bzimage && make install(v)
make config ; make ; make bzimage ; make install 
```

## bash built-in command


__ 글로벌 설정 내용(함수포함) __
----------------

/etc/profile.d/
/etc/profile
/etc/bashrc

__/etc/bash_completion.d/__: bash 쉘 기능 확장

- type -a <command>
- echo, source...몇명 명령어는 bash빌트인 명령어로 사용

alias: 
        별명선언, 보통 짧은 명령어 만들시 사용한다.
set:
    KR: 쉘 혹은 환경 변수에 선언하지 않는다
    EN: doesn't set shell nor environment variables

env:
    KR: 환경변수를 명령어로 선언이 가능하다
    EN: can set environment variables for a single command

declare:
    KR: 쉘 변수 선언 
    EN: sets shell variables

export:
    KR: 쉘 변수를 환경변수로 
    EN: makes shell variables environment variables

**빌트인 명령어들**
['https://www.gnu.org/software/bash/manual/bash.html#Bash-Builtins'](빌트인 명령들 모음)

**Set 빌트인 명령어**
['https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin'](set 명령어)


## 오늘 연습문제

### 변수
__wel_jeff__: "Welcome to Jeff!!"

__wel_jay__: "Hell low Jay!! :X"

### 명령어
* adduser
* grep, awk '{ print $1, $2 }'

### 쉘 명령어
```bash
if      /etc/passwd
then
fi 

if      /etc/services
then
fi
```

### 힌트

```bash

echo $(grep ^http /etc/services | head -1 | awk '{ print $1,$2 }')

```

### 사용자 이름

- helix
- jay
- syndy
- jeff

0. 위의 모든 사용자는 비밀번호가 설정이 안되어야 한다.
1. 사용자를 다음 명령어로 생성 후 올바르게 생성이 되었는지 확인한다.
2. 생성된 사용자 중에서 jeff사용자가 있으면 "Welcome to Jeff!!"라는 메세지를 콘솔에 출력한다.
3. 생성된 사용자 중에서 jay사용자가 있으면 "Hell low jay!! :X"라는 메세지를 콘솔에 출력한다.
4. 사용자 서비스 http가 /etc/services에 있는지 확인한다.
5. 사용자 서비스 ssh가 /etc/services에 있는지 확인한다.
6. 4, 5에 결과는 shell 콘솔로 메세지 출력한다.


### 예상 출력 결과

```bash
Welcome to Jeff!!
Hell low jay!! :x

http: http 80/tcp
ssh: ssh 22/tcp

```



