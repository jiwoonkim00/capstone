FROM python:3.10

WORKDIR /app

# GPU 지원 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 앱 파일 복사
COPY ./app /app/app
COPY build_faiss.py .
COPY ./faiss_store /app/faiss_store

# GPU 환경 변수 설정
ENV CUDA_VISIBLE_DEVICES=0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
