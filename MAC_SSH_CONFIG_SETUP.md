# Mac SSH Config 설정 가이드

## SSH Config 파일 위치
Mac의 SSH 설정 파일은 `~/.ssh/config` 입니다.

## 설정 방법

### 1. SSH Config 파일 생성/편집

Mac의 터미널에서 실행:

```bash
# SSH 디렉토리가 없으면 생성
mkdir -p ~/.ssh

# Config 파일 편집 (없으면 생성됨)
nano ~/.ssh/config
```

또는:

```bash
code ~/.ssh/config  # VS Code 사용 시
vim ~/.ssh/config   # Vim 사용 시
```

### 2. 다음 내용 추가

```ssh-config
Host wsl
    HostName 192.168.1.102
    Port 2222
    User jiwoonkim
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### 3. 권한 설정 (중요!)

```bash
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh
```

## 사용 방법

설정 후 Mac에서 간단하게 접속:

```bash
ssh wsl
```

위 명령어가 다음 명령어와 동일하게 동작합니다:
```bash
ssh -p 2222 jiwoonkim@192.168.1.102
```

## 설정 옵션 설명

- **Host**: 접속할 때 사용할 별칭 (예: `ssh wsl`)
- **HostName**: 실제 IP 주소 또는 도메인
- **Port**: SSH 포트 번호 (기본값: 22, WSL은 2222 사용)
- **User**: SSH 접속 사용자명
- **IdentityFile**: SSH 개인 키 파일 경로 (선택사항)
- **ServerAliveInterval**: 서버에 주기적으로 살아있는지 확인 (초 단위)
- **ServerAliveCountMax**: 살아있는지 확인 실패 횟수 제한

## SSH 키 사용 시

### SSH 키가 이미 있는 경우:
```ssh-config
Host wsl
    HostName 192.168.1.102
    Port 2222
    User jiwoonkim
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

### SSH 키를 새로 생성하는 경우:

1. Mac에서 키 생성:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# 파일 위치: ~/.ssh/id_ed25519 (기본값)
```

2. 공개키를 WSL로 복사:
```bash
ssh-copy-id -p 2222 jiwoonkim@192.168.1.102
# 또는
cat ~/.ssh/id_ed25519.pub | ssh -p 2222 jiwoonkim@192.168.1.102 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

3. WSL에서 권한 설정:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## 고급 설정 예시

```ssh-config
Host wsl
    HostName 192.168.1.102
    Port 2222
    User jiwoonkim
    IdentityFile ~/.ssh/id_ed25519
    
    # 연결 유지 설정
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
    # X11 포워딩 (GUI 앱 사용 시)
    ForwardX11 yes
    
    # 로컬 포트 포워딩 (예: 로컬 8080 -> WSL 8080)
    LocalForward 8080 localhost:8080
    
    # 원격 포트 포워딩 (예: WSL 3306 -> 로컬 3307)
    RemoteForward 3307 localhost:3306
    
    # 컴프레션 (느린 연결 시 유용)
    Compression yes
    
    # 로그 레벨
    LogLevel INFO
```

## 여러 WSL 인스턴스가 있는 경우

```ssh-config
Host wsl-ubuntu
    HostName 192.168.1.102
    Port 2222
    User jiwoonkim

Host wsl-debian
    HostName 192.168.1.102
    Port 2223
    User jiwoonkim
```

## 테스트

설정 후 연결 테스트:

```bash
# 연결 테스트 (실제 접속 없이)
ssh -T wsl

# 실제 접속
ssh wsl
```

## 문제 해결

### "Permission denied (publickey)" 오류
- SSH 키가 WSL에 제대로 복사되었는지 확인
- WSL의 `~/.ssh/authorized_keys` 파일 권한 확인 (600)

### "Connection refused" 오류
- Windows에서 포트 포워딩이 설정되었는지 확인
- Windows 방화벽이 포트 2222를 허용하는지 확인
- WSL에서 SSH 서버가 실행 중인지 확인

### 설정이 적용되지 않는 경우
```bash
# Config 파일 문법 확인
ssh -F ~/.ssh/config -T wsl

# 디버그 모드로 연결 시도
ssh -v wsl
```

