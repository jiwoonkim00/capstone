from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
from typing import List
from app.faiss_search import recommend_recipes
import time
import httpx
import os
import uuid
import logging
import asyncio
import json

# 라우터 생성 및 CORS 설정
router = APIRouter()

# 추천 요청 모델
class RecommendRequest(BaseModel):
    ingredients: List[str]

# /recommend 엔드포인트 (최적화된 버전)
@router.post("/recommend", response_model=List[dict])
def recommend(req: RecommendRequest):
    results = recommend_recipes(req.ingredients)
    if not results:
        raise HTTPException(status_code=404, detail="조건에 맞는 레시피가 없습니다.")
    return results

# /recommend/legacy 엔드포인트 (기존 버전) - 제거됨

# /recommend/performance 엔드포인트 (성능 측정)
@router.post("/recommend/performance")
def measure_performance(req: RecommendRequest):
    """추천 시스템 성능 측정"""
    
    start_time = time.time()
    results = recommend_recipes(req.ingredients)
    execution_time = time.time() - start_time
    
    return {
        "ingredients": req.ingredients,
        "results_count": len(results),
        "execution_time": round(execution_time, 3),
        "results": results[:5]  # 상위 5개만 반환
    }

# /system/status 엔드포인트 (시스템 상태 확인)
@router.get("/system/status")
def system_status():
    """시스템 상태 및 성능 정보"""
    import torch
    
    gpu_info = {}
    
    if torch.cuda.is_available():
        gpu_info = {
            "available": True,
            "device_name": torch.cuda.get_device_name(0),
            "device_count": torch.cuda.device_count(),
            "memory_allocated": f"{torch.cuda.memory_allocated(0) / 1024**3:.2f} GB",
            "memory_reserved": f"{torch.cuda.memory_reserved(0) / 1024**3:.2f} GB",
            "max_memory": f"{torch.cuda.max_memory_allocated(0) / 1024**3:.2f} GB"
        }
    else:
        gpu_info = {
            "available": False,
            "message": "GPU를 사용할 수 없습니다."
        }
    
    return {
        "gpu": gpu_info,
        "timestamp": time.time()
    }

# WebSocket 채팅 엔드포인트
@router.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):
    """음성 채팅 WebSocket 엔드포인트"""
    await websocket.accept()
    logger = logging.getLogger(__name__)
    logger.info("클라이언트와 WebSocket 연결 성공.")
    
    AI_SERVER_URL = os.getenv("AI_SERVER_URL", "http://203.252.240.65:8001")
    TEMP_DIR = "/tmp"
    os.makedirs(TEMP_DIR, exist_ok=True)
    
    local_temp_files = []
    server1_response_files = []
    
    try:
        # 초기 인사말 전송
        try:
            async with httpx.AsyncClient(timeout=90.0) as client:
                greeting_info_response = await client.post(f"{AI_SERVER_URL}/generate-greeting")
                greeting_info_response.raise_for_status()
                greeting_info = greeting_info_response.json()
                greeting_text = greeting_info["llm_text"]
                audio_filename = greeting_info["audio_filename"]
                await websocket.send_text(json.dumps({"type": "bot_text", "data": greeting_text}))
                await stream_audio(websocket, client, audio_filename)
            logger.info("초기 인사말 처리 완료.")
        except Exception as e:
            logger.error(f"초기 인사말 처리 중 에러 발생: {e}")

        # 사용자 음성 요청 처리 루프
        while True:
            # 1. 클라이언트 음성 수신 및 임시 파일 생성
            wav_data = await websocket.receive_bytes()
            uid = str(uuid.uuid4())
            wav_path = os.path.join(TEMP_DIR, f"{uid}.wav")
            local_temp_files.append(wav_path)
            with open(wav_path, 'wb') as f: f.write(wav_data)
            
            # 2. STT 요청 및 사용자 텍스트 우선 전송
            user_text = ""
            async with httpx.AsyncClient(timeout=60.0) as client:
                with open(wav_path, "rb") as f_wav:
                    files = {"audio": (f"{uid}.wav", f_wav, "audio/wav")}
                    stt_response = await client.post(f"{AI_SERVER_URL}/stt", files=files)
                stt_response.raise_for_status()
                user_text = stt_response.json()["text"]
                
                await websocket.send_text(json.dumps({"type": "user_text", "data": user_text}))
                logger.info(f"사용자 텍스트 우선 전송 완료: {user_text}")
            
            # 3. LLM/TTS 요청 및 결과 전송
            async with httpx.AsyncClient(timeout=90.0) as client:
                payload = {"text": user_text}
                llm_info_response = await client.post(f"{AI_SERVER_URL}/generate-llm-response", json=payload)
                llm_info_response.raise_for_status()
                
                llm_info = llm_info_response.json()
                bot_response_text = llm_info["llm_text"]
                audio_filename = llm_info["audio_filename"]
                
                server1_response_files.append(audio_filename)
                
                await websocket.send_text(json.dumps({"type": "bot_text", "data": bot_response_text}))
                logger.info(f"봇 텍스트 전송 완료: {bot_response_text}")

                await stream_audio(websocket, client, audio_filename)

    except WebSocketDisconnect:
        logger.info("클라이언트가 정상적으로 연결을 종료했습니다.")
    except Exception as e:
        logger.error(f"WebSocket 처리 중 예상치 못한 에러 발생: {e}")
    finally:
        # 세션 종료 시 모든 임시 파일 정리
        logger.info("세션 종료. 파일 정리를 시작합니다.")
        for file_path in local_temp_files:
            try:
                if os.path.exists(file_path): os.remove(file_path)
            except Exception as e:
                logger.error(f"로컬 임시 파일 삭제 실패 {file_path}: {e}")
        
        if server1_response_files:
            logger.info(f"서버 1의 응답 오디오 파일 {len(server1_response_files)}개 정리 시작...")
            try:
                async with httpx.AsyncClient() as client:
                    delete_tasks = [client.delete(f"{AI_SERVER_URL}/audio/{fname}") for fname in server1_response_files]
                    await asyncio.gather(*delete_tasks, return_exceptions=True)
                logger.info("서버 1 응답 오디오 파일 정리 완료.")
            except Exception as e:
                 logger.error(f"서버 1 파일 정리 중 에러 발생: {e}")
        
        logger.info("모든 세션 정리 완료.")

async def stream_audio(websocket: WebSocket, client: httpx.AsyncClient, audio_filename: str):
    """오디오를 스트리밍합니다."""
    AI_SERVER_URL = os.getenv("AI_SERVER_URL", "http://203.252.240.65:8001")
    async with client.stream("GET", f"{AI_SERVER_URL}/audio/{audio_filename}") as audio_response:
        audio_response.raise_for_status()
        async for chunk in audio_response.aiter_bytes():
            await websocket.send_bytes(chunk)
    
    await websocket.send_text(json.dumps({"type": "event", "data": "TTS_STREAM_END"}))
    logger = logging.getLogger(__name__)
    logger.info(f"오디오 스트리밍 완료: {audio_filename}")

# RAG 기반 레시피 추천 엔드포인트
@router.post("/recommend/rag")
def recommend_with_rag(req: RecommendRequest):
    """RAG 기반 레시피 추천"""
    try:
        import logging
        logger = logging.getLogger(__name__)
        logger.info(f"RAG API 호출됨 - 재료: {req.ingredients}")
        
        from .rag_chain import chain
        
        # 사용자 재료를 자연어로 변환
        query = f"이 재료들로 만들 수 있는 요리: {', '.join(req.ingredients)}"
        logger.info(f"쿼리 생성: {query}")
        
        # RAG 체인 실행 (재료를 직접 전달)
        result = chain(query, req.ingredients)
        logger.info(f"RAG 결과: {result}")
        
        return {
            "ingredients": req.ingredients,
            "rag_result": result,
            "method": "RAG"
        }
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"RAG 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"RAG 추천 중 오류 발생: {str(e)}")

# LLM 챗봇 연동 엔드포인트 (Hugging Face 모델 사용)
@router.post("/llama/chat")
def llama_chat(request: dict):
    """LLM 챗봇과 대화 (Hugging Face 모델 사용)"""
    try:
        from .llm_service import get_llm_service
        
        # 메시지 추출
        messages = request.get("messages", [])
        user_message = request.get("message", "")
        
        # 단일 메시지인 경우 리스트로 변환
        if user_message and not messages:
            messages = [
                {"role": "system", "content": "너는 친절한 한국 요리 도우미 셰프야. 사용자의 요리 관련 질문에 도움을 줘."},
                {"role": "user", "content": user_message}
            ]
        
        # LLM 서비스 호출
        llm_service = get_llm_service()
        response_text = llm_service.chat(
            messages=messages,
            max_length=256,
            temperature=0.7
        )
        
        return {
            "response": response_text,
            "model": llm_service.model_name,
            "status": "success"
        }
        
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"LLM 챗봇 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"LLM 챗봇 오류: {str(e)}")

@router.post("/llama/recipe-guide")
def llama_recipe_guide(recipe_data: dict):
    """선택된 레시피로 LLM 챗봇 가이드 시작 (Hugging Face 모델 사용)"""
    try:
        from .llm_service import get_llm_service
        
        # 레시피 정보 추출
        recipe_title = recipe_data.get("title", "레시피")
        recipe_ingredients = recipe_data.get("ingredients", "")
        recipe_content = recipe_data.get("content", "")
        
        # 프롬프트 생성
        prompt = f"""다음 레시피에 대한 요리 가이드를 시작합니다.

레시피 이름: {recipe_title}
재료: {recipe_ingredients}
조리법: {recipe_content[:500]}

이 레시피에 대한 친절하고 단계별 요리 가이드를 제공해주세요. 첫 번째 단계부터 시작해서 차근차근 설명해주세요."""
        
        # LLM 서비스 호출
        llm_service = get_llm_service()
        guide_text = llm_service.generate(
            prompt=prompt,
            max_length=512,
            temperature=0.7
        )
        
        return {
            "guide": guide_text,
            "recipe_title": recipe_title,
            "model": llm_service.model_name,
            "status": "success"
        }
        
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"레시피 가이드 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"레시피 가이드 오류: {str(e)}")

# 예시 헬로우 엔드포인트(유지)
@router.get("/hello")
def hello():
    return {"message": "Say Hello"}

# LLM 테스트 엔드포인트
@router.post("/llm/test")
def test_llm(request: dict):
    """Hugging Face LLM 테스트 엔드포인트"""
    try:
        from .llm_service import get_llm_service
        
        prompt = request.get("prompt", "안녕하세요!")
        max_length = request.get("max_length", 128)
        temperature = request.get("temperature", 0.7)
        
        llm_service = get_llm_service()
        
        result = llm_service.generate(
            prompt=prompt,
            max_length=max_length,
            temperature=temperature
        )
        
        return {
            "status": "success",
            "model": llm_service.model_name,
            "device": llm_service.device,
            "is_loaded": llm_service.is_loaded(),
            "prompt": prompt,
            "response": result,
            "response_length": len(result)
        }
        
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"LLM 테스트 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"LLM 테스트 오류: {str(e)}")

@router.get("/llm/status")
def get_llm_status():
    """LLM 모델 상태 확인"""
    try:
        from .llm_service import get_llm_service
        
        llm_service = get_llm_service()
        
        return {
            "model_name": llm_service.model_name,
            "device": llm_service.device,
            "is_loaded": llm_service.is_loaded(),
            "status": "ready" if llm_service.is_loaded() else "not_loaded"
        }
        
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }
