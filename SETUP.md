# 프로젝트 초기 설정 가이드

## 🚨 필수: FAISS 인덱스 생성

`faiss_store` 폴더는 용량이 커서 Git에 포함되지 않습니다. **처음 클론 후 반드시 생성해야 합니다.**

## 빠른 시작

### 1단계: 저장소 클론
```bash
git clone git@github.com:jiwoonkim00/capstone.git
cd capstone
```

### 2단계: Docker 서비스 시작 (데이터베이스 먼저)
```bash
docker-compose up -d mariadb
```

### 3단계: FAISS 인덱스 생성 ⚠️ 필수!
```bash
# 데이터베이스가 준비될 때까지 잠시 대기 (약 10초)
sleep 10

# FAISS 인덱스 생성 (약 5-10분 소요, GPU 권장)
docker-compose exec fastapi python build_faiss.py
```

### 4단계: 전체 서비스 실행
```bash
docker-compose up -d
```

## 상세 가이드

### 방법 1: 데이터베이스에서 생성 (권장)

```bash
# 1. MariaDB가 실행 중이어야 함
docker-compose up -d mariadb

# 2. 레시피 데이터가 DB에 있어야 함
# 데이터가 없으면 먼저 로드:
# docker-compose exec fastapi python json_to_db.py

# 3. FAISS 인덱스 생성
docker-compose exec fastapi python build_faiss.py
```

### 방법 2: JSON 파일에서 생성

```bash
# JSON 파일이 backend-server/fastapi/ 디렉토리에 있어야 함
docker-compose exec fastapi python build_faiss_from_json.py
```

### 방법 3: 로컬에서 직접 생성

```bash
cd backend-server/fastapi

# 가상환경 설정 (선택사항)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# 환경 변수 설정 필요 시
export CUDA_VISIBLE_DEVICES=0  # GPU 사용 시

# FAISS 인덱스 생성
python build_faiss.py
```

## 확인 방법

FAISS 인덱스가 정상적으로 생성되었는지 확인:

```bash
# Docker 컨테이너 내부에서 확인
docker-compose exec fastapi ls -lh /app/faiss_store/

# 다음 파일들이 있어야 함:
# - index.faiss  (FAISS 인덱스 파일)
# - metadata.pkl (레시피 메타데이터)
```

## 문제 해결

### 오류: "FileNotFoundError: faiss_store/index.faiss"

**원인**: FAISS 인덱스가 생성되지 않음

**해결**:
```bash
docker-compose exec fastapi python build_faiss.py
```

### 오류: "Database connection failed"

**원인**: MariaDB가 아직 준비되지 않음

**해결**:
```bash
# MariaDB 상태 확인
docker-compose ps mariadb

# 재시작
docker-compose restart mariadb

# 준비될 때까지 대기 (약 10-30초)
sleep 30

# 다시 시도
docker-compose exec fastapi python build_faiss.py
```

### 오류: "CUDA out of memory"

**원인**: GPU 메모리 부족

**해결**: CPU 모드로 실행하거나 배치 크기 줄이기
- `build_faiss.py`에서 `CHUNK_SIZE` 값을 작게 설정

### 오류: "No recipes found in database"

**원인**: 데이터베이스에 레시피 데이터가 없음

**해결**:
```bash
# JSON에서 데이터베이스로 데이터 로드
docker-compose exec fastapi python json_to_db.py
```

## 다음 단계

FAISS 인덱스 생성이 완료되면:
1. 전체 서비스 실행: `docker-compose up -d`
2. 서비스 확인: http://localhost:8002
3. 로그 확인: `docker-compose logs -f fastapi`

