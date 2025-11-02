# WSL SSH 접속 빠른 시작 가이드

## 현재 설정 정보
- **WSL IP**: 172.22.85.100
- **Windows 호스트 IP**: 192.168.1.102 (Mac에서 접속할 때 사용)
- **SSH 포트**: 22 (WSL 내부) → 2222 (Windows에서 외부 접속용)

## 빠른 설정 (3단계)

### 1단계: WSL에서 SSH 서버 시작
```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

또는 스크립트 실행:
```bash
./setup_ssh.sh
```

### 2단계: Windows에서 포트 포워딩 설정
**PowerShell 관리자 권한으로 실행:**

```powershell
# 스크립트 실행 (권장)
.\setup_wsl_ssh_portforward.ps1

# 또는 수동 실행
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=172.22.85.100
New-NetFirewallRule -DisplayName "WSL SSH" -Direction Inbound -LocalPort 2222 -Protocol TCP -Action Allow
```

### 3단계: Mac에서 접속
```bash
ssh -p 2222 jiwoonkim@192.168.1.102
```

## 중요 사항

### IP 주소 설명
- **192.168.1.102**: Windows 호스트의 실제 네트워크 IP (Mac에서 접속 시 사용)
- **172.22.85.100**: WSL 내부 IP (Windows 포트 포워딩에서 사용)
- **10.255.255.254**: WSL 게이트웨이 (WSL 내부 네트워크용)

### SSH 인증
현재 설정에서는 비밀번호 인증이 비활성화되어 있습니다. 다음 중 하나를 선택하세요:

#### 옵션 A: SSH 키 사용 (권장)
```bash
# Mac에서 키 생성 (이미 있으면 생략)
ssh-keygen -t ed25519

# WSL로 공개키 복사
ssh-copy-id -p 2222 jiwoonkim@192.168.1.102

# 또는 수동으로 복사
cat ~/.ssh/id_ed25519.pub
# → 출력된 내용을 WSL의 ~/.ssh/authorized_keys에 추가
```

#### 옵션 B: 비밀번호 인증 활성화
```bash
# WSL에서 실행
sudo nano /etc/ssh/sshd_config
# PasswordAuthentication no → yes로 변경
sudo systemctl restart ssh
```

## 문제 해결

### 연결이 안 될 때
1. Windows 방화벽 확인: 포트 2222가 허용되어 있는지
2. WSL IP 확인: `wsl hostname -I` (Windows에서 실행)
3. 포트 포워딩 확인: `netsh interface portproxy show all` (Windows PowerShell)
4. SSH 서버 상태 확인: `sudo systemctl status ssh` (WSL에서)

### WSL IP가 변경된 경우
WSL을 재시작하면 IP가 변경될 수 있습니다. 이 경우:
1. WSL에서 새 IP 확인: `hostname -I`
2. Windows에서 포트 포워딩 업데이트:
```powershell
# 기존 규칙 삭제
netsh interface portproxy delete v4tov4 listenport=2222 listenaddress=0.0.0.0
# 새 규칙 추가 (새 WSL IP로)
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=[새WSLIP]
```

