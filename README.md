# CookDuck 프로젝트

레시피 추천 서비스 (FastAPI + Spring + Flutter)

## ⚠️ 중요: 초기 설정 필수!

**처음 클론 후 반드시 FAISS 인덱스를 생성해야 합니다.** 

자세한 내용은 [SETUP.md](./SETUP.md)를 참고하세요.

### 빠른 시작 (3단계)

```bash
# 1. 클론
git clone git@github.com:jiwoonkim00/capstone.git
cd capstone

# 2. 데이터베이스 시작
docker-compose up -d mariadb

# 3. FAISS 인덱스 생성 (필수!)
docker-compose exec fastapi python build_faiss.py

# 4. 전체 서비스 실행
docker-compose up -d
```

## 프로젝트 구조

```
.
├── backend-server/
│   ├── fastapi/          # FastAPI 서버 (레시피 검색, RAG)
│   ├── spring/           # Spring Boot 서버 (인증, 사용자 관리)
│   └── nginx/            # Nginx 리버스 프록시
├── frontend/             # Flutter 웹앱
└── docker-compose.yml    # Docker Compose 설정
```

## 초기 설정

### 1. 저장소 클론

```bash
git clone git@github.com:jiwoonkim00/capstone.git
cd capstone
```

### 2. 환경 변수 설정 (선택사항)

필요시 `.env` 파일 생성:
```bash
# backend-server/fastapi/.env 예시
HF_MODEL_NAME=00PJH/Llama-3.2-Korean-GGACHI-1B-Instruct-v1-koToEn
```

### 3. FAISS 인덱스 생성 (필수)

`faiss_store` 폴더는 Git에 포함되지 않습니다. 처음 실행 전에 반드시 생성해야 합니다.

#### 방법 1: Docker 실행 후 생성 (권장)

```bash
# Docker Compose로 서비스 시작
docker-compose up -d mariadb

# 데이터베이스에 레시피 데이터 로드 (필요한 경우)
# docker-compose exec fastapi python json_to_db.py

# FastAPI 컨테이너에서 FAISS 인덱스 생성
docker-compose exec fastapi python build_faiss.py
```

#### 방법 2: 로컬에서 생성

```bash
cd backend-server/fastapi

# Python 가상환경 설정 (선택사항)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# 데이터베이스 연결 설정 후 실행
python build_faiss.py
```

#### 방법 3: JSON 파일에서 생성

```bash
cd backend-server/fastapi
python build_faiss_from_json.py
```

### 4. Docker Compose로 전체 서비스 실행

```bash
docker-compose up -d
```

## 서비스 접속

- **Frontend (Nginx)**: http://localhost:81
- **FastAPI**: http://localhost:8002
- **Spring Boot**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **MariaDB**: localhost:3307

## 문제 해결

### faiss_store 없음 오류

`faiss_store` 폴더가 없으면 다음 오류가 발생할 수 있습니다:
- `FileNotFoundError: faiss_store/index.faiss`
- `FileNotFoundError: faiss_store/metadata.pkl`

**해결**: 위의 "FAISS 인덱스 생성" 단계를 참고하여 `build_faiss.py`를 실행하세요.

### GPU 관련 오류

GPU가 없거나 NVIDIA 드라이버가 없으면:
- `docker-compose.yml`에서 GPU 설정 제거
- 또는 CPU 모드로 실행 (모델 로딩 속도 느려짐)

## 개발 가이드

### FastAPI 서버 재시작

```bash
docker-compose restart fastapi
```

### 로그 확인

```bash
docker-compose logs -f fastapi
docker-compose logs -f spring
```

### 데이터베이스 접속

```bash
docker-compose exec mariadb mysql -uroot -proot recipe_db
```

## 주요 스크립트

- `build_faiss.py`: 데이터베이스에서 레시피를 읽어 FAISS 인덱스 생성
- `build_faiss_from_json.py`: JSON 파일에서 FAISS 인덱스 생성
- `json_to_db.py`: JSON 파일의 레시피 데이터를 데이터베이스에 로드

