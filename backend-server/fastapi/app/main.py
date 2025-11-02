# main.py

from fastapi import FastAPI
from app.api import router as api_router   # api.py의 router를 api_router라는 이름으로 임포트
from app.cook_api import router as cook_router  # cook_api.py의 router 추가

# 1) 앱 생성
app = FastAPI(
    title="레시피 추천 API",
    description="사용자 재료 기반 레시피 추천 서비스",
    version="1.0.0"
)

# 2) 라우터 포함 — 반드시 app 선언 이후에!
#    prefix는 api.py에서 사용한 APIRouter(prefix="...")와 중복되지 않도록
app.include_router(api_router, prefix="/api/fastapi")
app.include_router(cook_router, prefix="/api/fastapi")

# 3) 헬스체크용 루트 엔드포인트
@app.get("/")
async def read_root():
    return {"message": "레시피 추천 API 서버가 실행 중입니다."}