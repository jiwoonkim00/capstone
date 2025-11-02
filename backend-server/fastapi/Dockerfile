FROM python:3.10

WORKDIR /app

# GPU 지원 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 앱 파일 복사
COPY ./app /app/app
COPY build_faiss.py .
COPY build_faiss_from_json.py .

# faiss_store 폴더 생성 (빈 폴더 생성)
# 주의: faiss_store의 실제 파일은 Git에 포함되지 않음
# 클론 후 docker-compose exec fastapi python build_faiss.py 실행 필요
RUN mkdir -p /app/faiss_store

# GPU 환경 변수 설정
ENV CUDA_VISIBLE_DEVICES=0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
