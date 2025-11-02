/// API 서버 설정
/// Docker 백엔드와 연동하기 위한 중앙 설정 파일
class ApiConfig {
  // 기본 백엔드 URL (Docker Nginx가 포트 81에서 실행됨)
  static const String baseUrl = 'http://localhost:81';
  
  // WebSocket 기본 URL
  static const String wsBaseUrl = 'ws://localhost:81';
  
  // Spring Boot API 경로
  static const String springApiBase = '$baseUrl/api';
  
  // FastAPI 경로
  static const String fastApiBase = '$baseUrl/api/fastapi';
  
  // 외부 서비스 URL (필요시 변경)
  static const String externalImageAnalysisUrl = 'http://203.252.240.65:8002/predict';
  static const String externalLlamaUrl = 'ws://203.252.240.40:8000/ws/chat';
  
  // 카카오 로그인 웹 리다이렉트 URI
  static const String kakaoWebRedirectUri = 'http://localhost:81/kakao/callback';
}

